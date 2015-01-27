From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v1 07/18] net: bonding: use __ethtool_get_ksettings
Date: Mon, 26 Jan 2015 17:36:03 -0800
Message-ID: <1422322574-6188-8-git-send-email-ddecotig@gmail.com>
References: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Eyal Perry <eyalpe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422322574-6188-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 drivers/net/bonding/bond_main.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f47bc43..7710386 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -371,22 +371,20 @@ down:
 static void bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
-	struct ethtool_cmd ecmd;
-	u32 slave_speed;
+	struct ethtool_ksettings ecmd;
 	int res;
 
 	slave->speed = SPEED_UNKNOWN;
 	slave->duplex = DUPLEX_UNKNOWN;
 
-	res = __ethtool_get_settings(slave_dev, &ecmd);
+	res = __ethtool_get_ksettings(slave_dev, &ecmd);
 	if (res < 0)
 		return;
 
-	slave_speed = ethtool_cmd_speed(&ecmd);
-	if (slave_speed == 0 || slave_speed == ((__u32) -1))
+	if (ecmd.parent.speed == 0 || ecmd.parent.speed == ((__u32) -1))
 		return;
 
-	switch (ecmd.duplex) {
+	switch (ecmd.parent.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
@@ -394,8 +392,8 @@ static void bond_update_speed_duplex(struct slave *slave)
 		return;
 	}
 
-	slave->speed = slave_speed;
-	slave->duplex = ecmd.duplex;
+	slave->speed = ecmd.parent.speed;
+	slave->duplex = ecmd.parent.duplex;
 
 	return;
 }
-- 
2.2.0.rc0.207.ga3a616c
