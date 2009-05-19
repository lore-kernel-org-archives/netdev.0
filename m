From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 19 May 2009 21:44:14 +0200
Message-ID: <4A130C0E.6000507@cosmosbay.com>
References: <4A092F59.7020900@cosmosbay.com>	<4A093178.9020105@cosmosbay.com>	<4A09CD6B.5070604@cosmosbay.com> <20090518.221956.153457626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50711 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbZESToW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:44:22 -0400
In-Reply-To: <20090518.221956.153457626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 12 May 2009 21:26:35 +0200
>=20
>> [PATCH] net: release dst entry in dev_hard_start_xmit()
>  ...
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Applied, thanks Eric.
>=20
> Eric, please followup and double-check the pppoe paths
> that Jarek mentioned.  I never saw that fully resolved.
>=20

[PATCH] ppp: unset IFF_XMIT_DST_RELEASE in ppp_setup()

Jarek pointed pppoe can call back dev_queue_xmit(), and might need
skb->dst, so its safer to unset IFF_XMIT_DST_RELEASE on ppp devices.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 8ee9142..639d11b 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1054,6 +1054,7 @@ static void ppp_setup(struct net_device *dev)
 	dev->type =3D ARPHRD_PPP;
 	dev->flags =3D IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 	dev->features |=3D NETIF_F_NETNS_LOCAL;
+	dev->priv_flags &=3D ~IFF_XMIT_DST_RELEASE;
 }
=20
 /*

