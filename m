From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sun, 12 Jan 2014 06:53:47 -0800 (PST)
Message-ID: <1389538427.32032.YahooMailBasic@web125505.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm42.bullet.mail.ne1.yahoo.com ([98.138.120.49]:27193 "EHLO
	nm42.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbaALO4r convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 09:56:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1/11/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wrot=
e:

> On Sat, Jan 11, 2014 at 05:38:27PM +0400, Alexey Kuznetsov wrote:
> > On Sat, Jan 11, 2014 at 5:06 PM, Fran=E7ois-Xavier Le Bail
> > <fx.lebail@yahoo.com> wrote:
> > > Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
> >=20
> > Actually, I was alerted by reset processing in your patch, it canno=
t be right.
> >=20
> > Do not you think this must not be enabled for common use? At least
> > some separate sysctl disabled by default.

> The idea I had, was, that if a socket does knowingly bind to an anyca=
st
> address, it is allowed to do so and process queries on it with both T=
CP and
> UDP. I don't think we need a sysctl for that? Anycast addresses are e=
ither
> pre-defined (e.g. the subnet router anycast address) or specified by =
a flag
> when the administrator adds one. Currently one can only add anycast a=
ddresses
> either by forwarding and gets the per-subnet anycast address or with =
a
> setsockopt IPV6_JOIN_ANYCAST.

> So the problem is what should be allowed when the socket listens on a=
n any
> address? Maybe this should be protected by a sysctl?

Hi,

TCP case:
With my two patches (the one for bind and this one for tcp), when a
SOCK_STREAM socket listen to in6addr_any, the server is able to=20
send TCP reply with unicast or anycast source address,=A0according
to the destination address used by the client.

dest request unicast =3D> src reply unicast (current behavior)
dest resquet anycast =3D> src reply anycast (new)

So, I don't think there is a need for a sysctl.

UDP case:
By default (no socket option), the server program don't know the
destination address of the request. The ipv6_dev_get_saddr() is=20
used for choosing the unicast source address of the reply.

I am not sure a change is needed here.

When using IPV6_RECVPKTINFO, a server is able to know
the destination address of the request and can use it as source
address for the reply.
To enable anycast for this (don't get EINVAL), there is need for
a patch like the one I posted ("IPv6: add option to use anycast
addresses as source addresses for datagrams").
I am working on a v2.

With the appropriate change:
dest request unicast =3D> src reply unicast (current behavior)
dest resquet anycast =3D> src reply anycast (new)

I don't think, there either, there is a need for a sysctl.

What do you think about it?

BR,
=46rancois-Xavier
