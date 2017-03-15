From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2] net: sun: sungem: rix a possible null dereference
Date: Wed, 15 Mar 2017 22:51:13 +0100
Message-ID: <1489614673-12595-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function gem_begin_auto_negotiation dereference
the pointer ep before testing if it's null. This
patch add a check on ep before dereferencing it.

Fixes: 92552fdd557 ("net: sun: sungem: use new api
ethtool_{get|set}_link_ksettings")

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Chanelog:
v2:
- use Fixes tag (thanks Sergei Shtylyov)

 drivers/net/ethernet/sun/sungem.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index dbfca04..fa607d0 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1259,8 +1259,9 @@ static void gem_begin_auto_negotiation(struct gem *gp,
 	int duplex;
 	u32 advertising;
 
-	ethtool_convert_link_mode_to_legacy_u32(&advertising,
-						ep->link_modes.advertising);
+	if (ep)
+		ethtool_convert_link_mode_to_legacy_u32(
+			&advertising, ep->link_modes.advertising);
 
 	if (gp->phy_type != phy_mii_mdio0 &&
      	    gp->phy_type != phy_mii_mdio1)
-- 
1.7.4.4
