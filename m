From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] net/8021q/vlan_dev.c - Use print_mac
Date: Fri, 15 Feb 2008 09:42:50 -0800
Message-ID: <1203097370.21308.18.camel@localhost>
References: <20080215104804.9870.15722.stgit@one>
	 <20080215.025855.202184003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080215.025855.202184003.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-02-15 at 02:58 -0800, David Miller wrote:
> From: Bruno Randolf <bruno-L9ZBdB2wSWtl57MIdRCFDg@public.gmane.org>
> Date: Fri, 15 Feb 2008 19:48:05 +0900
> > is there any chance to include a macro like this for printing mac
> addresses?
> > its advantage is that it can be used without the need to declare
> buffers for
> > print_mac(), for example:
> We specifically removed this sort of thing, please don't
> add it back.

Remove direct use of MAC_FMT

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 77f04e4..839c70e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -366,7 +366,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
-
+	DECLARE_MAC_BUF(mac);
+	DECLARE_MAC_BUF(mac2);
 	/* Handle non-VLAN frames if they are sent to us, for example by DHCP.
 	 *
 	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
@@ -404,11 +405,8 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	pr_debug("%s: about to send skb: %p to dev: %s\n",
 		__FUNCTION__, skb, skb->dev->name);
-	pr_debug("  " MAC_FMT " " MAC_FMT " %4hx %4hx %4hx\n",
-		 veth->h_dest[0], veth->h_dest[1], veth->h_dest[2],
-		 veth->h_dest[3], veth->h_dest[4], veth->h_dest[5],
-		 veth->h_source[0], veth->h_source[1], veth->h_source[2],
-		 veth->h_source[3], veth->h_source[4], veth->h_source[5],
+	pr_debug("  %s %s %4hx %4hx %4hx\n",
+		 print_mac(mac, veth->h_dest), print_mac(mac2, veth->h_source),
 		 veth->h_vlan_proto, veth->h_vlan_TCI,
 		 veth->h_vlan_encapsulated_proto);
 
