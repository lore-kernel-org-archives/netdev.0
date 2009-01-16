From: jpo234@netscape.net
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 06:12:40 -0500
Message-ID: <8CB45E27B3643B3-2F30-917@webmail-stg-d07.sysops.aol.com>
References: <8CB45DED3262281-2F30-8C9@webmail-stg-d07.sysops.aol.com> <200901161256.15744.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imo-d22.mx.aol.com ([205.188.144.208]:43080 "EHLO
	imo-d22.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757371AbZAPLU5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 06:20:57 -0500
In-Reply-To: <200901161256.15744.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi,
sorry, but a transport-layer raw socket is something I'd like to avoid.=
=20
The reason is, that I get the ready made packets from a tun device.=20
This means I can't make assumptions about the protocol value. Using=20
transport-layer raw sockets would mean that I had to open a new socket=20
for every packet I'm forwarding (yeah, I would cache them). This was=20
the way I had decided upon before Herbert's hint, but I think you=20
understand why I'd rather not go this way.

Regards
  Joerg

-----Original Message-----
=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
To: ext jpo234@netscape.net <jpo234@netscape.net>
Cc: herbert@gondor.apana.org.au; netdev@vger.kernel.org
Sent: Fri, 16 Jan 2009 11:56 am
Subject: Re: Sending complete IPv6 packets without bypassing=20
netfilter/IPsec

On Friday 16 January 2009 12:46:30 ext jpo234@netscape.net, you wrote:
> Herbert,
> sorry for bothering you (and everybody else on the list) again. It
> seems that the stack does not replace a "::" source address with a=20
real
> one when using a PF_INET6/SOCK_RAW/IPPROTO_RAW socket the way it does
> with an IP_HDRINCL IPv4 socket for "0.0.0.0". Do I have to fill this
> one myself

Yes. That's the _whole_ point of writing the header yourself.

> or is there another trick to achieve this?

Use transport-layer raw sockets and let the kernel do the network=20
header.

--
R=C3=A9mi Denis-Courmont
Maemo Software, Nokia Devices R&D






