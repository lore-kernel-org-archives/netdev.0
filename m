From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Thu, 18 Sep 2008 20:31:00 +0300
Message-ID: <200809182031.01291.rdenis@simphalempin.com>
References: <1221387956.9204.7.camel@fry> <20080916.210117.31865904.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>, johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:46719 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219AbYIRRbG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 13:31:06 -0400
In-Reply-To: <20080916.210117.31865904.taka@valinux.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 septembre 2008 15:01:17 Hirokazu Takahashi, vous avez =E9cr=
it=A0:
> UDP is a datagram protocol, so I think applications using UDP should
> care about the size of packets they are going to send rather than
> expecting that the messages will be split into several packets
> automatically. If some of the packets have lost, it will be really ha=
rd for
> the applications to re-create the same ones to send again.

Also, why use UDP for this... If you want stream semantics, why not use=
 TCP or=20
SCTP instead?

> If you want send a large file over UDP, the typical code will be like=
:

> while (...) {
>         sendmsg(fd, &apl_header, sizeof(apl_header), MSG_MORE);
>         offset +=3D sendfile(fd, offset, count);
> }

Correct me if I am wrong, but... Unless you have a big MTU (as _not_ in=
 1500=20
bytes :D), doing an extra syscall might be slower than copying data in =
a=20
single vectorized sendmsg() syscall.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
