From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Sat, 20 Sep 2003 13:32:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309201332.13167.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <200309172317.38348.bdschuym@pandora.be> <20030918194802.6726d53c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, hno@marasystems.com, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030918194802.6726d53c.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 19 September 2003 04:48, David S. Miller wrote:
> Don't use an alignment attribute, just put the member of
> the struct at the very beginning and use "unsigned int"
> at a time op+comparisons.
>
> How about that?

Fine with me.

cheers,
Bart


--- linux-2.6.0-test5/include/linux/netfilter_ipv4/ipt_physdev.h.old	2003-09-20 13:28:26.000000000 +0200
+++ linux-2.6.0-test5/include/linux/netfilter_ipv4/ipt_physdev.h	2003-09-20 13:29:06.000000000 +0200
@@ -13,12 +13,12 @@
 #define IPT_PHYSDEV_OP_MASK		(0x20 - 1)
 
 struct ipt_physdev_info {
-	u_int8_t invert;
-	u_int8_t bitmask;
 	char physindev[IFNAMSIZ];
 	char in_mask[IFNAMSIZ];
 	char physoutdev[IFNAMSIZ];
 	char out_mask[IFNAMSIZ];
+	u_int8_t invert;
+	u_int8_t bitmask;
 };
 
 #endif /*_IPT_PHYSDEV_H*/
--- linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c.old	2003-09-20 13:28:44.000000000 +0200
+++ linux-2.6.0-test5/net/ipv4/netfilter/ipt_physdev.c	2003-09-20 13:29:06.000000000 +0200
@@ -23,7 +23,7 @@ match(const struct sk_buff *skb,
 	int i;
 	static const char nulldevname[IFNAMSIZ];
 	const struct ipt_physdev_info *info = matchinfo;
-	unsigned long ret;
+	unsigned int ret;
 	const char *indev, *outdev;
 	struct nf_bridge_info *nf_bridge;
 
@@ -65,10 +65,10 @@ match(const struct sk_buff *skb,
 	if (!(info->bitmask & IPT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)info->physindev)[i])
-			& ((const unsigned long *)info->in_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |= (((const unsigned int *)indev)[i]
+			^ ((const unsigned int *)info->physindev)[i])
+			& ((const unsigned int *)info->in_mask)[i];
 	}
 
 	if ((ret == 0) ^ !(info->invert & IPT_PHYSDEV_OP_IN))
@@ -79,10 +79,10 @@ match_outdev:
 		return MATCH;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)info->physoutdev)[i])
-			& ((const unsigned long *)info->out_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned int); i++) {
+		ret |= (((const unsigned int *)outdev)[i]
+			^ ((const unsigned int *)info->physoutdev)[i])
+			& ((const unsigned int *)info->out_mask)[i];
 	}
 
 	return (ret != 0) ^ !(info->invert & IPT_PHYSDEV_OP_OUT);
