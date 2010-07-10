From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] net: Get rid of rtnl_link_stats64 /
 net_device_stats union
Date: Fri, 09 Jul 2010 18:01:52 -0700 (PDT)
Message-ID: <20100709.180152.183047856.davem@davemloft.net>
References: <1278702713.2078.13.camel@achroite.uk.solarflarecom.com>
	<1278709734.2538.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750810Ab0GJBBl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jul 2010 21:01:41 -0400
In-Reply-To: <1278709734.2538.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Jul 2010 23:08:54 +0200

> Le vendredi 09 juillet 2010 =E0 20:11 +0100, Ben Hutchings a =E9crit =
:
>> In commit be1f3c2c027cc5ad735df6a45a542ed1db7ec48b "net: Enable 64-b=
it
>> net device statistics on 32-bit architectures" I redefined struct
>> net_device_stats so that it could be used in a union with struct
>> rtnl_link_stats64, avoiding the need for explicit copying or
>> conversion between the two.  However, this is unsafe because there i=
s
>> no locking required and no lock consistently held around calls to
>> dev_get_stats() and use of the statistics structure it returns.
>>=20
>> In commit 28172739f0a276eb8d6ca917b3974c2edb036da3 "net: fix 64 bit
>> counters on 32 bit arches" Eric Dumazet dealt with that problem by
>> requiring callers of dev_get_stats() to provide storage for the
>> result.  This means that the net_device::stats64 field and the paddi=
ng
>> in struct net_device_stats are now redundant, so remove them.
>>=20
>> Update the comment on net_device_ops::ndo_get_stats64 to reflect its
>> new usage.
>>=20
>> Change dev_txq_stats_fold() to use struct rtnl_link_stats64, since
>> that is what all its callers are really using and it is no longer
>> going to be compatible with struct net_device_stats.
>>=20
>> Eric Dumazet suggested the separate function for the structure
>> conversion.
>>=20
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
