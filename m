From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 20:06:34 +0300
Message-ID: <200805132006.35010.rdenis@simphalempin.com>
References: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:37604 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751604AbYEMRGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 13:06:41 -0400
In-Reply-To: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 13 May 2008 19:59:35 David Stevens, vous avez =E9crit=A0:
>         Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't really =
that
> either, as Remi said.
>         If you do a connect() on a UDP socket, it doesn't cease to
> be a SOCK_DGRAM socket, so I don't really care about that distinction=
,
> but if others do, that's ok with me. There are ACKs here, too, so may=
be.

But connect() is a _non-blocking_ operation which merely sets the _defa=
ult_=20
destination (you can still sendto() someone else).

Using socket types blindly may also break applications using=20
getsockopt(SO_TYPE), if they exists (I think I wrote one once...) to=20
determine how to use a socket.

SOCK_DCCP was perhaps a bad idea, but SOCK_DGRAM seems worse. In the en=
d, it's=20
more a matter of patching libc getaddrinfo than changing the kernel API=
=20
anyway. Did AIX not have a similar socket type as DCCP under a more gen=
eric=20
name by the way?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
