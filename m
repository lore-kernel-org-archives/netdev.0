From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 36/50] igbvf: reset netdevice addr_assign_type
	if changed from random
Date: Wed,  8 Feb 2012 22:10:43 +0100
Message-ID: <1328735457-29986-37-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Danny Kukawka <dkukawka@suse.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Reset the state of addr_assign_type to NET_ADDR_PERM as soon as
the MAC get changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index a4b20c8..af652bf 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1695,6 +1695,8 @@ static int igbvf_set_mac(struct net_device *netdev, void *p)
 		return -EADDRNOTAVAIL;
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	if (netdev->addr_assign_type & NET_ADDR_RANDOM)
+		netdev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	return 0;
 }
-- 
1.7.7.3


------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
