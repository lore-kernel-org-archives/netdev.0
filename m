From: Flavio Leitner <fbl@redhat.com>
Subject: Re: bind()/inet_csk_get_port() fails when no port is requested
Date: Wed, 18 Jan 2012 15:57:42 -0200
Message-ID: <20120118155742.5ed38f98@asterix.rh>
References: <20120118151126.01a74dc5@asterix.rh>
	<1326908219.4910.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Marcelo Leitner <mleitner@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932374Ab2ARR5r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:57:47 -0500
In-Reply-To: <1326908219.4910.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jan 2012 18:36:59 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 18 janvier 2012 =C3=A0 15:11 -0200, Flavio Leitner a =C3=A9=
crit :
> > Hi folks,
> >=20
> > It has been reported to me that bind() fails when you leave
> > the port up to the kernel to choose and succeed when you
> > request a certain port in the same conditions.
> >=20
> > For example, let's restrict the ephemeral port range to 3 ports onl=
y:
> > # echo "32768 32770" > /proc/sys/net/ipv4/ip_local_port_range
> >=20
> > Assuming the system has two IP addresses: 172.31.1.6/24 and
> > 192.168.100.6/24 then run the following python script which
> > allocates all ephemeral ports using one IP address and then
> > try to bind another one using another IP address.
> >=20
> ...
> > Conclusion: When using ephemeral ports, inet_csk_get_port()
> > fails without checking if a conflict had happened. When using
> > fixed ports on the other hand, inet_csk_get_port() works
> > as expected.
> >=20
> > I will attach a quick hack to illustrate what I am thinking.
> > The idea is to check all ports first and if it fails, then
> > try again looking for a port that doesn't conflict. So, for
> > most cases, the algorithm is the same, but when the system
> > ran out of ports, there is a hope :-)
> >=20
> > Is there a reason to behave like that? or is this a real bug?
> > Sounds like a FAQ, but I am not finding an explanation for this
> > on the net yet.
> >=20
>=20
> Hi Flavio
>=20
> This seems a very good idea.
>=20
> Only drawback is when table is really full, we'll scan it twice.
>=20

That's right. Maybe checking for conflicts in the first round
helps, but it would add a cost for the average case scenario.

But first, I'd like to know if this is a bug before spending
more time working on it. Maybe there is a reason for behaving
like that.

thanks!
fbl
