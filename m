From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netxen: fix a race in netxen_nic_get_stats()
Date: Wed, 18 Aug 2010 14:29:30 +0200
Message-ID: <1282134570.2194.53.camel@edumazet-laptop>
References: <1282128168.2194.49.camel@edumazet-laptop>
	 <99737F4847ED0A48AECC9F4A1974A4B80F86E69124@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48152 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab0HRM3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 08:29:34 -0400
Received: by wyb32 with SMTP id 32so726667wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 05:29:33 -0700 (PDT)
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F86E69124@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 05:47 -0500, Amit Salecha a =C3=A9=
crit :
> Same fix will be require for netxen_nic.

Indeed, here is netxen part

Thanks

[PATCH] netxen: fix a race in netxen_nic_get_stats()

Dont clear netdev->stats, it might give transient wrong values to
concurrent stat readers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index fd86e18..cb30df1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2032,8 +2032,6 @@ struct net_device_stats *netxen_nic_get_stats(str=
uct net_device *netdev)
 	struct netxen_adapter *adapter =3D netdev_priv(netdev);
 	struct net_device_stats *stats =3D &netdev->stats;
=20
-	memset(stats, 0, sizeof(*stats));
-
 	stats->rx_packets =3D adapter->stats.rx_pkts + adapter->stats.lro_pkt=
s;
 	stats->tx_packets =3D adapter->stats.xmitfinished;
 	stats->rx_bytes =3D adapter->stats.rxbytes;


