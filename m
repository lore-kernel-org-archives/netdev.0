From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bind()/inet_csk_get_port() fails when no port is requested
Date: Wed, 18 Jan 2012 18:36:59 +0100
Message-ID: <1326908219.4910.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120118151126.01a74dc5@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Marcelo Leitner <mleitner@redhat.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33600 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301Ab2ARRhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:37:03 -0500
Received: by wibhm6 with SMTP id hm6so2404517wib.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 09:37:02 -0800 (PST)
In-Reply-To: <20120118151126.01a74dc5@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 15:11 -0200, Flavio Leitner a =C3=A9=
crit :
> Hi folks,
>=20
> It has been reported to me that bind() fails when you leave
> the port up to the kernel to choose and succeed when you
> request a certain port in the same conditions.
>=20
> For example, let's restrict the ephemeral port range to 3 ports only:
> # echo "32768 32770" > /proc/sys/net/ipv4/ip_local_port_range
>=20
> Assuming the system has two IP addresses: 172.31.1.6/24 and
> 192.168.100.6/24 then run the following python script which
> allocates all ephemeral ports using one IP address and then
> try to bind another one using another IP address.
>=20
=2E..
> Conclusion: When using ephemeral ports, inet_csk_get_port()
> fails without checking if a conflict had happened. When using
> fixed ports on the other hand, inet_csk_get_port() works
> as expected.
>=20
> I will attach a quick hack to illustrate what I am thinking.
> The idea is to check all ports first and if it fails, then
> try again looking for a port that doesn't conflict. So, for
> most cases, the algorithm is the same, but when the system
> ran out of ports, there is a hope :-)
>=20
> Is there a reason to behave like that? or is this a real bug?
> Sounds like a FAQ, but I am not finding an explanation for this
> on the net yet.
>=20

Hi Flavio

This seems a very good idea.

Only drawback is when table is really full, we'll scan it twice.
