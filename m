From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] ipv6 -- more 0 vs NULL
Date: Tue, 13 Jul 2004 11:25:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713112515.51665b9b@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        "David S.
 Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More sparse complaints about 0 vs. NULL

diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	2004-07-13 11:22:18 -07:00
+++ b/net/ipv6/ip6_output.c	2004-07-13 11:22:18 -07:00
@@ -561,7 +561,7 @@
 		err = 0;
 		offset = 0;
 		frag = skb_shinfo(skb)->frag_list;
-		skb_shinfo(skb)->frag_list = 0;
+		skb_shinfo(skb)->frag_list = NULL;
 		/* BUILD HEADER */
 
 		tmp_hdr = kmalloc(hlen, GFP_ATOMIC);
@@ -789,7 +789,7 @@
 		err = ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
 
 		if (err) {
-#if IP6_DEBUG >= 2
+#if defined(IP6_DEBUG) && IP6_DEBUG >= 2
 			printk(KERN_DEBUG "ip6_dst_lookup: "
 			       "no available source address\n");
 #endif
diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-07-13 11:22:18 -07:00
+++ b/net/ipv6/mcast.c	2004-07-13 11:22:18 -07:00
@@ -210,7 +210,7 @@
 
 	mc_lst->ifindex = dev->ifindex;
 	mc_lst->sfmode = MCAST_EXCLUDE;
-	mc_lst->sflist = 0;
+	mc_lst->sflist = NULL;
 
 	/*
 	 *	now add/increase the group membership on the device
@@ -272,8 +272,8 @@
 
 struct inet6_dev *ip6_mc_find_dev(struct in6_addr *group, int ifindex)
 {
-	struct net_device *dev = 0;
-	struct inet6_dev *idev = 0;
+	struct net_device *dev = NULL;
+	struct inet6_dev *idev = NULL;
 
 	if (ifindex == 0) {
 		struct rt6_info *rt;
@@ -288,18 +288,18 @@
 		dev = dev_get_by_index(ifindex);
 
 	if (!dev)
-		return 0;
+		return NULL;
 	idev = in6_dev_get(dev);
 	if (!idev) {
 		dev_put(dev);
-		return 0;
+		return NULL;
 	}
 	read_lock_bh(&idev->lock);
 	if (idev->dead) {
 		read_unlock_bh(&idev->lock);
 		in6_dev_put(idev);
 		dev_put(dev);
-		return 0;
+		return NULL;
 	}
 	return idev;
 }
