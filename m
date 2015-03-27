From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 4/7] net: Introduce
	passthru_features_check
Date: Fri, 27 Mar 2015 14:31:13 +0900
Message-ID: <1427434277-27569-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

As there are a number of (especially virtual) devices that don't
need the multiple vlan check, introduce passthru_features_check() for
convenience.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/netdevice.h | 3 +++
 net/core/dev.c            | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 08c4ab3..967bb4c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3657,6 +3657,9 @@ void netdev_change_features(struct net_device *dev);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 					struct net_device *dev);
 
+netdev_features_t passthru_features_check(struct sk_buff *skb,
+					  struct net_device *dev,
+					  netdev_features_t features);
 netdev_features_t netif_skb_features(struct sk_buff *skb);
 
 static inline bool net_gso_ok(netdev_features_t features, int gso_type)
diff --git a/net/core/dev.c b/net/core/dev.c
index cb46bad..3a06003 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2562,6 +2562,14 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 	return features;
 }
 
+netdev_features_t passthru_features_check(struct sk_buff *skb,
+					  struct net_device *dev,
+					  netdev_features_t features)
+{
+	return features;
+}
+EXPORT_SYMBOL(passthru_features_check);
+
 static netdev_features_t dflt_features_check(const struct sk_buff *skb,
 					     struct net_device *dev,
 					     netdev_features_t features)
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
