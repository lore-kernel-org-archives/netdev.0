From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Re: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken. In 4.0.0-rc3
Date: Tue, 10 Mar 2015 23:12:14 +0300
Message-ID: <3625951426018334@web26j.yandex.ru>
References: <390621425930628@web28o.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nimrod Andy <b38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11.mail.yandex.net ([95.108.130.93]:51294 "EHLO
	forward11.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbbCJUMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 16:12:19 -0400
In-Reply-To: <390621425930628@web28o.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!
Adding lakml to cc:

> Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introduc=
es a nasty bug in transmit, corrupting packets.
>
> To reproduce:
>
> $ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
> $ md5sum -b zeros
> 8f4e33f3dc3e414ff94e5fb6905cba8c *zeros
>
> This checksum is correct.
>
> Copy file "zeros" to another host with NFS, and it gets corrupted, ch=
ecksum is changed.
> File should be big, small amounts of transmit isn't affected.
>
> I use an i.MX6 Quad board.
>
> If this commit is reverted, all works fine.

3.19 works fine too.
And it is not random corruption, when copying all-zero file this is rec=
eived on NFS host:
$ hd zeros | head -16
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |..........=
=2E.....|
*
0052c0f0  00 00 00 00 00 00 00 00  1c f0 9f e5 1c f0 9f e5  |..........=
=2E.....|
0052c100  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 1c f0 9f e5  |..........=
=2E.....|
0052c110  1c f0 9f e5 1c f0 9f e5  1c f0 9f e5 74 fb 00 00  |..........=
=2E.t...|
0052c120  bc ff 93 00 c0 ff 93 00  c4 ff 93 00 c8 ff 93 00  |..........=
=2E.....|
0052c130  cc ff 93 00 d0 ff 93 00  d4 ff 93 00 d8 ff 93 00  |..........=
=2E.....|
0052c140  13 00 00 00 28 63 29 20  43 6f 70 79 72 69 67 68  |....(c) Co=
pyrigh|
0052c150  74 20 32 30 30 37 2d 32  30 31 32 2c 20 46 72 65  |t 2007-201=
2, Fre|
0052c160  65 73 63 61 6c 65 20 53  65 6d 69 63 6f 6e 64 75  |escale Sem=
icondu|
0052c170  63 74 6f 72 2e 20 41 6c  6c 20 72 69 67 68 74 73  |ctor. All =
rights|
0052c180  20 72 65 73 65 72 76 65  64 2e 00 00 dd 00 2c 41  | reserved.=
=2E...,A|
0052c190  11 73 00 00 d3 74 00 00  3d 75 00 00 a9 78 00 00  |.s...t..=3D=
u...x..|
0052c1a0  4f 78 00 00 75 77 00 00  07 76 00 00 c3 79 00 00  |Ox..uw...v=
=2E..y..|
0052c1b0  09 7a 00 00 75 7a 00 00  97 22 00 00 49 1f 00 00  |.z..uz..."=
=2E.I...|
0052c1c0  b9 21 00 00 ff 70 00 00  90 21 90 00 23 4a 52 f8  |.!...p...!=
=2E.#JR.|

Looks like zero page with vectors at beginning.
=46reescale i.MX6 Quad-based Embedsky E9 board.

--
 =E1=CE=C4=D2=C5=CA
