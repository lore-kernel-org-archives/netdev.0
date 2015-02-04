From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v2 13/17] net: bridge: use __ethtool_get_ksettings
Date: Wed,  4 Feb 2015 11:53:37 -0800
Message-ID: <1423079621-1374-14-git-send-email-ddecotig@gmail.com>
References: <1423079621-1374-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Upinder Malhi <umalhi@cisco.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:59621 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161642AbbBDTyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 14:54:21 -0500
In-Reply-To: <1423079621-1374-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/bridge/br_if.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index b087d27..57282a5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -35,10 +35,10 @@
  */
 static int port_cost(struct net_device *dev)
 {
-	struct ethtool_cmd ecmd;
+	struct ethtool_ksettings ecmd;
 
-	if (!__ethtool_get_settings(dev, &ecmd)) {
-		switch (ethtool_cmd_speed(&ecmd)) {
+	if (!__ethtool_get_ksettings(dev, &ecmd)) {
+		switch (ecmd.parent.speed) {
 		case SPEED_10000:
 			return 2;
 		case SPEED_1000:
-- 
2.2.0.rc0.207.ga3a616c
