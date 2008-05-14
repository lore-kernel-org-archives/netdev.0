From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 20:47:40 +0300
Message-ID: <200805142047.40726.rdenis@simphalempin.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39434 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbYENRrn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 13:47:43 -0400
In-Reply-To: <4829E87F.1070006@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Tuesday 13 May 2008 22:14:07 Ulrich Drepper, vous avez =C3=A9crit=C2=
=A0:
> R=C3=A9mi Denis-Courmont wrote:
> > In any case, getaddrinfo() should be patched to
> > [...]
>
> What should be the behavior is socktype and protocol are zero?  Shoul=
d
> these two types be returned by default?  What others?  So far we retu=
rn
> TCP, UDP, and raw socket information.  I'd rather keep the list short
> but since we already have raw sockets in there (because they are in
> POSIX) I won't reject anything that's more useful than raw sockets.

Well... I've always wondered what the use of both zeroes was supposed t=
o be.

In AI_PASSIVE mode, it makes no sense, since there is no way you can ha=
ndle=20
passive SOCK_STREAM sockets (bind+listen+accept) and "passive" SOCK_DGR=
AM=20
sockets in any common way (bind+recvfrom+sendto).

Even in active mode (connect+send), I cannot figure out how to share=20
SOCK_STREAM code with SOCK_DGRAM code, given the incompatible end-of-fi=
le and=20
datagram boundaries semantics (or lack thereof).

Hence, it seems that both zeroes is only of use to enumerate the suppor=
ted=20
protocol (yeah right...). If that's so adding DCCP and even UDP-Lite wo=
uld be=20
OK, even though they are corner-case protocols. Do you intend to=20
implement "dccp" when parsing /etc/services, though?

=46rankly, I have no definite answer, and I'm not any kind of standard =
body to=20
make one in the first place :P

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
