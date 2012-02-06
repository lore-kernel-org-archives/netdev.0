From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Mon, 06 Feb 2012 12:31:34 +0100
Message-ID: <4F2FBA16.8010400@profihost.ag>
References: <20120201.162157.880976652659067010.davem@davemloft.net>			 <4F2A87B0.6070900@profihost.ag>			 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>			 <20120202.143957.2251106530056768980.davem@davemloft.net>			 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>		 <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>	 <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>	 <4F2F971B.9090503@profihost.ag> <1328519818.2220.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040501020709090801010806"
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:50810 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab2BFLbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 06:31:38 -0500
In-Reply-To: <1328519818.2220.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040501020709090801010806
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Greg, Hi Eric,

>> how to get an allyesconfig? Or just doing something like:
>> rm -f .config; /usr/bin/yes | make oldconfig
>
> Save your .config, since next step will destroy it :
>
> make allyesconfig
>
> Then build :
>
> make   $your_favorite_build_options

here is the missing patch attached to have a fine build with
allyesconfig.allyesconfig

Stefan

--------------040501020709090801010806
Content-Type: text/x-patch;
 name="0001-missing-fixes-for-0002-net-Abstract-dst-neighbour-ac.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-missing-fixes-for-0002-net-Abstract-dst-neighbour-ac.pa";
 filename*1="tch"

>From fdfbdcc7c4698225e7d185f65f3fc176cc22116f Mon Sep 17 00:00:00 2001
From: Stefan Priebe <s.priebe@profihost.ag>
Date: Mon, 6 Feb 2012 12:26:03 +0100
Subject: [PATCH] - missing fixes for 0002-net-Abstract-dst-neighbour-accesses-behind-helpers.patch

---
 net/decnet/dn_neigh.c |    6 +++---
 net/decnet/dn_route.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 2a90341..9810610 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -227,7 +227,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 static int dn_long_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_long_packet) + 3;
 	unsigned char *data;
@@ -274,7 +274,7 @@ static int dn_long_output(struct sk_buff *skb)
 static int dn_short_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
 	struct dn_short_packet *sp;
@@ -318,7 +318,7 @@ static int dn_short_output(struct sk_buff *skb)
 static int dn_phase3_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
 	struct dn_short_packet *sp;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index df69e92..4bb1456 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -754,7 +754,7 @@ static int dn_forward(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_dev *dn_db = rcu_dereference(dst->dev->dn_ptr);
 	struct dn_route *rt;
-	struct neighbour *neigh = dst->neighbour;
+	struct neighbour *neigh = dst_get_neighbour(dst);
 	int header_len;
 #ifdef CONFIG_NETFILTER
 	struct net_device *dev = skb->dev;
-- 
1.7.1


--------------040501020709090801010806--
