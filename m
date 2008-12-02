From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: EOF and zero-length packets?
Date: Tue, 2 Dec 2008 20:57:45 +0200
Message-ID: <200812022057.45844.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:45636 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752566AbYLBS5u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 13:57:50 -0500
Received: from basile.remlab.net (unknown [IPv6:2002:591b:3d4a:0:211:11ff:fe25:e6b4])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: remi)
	by yop.chewa.net (Postfix) with ESMTP id 3213629D
	for <netdev@vger.kernel.org>; Tue,  2 Dec 2008 19:57:49 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

When dealing with SOCK_STREAM sockets, a zero read means the other side=
 has=20
shut down the connection, and there will be no more incoming data.

When dealing with SOCK_DGRAM/SOCK_RAW sockets, a zero read means we got=
 an=20
empty packet, and we should keep on reading.

What about SOCK_DCCP? It seems both scenarios yield zero, which is, hmm=
,=20
problematic from userland. Is checking for POLLHUP in revents the recom=
mended=20
disambiguation? that seems a bit backward to me :(

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
