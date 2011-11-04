From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942
 recommendation
Date: Fri, 04 Nov 2011 17:24:20 +0100
Message-ID: <1320423860.16609.4.camel@edumazet-laptop>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61279 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755880Ab1KDQYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 12:24:24 -0400
Received: by wwi36 with SMTP id 36so3723144wwi.1
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2011 09:24:23 -0700 (PDT)
In-Reply-To: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 novembre 2011 =C3=A0 07:46 -0700, Fran=C3=A7ois-Xavier L=
e Bail a
=C3=A9crit :
> Hi,
>=20
> I do some tests on a Linux 3.0 kernel with IPv6 forwarding mode enabl=
ed.
>=20
> When I ping (ICMPv6 echo request) on one of its Subnet-Router anycast=
 addresses
> (SRAA, http://tools.ietf.org/html/rfc4291#section-2.6.1),
> the Linux kernel reply with an unicast source address, not the anycas=
t one.
>=20
> When I send an IPv6 UDP packet to a server on Linux on one of its SRA=
A,
> the Linux kernel build a reply with an unicast source address, not th=
e anycast one.
>=20

Nothing in the kernel builds a reply to an UDP packet.

I would say the user application is responsible to build an answer, and
chose appropriate source address.

If your application uses a ANY_ADDR bind, then it must appropriate
action so that a good source address is used in answers.

In case of IPv6 socket, I advise you take a look at IPV6_PKTINFO /
IPV6_RECVPKTINFO options.


> The RFC 4942 states (http://tools.ietf.org/html/rfc4942#section-2.1.6=
) :
> 2.1.6. Anycast Traffic Identification and Security
> [. . .]
>    To avoid exposing knowledge about the internal structure of the
>    network, it is recommended that anycast servers now take advantage=
 of
>    the ability to return responses with the anycast address as the
>    source address if possible.
>=20
> Also, If the source address of reply differs from destination address=
 of the request, many applications are broken.
> Please let me know your feedback.
>=20

'anycast servers' are a combination of kernel and userland parts.
