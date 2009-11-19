From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: Oops in Unix sockets code
Date: Thu, 19 Nov 2009 14:40:18 +0100
Message-ID: <200911191440.18949.borntraeger@de.ibm.com>
References: <20091119132028.GA22427@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Blaschka <frank.blaschka@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:37702 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbZKSNkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 08:40:47 -0500
In-Reply-To: <20091119132028.GA22427@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag 19 November 2009 14:20:28 schrieb Blaschka:
>     <1>Unable to handle kernel pointer dereference at virtual kernel address 000000007575e000
>     <4>Oops: 0011 [#1] PREEMPT SMP DEBUG_PAGEALLOC
0011(page translation excepton) and DEBUG_PAGEALLOC might indicate a use after free.

>     <4>Modules linked in: sunrpc qeth_l3 dm_multipath dm_mod qeth ccwgroup chsc_sch
>     <4>CPU: 0 Not tainted 2.6.31-39.x.20091102-s390xdefault #1
>     <4>Process hald (pid: 2117, task: 000000007d200c40, ksp: 000000007ab33880)
>     <4>Krnl PSW : 0704100180000000 00000000003a15f8 (_raw_read_trylock+0x0/0x28)
>     <4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
>     <4>Krnl GPRS: 16c8a00000000000 000000007d200c40 000000007575ed18 0000000000000003
>     <4>           00000000005853d2 000000007d201470 0000000000000002 000000007ab33c30
>     <4>           0000000075746c78 000000007a74da48 000000000051a16a 000000007575ed18
>     <4>           000000007575ed30 00000000005da190 00000000005853dc 000000007ab338c8
>     <4>Krnl Code: 00000000003a15e8: c03000185811        larl    %r3,6ac60a
>     <4>           00000000003a15ee: c0e5fffffdd9        brasl   %r14,3a11a0
>     <4>           00000000003a15f4: a7f4ffce            brc     15,3a1590
>     <4>          >00000000003a15f8: 58302000            l       %r3,0(%r2)
>     <4>           00000000003a15fc: b9170033            llgtr   %r3,%r3
>     <4>           00000000003a1600: 1853                lr      %r5,%r3
>     <4>           00000000003a1602: 1813                lr      %r1,%r3
>     <4>           00000000003a1604: a75a0001            ahi     %r5,1
>     <4>Call Trace:
>     <4>([<00000000005853d2>] _read_lock+0x5a/0x98)
>     <4> [<000000000051a16a>] unix_write_space+0x36/0xb0
[...]

So it looks like that struct sock *sk is already gone in unix_write_space.
Since I have no clue about the socket code, I can only guess that there is a
locking or refcount issue.

Christian

