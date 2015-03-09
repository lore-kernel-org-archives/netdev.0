From: =?koi8-r?B?8MHOz9cg4c7E0sXK?= <rockford@yandex.ru>
Subject: Bug in drivers/net/ethernet/freescale/fec_main.c, TX is broken. In 4.0.0-rc3
Date: Mon, 09 Mar 2015 22:50:28 +0300
Message-ID: <390621425930628@web28o.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nimrod Andy <b38611@freescale.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward2o.mail.yandex.net ([37.140.190.31]:60914 "EHLO
	forward2o.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbbCIUAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 16:00:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Commit 2b995f63987013bacde99168218f9c7b252bdcf1 in 4.0.0-rc3 introduces=
 a nasty bug in transmit, corrupting packets.

To reproduce:

$ dd if=3D/dev/zero of=3Dzeros bs=3D1M count=3D20
$ md5sum -b zeros
8f4e33f3dc3e414ff94e5fb6905cba8c *zeros

This checksum is correct.

Copy file "zeros" to another host with NFS, and it gets corrupted, chec=
ksum is changed.
=46ile should be big, small amounts of transmit isn't affected.

I use an i.MX6 Quad board.

If this commit is reverted, all works fine.

--
 =E1=CE=C4=D2=C5=CA
