From: Arthur Marsh <arthur.marsh@internode.on.net>
Subject: inbound connection problems when "netlink: test for all flags of the NLM_F_DUMP composite" commit applied
Date: Sun, 16 Jan 2011 19:24:41 +1030
Message-ID: <54347.1295168081@internode.on.net>
Reply-To: arthur.marsh@internode.on.net
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:8390 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751011Ab1API7s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jan 2011 03:59:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
 
 
 This bug was originally posted at https://bugzilla.kernel.org/show_bug.cgi?id=26632 
 
With kernels up to and including 2.6.37-git7, inbound telnetd-ssl connections worked fine. 
With kernel 2.6.37-git9 and later inbound telnetd-ssl connections failed, and on machine shut-down, there were warning messages about daemons not return status. 
 
A git bisect on Linus' kernel tree revealed: 
 
0ab03c2b1478f2438d2c80204f7fef65b1bca9cf is the first bad commit 
commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf 
Author: Jan Engelhardt <jengelh@medozas.de> 
Date:   Fri Jan 7 03:15:05 2011 +0000 
 
    netlink: test for all flags of the NLM_F_DUMP composite 
 
    Due to NLM_F_DUMP is composed of two bits, NLM_F_ROOT | NLM_F_MATCH, 
    when doing "if (x & NLM_F_DUMP)", it tests for _either_ of the bits 
    being set. Because NLM_F_MATCH's value overlaps with NLM_F_EXCL, 
    non-dump requests with NLM_F_EXCL set are mistaken as dump requests. 
 
    Substitute the condition to test for _all_ bits being set. 
 
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de> 
    Acked-by: Pablo Neira Ayuso <pablo@netfilter.org> 
    Signed-off-by: David S. Miller <davem@davemloft.net> 
 
:040000 040000 1a0717ab0c87787309c3c3af88d666b44f327f64 
cba6279de85b7ebeaf21f19f1d93b59468fdd01d M      net 
 
I tried git cherry-pick 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf and verified 
that the resulting kernel had these problems, then git revert 
0ab03c2b1478f2438d2c80204f7fef65b1bca9cf and verified that the resulting kernel 
did *not* have problems. 
 
Arthur. 
