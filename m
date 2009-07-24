From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bnx2x: Dont update vlan_features in bnx2x_set_tso()
Date: Fri, 24 Jul 2009 09:21:19 +0200
Message-ID: <4A6960EF.5020204@gmail.com>
References: <4A681029.4070600@voltaire.com> <4A681F63.7060001@gmail.com> <4A685122.3090300@gmail.com> <20090723.105932.249439810.davem@davemloft.net> <1248394379.13301.2.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"ogerlitz@voltaire.com" <ogerlitz@voltaire.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48214 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbZGXHVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 03:21:31 -0400
In-Reply-To: <1248394379.13301.2.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan a =E9crit :
> On Thu, 2009-07-23 at 10:59 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 23 Jul 2009 14:01:38 +0200
>>
>>> [PATCH net-next-2.6] bnx2: Update vlan_features
>>>
>>> In order to get full use of some advanced features of BNX2, we now =
need to
>>> fill dev->vlan_features.
>>>
>>> Patch successfully tested with vlan devices built on top of bonding=
=2E
>>> (bond0 : one bnx2 slave, one tg3 slave (not yet vlan_features enabl=
ed)
>>>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Can I get some Broadcom ACKs for this?
>>
> I've reviewed and tested Eric's 2nd patch.  Thanks.
>=20
> Acked-by: Michael Chan <mchan@broadcom.com>

Thanks

Based on Patrick feedback, I believe we can add this followup too

[PATCH net-next-2.6] bnx2x: Dont update vlan_features in bnx2x_set_tso(=
)

Patrick said : "vlan_features doesn't need to be updated, the resulting
dev->features of the VLAN device is computed as the intersection of
dev->features and dev->vlan_features."

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c4c42b3..a2de0cd 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -9349,17 +9349,9 @@ static int bnx2x_set_tso(struct net_device *dev,=
 u32 data)
 	if (data) {
 		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
 		dev->features |=3D NETIF_F_TSO6;
-#ifdef BCM_VLAN
-		dev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->vlan_features |=3D NETIF_F_TSO6;
-#endif
 	} else {
 		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
 		dev->features &=3D ~NETIF_F_TSO6;
-#ifdef BCM_VLAN
-		dev->vlan_features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->vlan_features &=3D ~NETIF_F_TSO6;
-#endif
 	}
=20
 	return 0;
