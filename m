From: Sebastian.Poehn@Belden.com
Subject: [PATCH 2/3] RFC gianfar: add rx_ntuple feature
Date: Tue, 10 May 2011 08:54:28 -0400
Message-ID: <OF57143EF9.D6B06D40-ON8525788C.0046E788-8525788C.0046E78E@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.belden.com ([12.161.118.91]:47594 "EHLO mx2.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169Ab1EJNJg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 09:09:36 -0400
In-Reply-To: 
References: 
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This part sets the flags for ethtool and does primary hardware checking=
=2E

--- gianfar.c.orig=A0=A0=A0 2011-05-10 11:08:13.573744000 +0200
+++ gianfar.c=A0=A0=A0 2011-05-10 11:22:07.865744495 +0200
@@ -751,7 +751,8 @@ static int gfar_of_init(struct platform_
=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_VLAN |
=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
=A0=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
-=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_TIMER;
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_TIMER |
+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 FSL_GIANFAR_DEV_HAS_RX_FILER;
=A0
=A0=A0=A0=A0 ctype =3D of_get_property(np, "phy-connection-type", NULL)=
;
=A0
@@ -1042,6 +1043,9 @@ static int gfar_probe(struct platform_de
=A0=A0=A0=A0 if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
=A0=A0=A0=A0 =A0=A0=A0 dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_=
HW_VLAN_RX;
=A0
+=A0=A0=A0 if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RX_FILER)
+=A0=A0=A0 =A0=A0=A0 dev->features |=3D NETIF_F_NTUPLE;
+
=A0=A0=A0=A0 if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH=
) {
=A0=A0=A0=A0 =A0=A0=A0 priv->extended_hash =3D 1;
=A0=A0=A0=A0 =A0=A0=A0 priv->hash_width =3D 9;
@@ -1151,9 +1155,8 @@ static int gfar_probe(struct platform_de
=A0=A0=A0=A0 =A0=A0=A0 priv->rx_queue[i]->rxic =3D DEFAULT_RXIC;
=A0=A0=A0=A0 }
=A0
-=A0=A0=A0 /* enable filer if using multiple RX queues*/
-=A0=A0=A0 if(priv->num_rx_queues > 1)
-=A0=A0=A0 =A0=A0=A0 priv->rx_filer_enable =3D 1;
+=A0=A0=A0 /* always enable rx filer*/
+=A0=A0=A0 priv->rx_filer_enable =3D 1;
=A0=A0=A0=A0 /* Enable most messages by default */
=A0=A0=A0=A0 priv->msg_enable =3D (NETIF_MSG_IFUP << 1 ) - 1;
=A0
Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

