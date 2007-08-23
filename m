From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDPv4 port allocation problem
Date: Thu, 23 Aug 2007 10:04:23 -0700
Message-ID: <46CDBE17.7080909@hp.com>
References: <46CD3462.2070403@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas03.cce.hp.com ([161.114.21.106]:56330 "EHLO
	ccerelbas03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795AbXHWRIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 13:08:44 -0400
In-Reply-To: <46CD3462.2070403@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T=F3th L=E1szl=F3 Attila wrote:
> Hello,
>=20
> I noticed that it is possible that the kernel allocates the same UDP

_Which_ kernel - or rather which rev?  There are lots of linux kernels=20
potentially out there...

> port to an application that was used and closed immediately before th=
e
> new application got it. This means that applications that do not spec=
ify
> an exact port and rely on the  kernel to allocate a port for them mig=
ht
> see traffic originally meant for another application.
>=20
> Imagine that two applications want to resolve a name in DNS at about =
the
> same time. The following happens:
>  * first app sends out the DNS query then closes the socket without
> waiting for an answer (e.g. it got interrupted by Ctrl+C)
>  * second app opens an UDP socket, and gets the same port, originally
> assigned to app#1, sends out the DNS query
>  * DNS server responds, the response goes to app#2
>=20
> DNS might not be the perfect example, but you get the idea.=20
> Applications do not expect to receive data on newly opened sockets, n=
ot
> to mention the security implications.

Actually, all applications using UDP are required to cope with just abo=
ut=20
anything since there are no guarantees with UDP of anything other than =
the=20
checksum generally protecting one from corrupt data.

In the specific case of DNS, the resolver library will (damn well bette=
r) be=20
checking the answer it gets against the query it sent.  There will be a=
=20
transaction ID check, and IIRC a check of the returned query against th=
e query sent.

> TCP on the other hand increases the allocated port number for each ne=
w
> socket, the same behaviour for UDP would add certain amount of time t=
hat
> decreases this risk.

Does it always?  If you wait for the length of TIME_WAIT before issuing=
 another=20
bind() request does the port number still increase?


While it might be nice to step through the anonymous port space in some=
 fashion=20
(I suspect the argument would be made that it should be somewhat random=
 to=20
preclude guessing from the outside), applications using UDP are still r=
equired=20
to expect the unexpected wrt data arriving on their socket.

rick jones

>=20
> Is the current behaviour intended?
>=20
> Regards,
> Laszlo Attila Toth
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

