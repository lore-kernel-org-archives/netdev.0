From: Jan Engelhardt <jengelh@medozas.de>
Subject: Unaligned access in xfrm_user:copy_to_user_state
Date: Fri, 2 Apr 2010 22:18:59 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004022210270.30875@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:43005 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917Ab0DBUTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 16:19:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


since we seem to be dealing with unaligned access quite recently, here's 
my turn in reporting one:

22:09 ares:/etc # uname -a
Linux ares 2.6.34-rc1 #17 SMP Thu Mar 25 00:08:55 CET 2010 sparc64 
sparc64 sparc64 GNU/Linux
(This is kaber/nf-next)

Apr  2 22:09:53 ares kernel: Kernel unaligned access at TPC[101a0c18] 
copy_to_user_state+0x18/0x120 [xfrm_user]

0000000000000c00 <copy_to_user_state>:
     c00:       9d e3 bf 50     save  %sp, -176, %sp
     c04:       ce 5e 20 80     ldx  [ %i0 + 0x80 ], %g7
     c08:       86 06 20 80     add  %i0, 0x80, %g3
     c0c:       84 06 60 38     add  %i1, 0x38, %g2
     c10:       82 06 20 98     add  %i0, 0x98, %g1
     c14:       90 06 60 60     add  %i1, 0x60, %o0
     c18:       ce 76 60 38     stx  %g7, [ %i1 + 0x38 ]

That happens when strongswan is trying to handle a new incoming tunnel 
request between two IPv6 endpoints (it does not seem to get triggered
for IPv4).
