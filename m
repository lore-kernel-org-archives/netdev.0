From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT PATCH 3/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Mon, 20 Jun 2011 13:51:09 -0700
Message-ID: <20110620135109.63d81d83@nehalam.ftrdhcpuser.net>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
	<51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
	<1308600681.2701.159.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38059 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab1FTUvM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 16:51:12 -0400
In-Reply-To: <1308600681.2701.159.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jun 2011 21:11:21 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > This is the only place where NETIF_F_* feature flags are exposed
> > to userspace.
>=20
> Except sysfs.
>=20
> > After this patch feature flags may be changed/reordered freely.
> [...]
>=20
> Really, what do you think was the point of exposing features through
> sysfs if they are going to be changed?
>=20
> Oh, but they have been changed already:
>=20
> v2.5.70
> net-sysfs added
>=20
> v2.6.15
> +#define NETIF_F_UFO             8192    /* Can offload UDP Large Sen=
d*/
>=20
> v2.6.18
> -#define NETIF_F_TSO            2048    /* Can offload TCP/IP segment=
ation */
> -#define NETIF_F_UFO             8192    /* Can offload UDP Large Sen=
d*/
> +#define NETIF_F_GSO            2048    /* Enable software GSO. */
> +#define NETIF_F_GSO_SHIFT      16
> +#define NETIF_F_TSO            (SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
> +#define NETIF_F_UFO            (SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
> +#define NETIF_F_GSO_ROBUST     (SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
> +#define NETIF_F_TSO_ECN                (SKB_GSO_TCP_ECN << NETIF_F_G=
SO_SHIFT)
> +#define NETIF_F_TSO6           (SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
>=20
> v2.6.23
> +#define NETIF_F_IPV6_CSUM      16      /* Can checksum TCP/UDP over =
IPV6 */
> +#define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues =
*/
>=20
> v2.6.24
> +#define NETIF_F_NETNS_LOCAL    8192    /* Does not change network na=
mespaces */
>=20
> v2.6.27
> -#define NETIF_F_MULTI_QUEUE    16384   /* Has multiple TX/RX queues =
*/
>=20
> v2.6.29
> +#define NETIF_F_GRO            16384   /* Generic receive offload */
>=20
> (I've omitted changes that use previously unused bits.)
>=20
> If we're going to keep changing features (maybe even more often) then=
 we
> have to do something about this sysfs attribute.  Maybe get rid of it
> (as it seems not to be widely used, thankfully).  Maybe fix it to use
> the same feature values as today, but no new features.  But certainly
> don't pretend that feature flags are not exposed.
>=20
> Ben.
>=20


I have no problem with dropping or changing the sysfs feature output.
It is useful to have a way to check if device supports something. Sysfs
predates the feature support bits of ethtool. As long as ethtool suppor=
ts
it then I am fine with that.

It would be nice to have a non-grotty way of doing something like:
  if ethtool eth0 --supports gro=20
  then
       ...
  fi

