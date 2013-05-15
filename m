From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: allow TSO being set on bonding master
Date: Wed, 15 May 2013 16:30:13 -0700
Message-ID: <1368660613.4519.60.camel@edumazet-glaptop>
References: <1368654065.4519.53.camel@edumazet-glaptop>
	 <CAHXqBF+r3wnWY+hveYjVBNwbVYdiDF4mOj1UmbKeH3OYo6kz6Q@mail.gmail.com>
	 <1368659900.4519.57.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:56920 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab3EOXaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 19:30:15 -0400
Received: by mail-pb0-f41.google.com with SMTP id xb12so1794351pbc.0
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 16:30:15 -0700 (PDT)
In-Reply-To: <1368659900.4519.57.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 16:18 -0700, Eric Dumazet wrote:
> On Thu, 2013-05-16 at 00:55 +0200, Micha=C5=82 Miros=C5=82aw wrote:
>=20
> > Have you tried adding it to NETIF_F_ONE_FOR_ALL set? 'Team' and bri=
dge
> > could then also use it.
>=20
> Good point, I am testing this, thanks !
>=20

Hmm, this doesnt work.


# ethtool -k bond0 | grep tcp-segmentation-offload
tcp-segmentation-offload: off
# ethtool -K bond0 tso on
# ethtool -k bond0 | grep tcp-segmentation-offload
tcp-segmentation-offload: off

Do you have something different in mind ?

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 77f5202..c8d9db0 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -132,7 +132,7 @@ enum {
  * for all in netdev_increment_features.
  */
 #define NETIF_F_ONE_FOR_ALL    (NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROB=
UST | \
-                                NETIF_F_SG | NETIF_F_HIGHDMA |        =
 \
+                                NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F=
_ALL_TSO |       \
                                 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLE=
NGED)
 /*
  * If one device doesn't support one of these features, then disable i=
t
