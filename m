From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/9] igb: Convert uses of
	__constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:22:32 -0700
Message-ID: <0eb4523c7e13dc35a6467332e22a24719f7d7041.1394644825.git.joe@perches.com>
References: <cover.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1394644825.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3384156..5476e25 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4546,7 +4546,7 @@ static int igb_tso(struct igb_ring *tx_ring,
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
 
-	if (first->protocol == __constant_htons(ETH_P_IP)) {
+	if (first->protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -4602,12 +4602,12 @@ static void igb_tx_csum(struct igb_ring *tx_ring, struct igb_tx_buffer *first)
 	} else {
 		u8 l4_hdr = 0;
 		switch (first->protocol) {
-		case __constant_htons(ETH_P_IP):
+		case htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
 			l4_hdr = ip_hdr(skb)->protocol;
 			break;
-		case __constant_htons(ETH_P_IPV6):
+		case htons(ETH_P_IPV6):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			l4_hdr = ipv6_hdr(skb)->nexthdr;
 			break;
@@ -6690,7 +6690,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 	hdr.network += ETH_HLEN;
 
 	/* handle any vlan tag if present */
-	if (protocol == __constant_htons(ETH_P_8021Q)) {
+	if (protocol == htons(ETH_P_8021Q)) {
 		if ((hdr.network - data) > (max_len - VLAN_HLEN))
 			return max_len;
 
@@ -6699,7 +6699,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 	}
 
 	/* handle L3 protocols */
-	if (protocol == __constant_htons(ETH_P_IP)) {
+	if (protocol == htons(ETH_P_IP)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct iphdr)))
 			return max_len;
 
@@ -6713,7 +6713,7 @@ static unsigned int igb_get_headlen(unsigned char *data,
 		/* record next protocol if header is present */
 		if (!(hdr.ipv4->frag_off & htons(IP_OFFSET)))
 			nexthdr = hdr.ipv4->protocol;
-	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
+	} else if (protocol == htons(ETH_P_IPV6)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
 			return max_len;
 
-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
