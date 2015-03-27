From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 1/7] vlan: Add features for
	stacked vlan device
Date: Fri, 27 Mar 2015 14:31:10 +0900
Message-ID: <1427434277-27569-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1427434277-27569-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>, Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Linux NICS <linux.nics@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1427434277-27569-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Stacked vlan devices curretly have few features (GRO, HIGHDMA, LLTX).
Since we have software fallbacks in case the NIC can not handle some
features for multiple vlans, we can add the same features as the lower
vlan devices for stacked vlan devices.

This allows stacked vlan devices to create large (GSO) packets and not to
segment packets. Those packets will be segmented by software on the real
device, or even can be segmented by the NIC once TSO for multiple vlans
becomes enabled by the following patches.

The exception is those related to FCoE, which does not have a software
fallback.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/8021q/vlan_dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f196552..8b5ab90 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -554,6 +554,7 @@ static int vlan_dev_init(struct net_device *dev)
 	if (dev->features & NETIF_F_VLAN_FEATURES)
 		netdev_warn(real_dev, "VLAN features are set incorrectly.  Q-in-Q configurations may not work correctly.\n");
 
+	dev->vlan_features = real_dev->vlan_features & ~NETIF_F_ALL_FCOE;
 
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
-- 
1.8.1.2



------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
