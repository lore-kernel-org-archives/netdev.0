From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question about /proc/net/netlink mystery
Date: Wed, 20 May 2009 20:51:03 +0100
Message-ID: <1242849063.6618.64.camel@achroite>
References: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:42987 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbZETTvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:51:08 -0400
In-Reply-To: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-20 at 22:22 +0300, Rami Rosen wrote:
> Hi,
> I tried to figure this out, but something is mysterious here to me.
>=20
>  cat /proc/net/netlink
> shows:
> sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks
>=20
> Why is the Eth here in the second column title?
> It does not seem that this column has anything to do with network
> interfaces.
>=20
> A short look to the code, in netlink_seq_show() , net/netlink/af_netl=
ink.c,
> will show that the values in this column are s->sk_protocol.
=EF=BB=BF
=EF=BB=BFI would guess that "Eth" is meant to be short for "Ethertype",=
 a
layer-3 protocol number, although sock::sk_protocol actually holds a
layer-4 protocol number.

> So it seems that the title should be here different; it should repres=
ent
> the protocol (since s->sk_protocol is assigned
> the number of the protocol of the netlink socket ;
> for example, NETLINK_ROUTE is 0, NETLINK_AUDIT is 9, and so on ; (see
> include/linux/netfilter.h)
>=20
> So shouldn't it be something like "Proto"?

Yes, but changing column names in /proc risks breaking the programs tha=
t
read them.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

