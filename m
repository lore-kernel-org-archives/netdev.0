From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Kernel panic nf_nat_setup_info+0x5b3/0x6e0
Date: Wed, 23 Feb 2011 20:07:21 +0300
Message-ID: <118081298480841@web25.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20.mail.yandex.net ([95.108.253.145]:57609 "EHLO
	forward20.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370Ab1BWRPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:15:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Got this panic yesterday:
http://www.progtech.ru/~oleg/crash.txt

The offending instruction is:
cmpb 54(%edx), %cl # <variable>.tuple.dst.protonum,

and here is the assembler code of net/ipv4/netfilter/nf_nat_core.c:
http://www.progtech.ru/~oleg/nf_nat_core.s

Quick investigation lead me to conclusion that the problem is in
return of same_src function:

        return (t->dst.protonum == tuple->dst.protonum &&
                t->src.u3.ip == tuple->src.u3.ip &&
                t->src.u.all == tuple->src.u.all);

So either t or tuple pointer is bad, but I don't understand how
this can be.

Looks like the similar situation described here:
https://bugzilla.kernel.org/show_bug.cgi?id=21512

Any thoughts on this?
Thank you!

-- 
wbr, Oleg.
