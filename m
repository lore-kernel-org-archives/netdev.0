From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bonding: enable gro by default
Date: Fri, 17 Sep 2010 21:25:07 +0200
Message-ID: <1284751507.2235.17.camel@edumazet-laptop>
References: <20100915.233851.85414928.davem@davemloft.net>
	 <1284619376.2462.95.camel@edumazet-laptop>
	 <1284624663.3352.9.camel@edumazet-laptop>
	 <20100917.115707.106807995.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>, Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56695 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220Ab0IQTZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 15:25:14 -0400
Received: by wyf22 with SMTP id 22so2713393wyf.19
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 12:25:12 -0700 (PDT)
In-Reply-To: <20100917.115707.106807995.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 11:57 -0700, David Miller a =C3=A9=
crit :

> Applied, thanks Eric.
>=20
> Can you do whatever change is needed to get it enabled by default?
>=20

Sure ;)

[PATCH] bonding: enable gro by default

gro can be enabled by default on bonding devices.

Actual support depends on the lower devices.

One can still use ethtool to switch off GRO if needed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 3b16f62..80610a6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4678,6 +4678,10 @@ static void bond_setup(struct net_device *bond_d=
ev)
 			       NETIF_F_HW_VLAN_RX |
 			       NETIF_F_HW_VLAN_FILTER);
=20
+	/* By default, we enable GRO on bonding devices.
+	 * Actual support requires lowlevel drivers are GRO ready.
+	 */
+	bond_dev->features |=3D NETIF_F_GRO;
 }
=20
 static void bond_work_cancel_all(struct bonding *bond)


