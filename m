From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Thu, 27 Nov 2014 10:22:13 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411271020061.9397@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-972783701-1417080134=:9397"
Cc: youtux@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alex Strizhevsky <alexxst@gmail.com>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:39884 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363AbaK0JVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 04:21:46 -0500
In-Reply-To: <87ppc957h1.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-972783701-1417080134=:9397
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

So ... might be this is happening even in 16 bit mode?
With our test device we are having no luck: the firmware now at least prints 
dsflowrpt messages, but we seem to not go farther than this.
so - what should we try in your opinion? Go try with the 16 bit mode and try to 
fix the alignment issues?
Any help would be greatly apreciated ... this is becoming a personal challenge, 
even facing a possibly growing number of devices.


On Thu, 27 Nov 2014, Bjørn Mork wrote:

==Date: Thu, 27 Nov 2014 10:16:26
==From: Bjørn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: youtux@gmail.com, linux-usb@vger.kernel.org, netdev@vger.kernel.org
==Subject: Re: Is this 32-bit NCM?
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> I am sorry for the indecent capture - but I didn't manage to get a
==> better one till now.
==> We modified the driver: but I wanted to be sure ... is this 32-bit NCM?
==
==
==Yes, it looks OK to me.  I have only looked at it manually, so I could
==have missed something.  But the signatures and header field lengths seem
==fine.
==
==I did notice one issue though, which might be related to more generic
==alignment bugs in the driver?
==
==The modem sends this. Notice how the single ethernet frame inside starts
==at 0072, skipping 2 unused bytes, making the IP packet start at a 4-byte
==aligned 0080:
==
==0040  6e 63 6d 68 10 00 c7 00 cd 00 00 00 10 00 00 00   ncmh............
==0050  6e 63 6d 30 20 00 00 00 00 00 00 00 00 00 00 00   ncm0 ...........
==0060  32 00 00 00 9b 00 00 00 00 00 00 00 00 00 00 00   2...............
==0070  00 00 0c 5b 8f 27 9a 64 4c 54 99 45 e5 d5 08 00   ...[.'.dLT.E....
==0080  45 00 00 8d 05 7f 40 00 33 06 af d8 95 9a a7 5b   E.....@.3......[
==0090  0a 1f 4a ff 01 bb ce 5c c0 d5 a0 ba 8c 57 85 63   ..J....\.....W.c
==00a0  80 18 09 e6 35 0b 00 00 01 01 08 0a 4d 8b 3f fe   ....5.......M.?.
==00b0  00 78 a8 a7 16 1a 21 17 60 0e 73 21 c7 d6 77 cd   .x....!.`.s!..w.
==00c0  92 00 69 26 54 28 cb 19 25 2a 16 6b 82 6b bf ba   ..i&T(..%*.k.k..
==00d0  46 a7 8a 6e eb 36 59 25 eb 9b e2 bb 4b 53 f2 4d   F..n.6Y%....KS.M
==00e0  ce 11 dd 88 06 e8 23 24 8a 96 03 d9 61 31 34 9b   ......#$....a14.
==00f0  68 f3 e9 5c fd d1 77 5f 18 75 fd 10 4d cb e7 29   h..\..w_.u..M..)
==0100  96 89 3d 75 fe 11 15 82 28 88 5b ba b0            ..=u....(.[..
==
==
==
==While we, after a large number of unused 0 bytes due to the fixed size
==NDP allocation, start the ethernet frame at 01a8, making the IP packet
==start at a 2-byte aligned offset at 01b6:
==
==0040  6e 63 6d 68 10 00 d5 00 aa 01 00 00 10 00 00 00   ncmh............
==0050  6e 63 6d 30 20 00 00 00 00 00 00 00 00 00 00 00   ncm0 ...........
==0060  68 01 00 00 42 00 00 00 00 00 00 00 00 00 00 00   h...B...........
==0070  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0080  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0090  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00a0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00b0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00c0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00d0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00e0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==00f0  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0100  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0110  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0120  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0130  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0140  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0150  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0160  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0170  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0180  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==0190  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
==01a0  00 00 00 00 00 00 00 00 4c 54 99 45 e5 d5 0c 5b   ........LT.E...[
==01b0  8f 27 9a 64 08 00 45 00 00 34 84 0b 40 00 40 06   .'.d..E..4..@.@.
==01c0  24 a5 0a 1f 4a ff 95 9a a7 5b ce 5c 01 bb 8c 57   $...J....[.\...W
==01d0  85 63 c0 d5 a1 13 80 10 03 59 0f 23 00 00 01 01   .c.......Y.#....
==01e0  08 0a 00 79 00 6f 4d 8b 3f fe                     ...y.oM.?.
==
==
==This is not so nice, and I do wonder if it is according to the requested
==alignment from the modem?  If not, then that is more likely to break
==stuff than the 16-bit vs 32-bit header issue.
==
==
==
==Bjørn
==
--8323328-972783701-1417080134=:9397--
