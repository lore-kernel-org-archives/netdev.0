From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-net-3.8 2/3] qlcnic: set gso_type
Date: Thu, 7 Feb 2013 15:13:13 +0200
Message-ID: <50a60e1293901965901edb46ae49e52da1d469d5.1360236441.git.mst@redhat.com>
References: <cover.1360236441.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, e1000-devel@lists.sourceforge.net,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <cover.1360236441.git.mst@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

qlcnic set gso_size but not gso type. This leads to crashes
in macvtap.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 6f82812..09aa310 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -986,8 +986,13 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	th->seq = htonl(seq_number);
 	length = skb->len;
 
-	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
+	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP) {
 		skb_shinfo(skb)->gso_size = qlcnic_get_lro_sts_mss(sts_data1);
+		if (skb->protocol == htons(ETH_P_IPV6))
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+		else
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	}
 
 	if (vid != 0xffff)
 		__vlan_hwaccel_put_tag(skb, vid);
-- 
MST


------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
