From: "Gerd v. Egidy" <lists@egidy.de>
Subject: xfrm by MARK: expected behavior of masking
Date: Thu, 14 Oct 2010 15:15:41 +0200
Message-ID: <201010141515.41654.lists@egidy.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:39574 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab0JNN15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 09:27:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

while looking at the xfrm by MARK code I found a case where the masking of 
marks does not work as I would it expect to work.

Take for example a mark value of 5 and a mask of 0xfffffffe
->
src 192.168.5.0/24 dst 192.168.1.0/24 
        dir out priority 1760 ptype main 
        mark 5/0xfffffffe
        tmpl src 172.16.1.131 dst 172.16.1.130
                proto esp reqid 16384 mode tunnel

The code to check the marks always (e.g. in xfrm_policy.c, but several other 
places too) looks like this:

(fl->mark & pol->mark.m) != pol->mark.v

This means that a flow marked with 5 will actually never match. You have to 
use the first number in the mask (4 in this case) to make the policy work.

Is this expected behavior?

I'd expect that the kernel would either
a) still match those packets
or
b) refuse to configure such a policy

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
