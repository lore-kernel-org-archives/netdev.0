From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH 2/2][BRIDGE] convert __constant_htons(constant) to htons
Date: Tue, 05 Oct 2004 19:08:45 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41631B6D.5050503@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050708090507050204020000"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050708090507050204020000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

	Please consider pulling from:

bk://kernel.bkbits.net/acme/sk_buff-2.6

	Now there are just these two changesets in this tree, will
wait for you to pull to submit the next set.

- Arnaldo

--------------050708090507050204020000
Content-Type: text/plain;
 name="bridge_htons.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bridge_htons.patch"

===================================================================


ChangeSet@1.2054, 2004-10-05 19:01:58-03:00, acme@conectiva.com.br
  [BRIDGE] convert __constant_htons(constant) to htons
  
  Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  Signed-off-by: David S. Miller <davem@redhat.com>


 ebt_arp.c      |    4 ++--
 ebt_arpreply.c |    6 +++---
 ebt_ip.c       |    2 +-
 ebt_log.c      |    2 +-
 ebt_vlan.c     |    2 +-
 5 files changed, 8 insertions(+), 8 deletions(-)


diff -Nru a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
--- a/net/bridge/netfilter/ebt_arp.c	2004-10-05 19:02:40 -03:00
+++ b/net/bridge/netfilter/ebt_arp.c	2004-10-05 19:02:40 -03:00
@@ -108,8 +108,8 @@
 
 	if (datalen != EBT_ALIGN(sizeof(struct ebt_arp_info)))
 		return -EINVAL;
-	if ((e->ethproto != __constant_htons(ETH_P_ARP) &&
-	   e->ethproto != __constant_htons(ETH_P_RARP)) ||
+	if ((e->ethproto != htons(ETH_P_ARP) &&
+	   e->ethproto != htons(ETH_P_RARP)) ||
 	   e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	if (info->bitmask & ~EBT_ARP_MASK || info->invflags & ~EBT_ARP_MASK)
diff -Nru a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
--- a/net/bridge/netfilter/ebt_arpreply.c	2004-10-05 19:02:40 -03:00
+++ b/net/bridge/netfilter/ebt_arpreply.c	2004-10-05 19:02:40 -03:00
@@ -29,9 +29,9 @@
 	if (ap == NULL)
 		return EBT_DROP;
 
-	if (ap->ar_op != __constant_htons(ARPOP_REQUEST) ||
+	if (ap->ar_op != htons(ARPOP_REQUEST) ||
 	    ap->ar_hln != ETH_ALEN ||
-	    ap->ar_pro != __constant_htons(ETH_P_IP) ||
+	    ap->ar_pro != htons(ETH_P_IP) ||
 	    ap->ar_pln != 4)
 		return EBT_CONTINUE;
 
@@ -65,7 +65,7 @@
 		return -EINVAL;
 	if (BASE_CHAIN && info->target == EBT_RETURN)
 		return -EINVAL;
-	if (e->ethproto != __constant_htons(ETH_P_ARP) ||
+	if (e->ethproto != htons(ETH_P_ARP) ||
 	    e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	CLEAR_BASE_CHAIN_BIT;
diff -Nru a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
--- a/net/bridge/netfilter/ebt_ip.c	2004-10-05 19:02:40 -03:00
+++ b/net/bridge/netfilter/ebt_ip.c	2004-10-05 19:02:40 -03:00
@@ -80,7 +80,7 @@
 
 	if (datalen != EBT_ALIGN(sizeof(struct ebt_ip_info)))
 		return -EINVAL;
-	if (e->ethproto != __constant_htons(ETH_P_IP) ||
+	if (e->ethproto != htons(ETH_P_IP) ||
 	   e->invflags & EBT_IPROTO)
 		return -EINVAL;
 	if (info->bitmask & ~EBT_IP_MASK || info->invflags & ~EBT_IP_MASK)
diff -Nru a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
--- a/net/bridge/netfilter/ebt_log.c	2004-10-05 19:02:40 -03:00
+++ b/net/bridge/netfilter/ebt_log.c	2004-10-05 19:02:40 -03:00
@@ -121,7 +121,7 @@
 
 		/* If it's for Ethernet and the lengths are OK,
 		 * then log the ARP payload */
-		if (ah->ar_hrd == __constant_htons(1) &&
+		if (ah->ar_hrd == htons(1) &&
 		    ah->ar_hln == ETH_ALEN &&
 		    ah->ar_pln == sizeof(uint32_t)) {
 			struct arppayload _arpp, *ap;
diff -Nru a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
--- a/net/bridge/netfilter/ebt_vlan.c	2004-10-05 19:02:40 -03:00
+++ b/net/bridge/netfilter/ebt_vlan.c	2004-10-05 19:02:40 -03:00
@@ -104,7 +104,7 @@
 	}
 
 	/* Is it 802.1Q frame checked? */
-	if (e->ethproto != __constant_htons(ETH_P_8021Q)) {
+	if (e->ethproto != htons(ETH_P_8021Q)) {
 		DEBUG_MSG
 		    ("passed entry proto %2.4X is not 802.1Q (8100)\n",
 		     (unsigned short) ntohs(e->ethproto));


--------------050708090507050204020000--
