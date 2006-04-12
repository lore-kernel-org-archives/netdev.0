From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv4/: possible cleanups
Date: Wed, 12 Apr 2006 22:22:25 +0200
Message-ID: <20060412202225.GD6517@stusta.de>
References: <20060404163701.GS6529@stusta.de> <20060405.222543.118196555.davem@davemloft.net> <20060406084909.GL8673@stusta.de> <20060406.133857.40478787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:20487 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932225AbWDLUW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 16:22:26 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060406.133857.40478787.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 06, 2006 at 01:38:57PM -0700, David S. Miller wrote:
> From: Adrian Bunk <bunk@stusta.de>
> Date: Thu, 6 Apr 2006 10:49:09 +0200
> 
> > On Wed, Apr 05, 2006 at 10:25:43PM -0700, David S. Miller wrote:
> > > > - remove the following unused EXPORT_SYMBO's:
> > > >   - devinet.c: devinet_ioctl
> > > 
> > > Used by wan drivers, can't remove.
> > 
> > Used only by drivers that:
> > - are marked as BROKEN since at least 2.6.0
> > - are removed in a maintainer-approved patch I sent before this one
> 
> Then get the WAN drivers removed, once they are you can remove the
> export, but until then you can't.

Done.

cu
Adrian


<--  snip  -->


This patch contains the following possible cleanups:
- make the following needlessly global function static:
  - arp.c: arp_rcv()
- remove the following unused EXPORT_SYMBOL's:
  - devinet.c: devinet_ioctl
  - fib_frontend.c: ip_rt_ioctl
  - inet_hashtables.c: inet_bind_bucket_create
  - inet_hashtables.c: inet_bind_hash
  - tcp_input.c: sysctl_tcp_abc
  - tcp_ipv4.c: sysctl_tcp_tw_reuse
  - tcp_output.c: sysctl_tcp_mtu_probing
  - tcp_output.c: sysctl_tcp_base_mss

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/arp.h          |    2 --
 net/ipv4/arp.c             |    4 ++--
 net/ipv4/devinet.c         |    1 -
 net/ipv4/fib_frontend.c    |    1 -
 net/ipv4/inet_hashtables.c |    4 ----
 net/ipv4/tcp_input.c       |    1 -
 net/ipv4/tcp_ipv4.c        |    1 -
 net/ipv4/tcp_output.c      |    3 ---
 8 files changed, 2 insertions(+), 15 deletions(-)

--- linux-2.6.16-mm2-full/include/net/arp.h.old	2006-04-04 00:17:55.000000000 +0200
+++ linux-2.6.16-mm2-full/include/net/arp.h	2006-04-04 00:18:01.000000000 +0200
@@ -10,8 +10,6 @@
 extern struct neigh_table arp_tbl;
 
 extern void	arp_init(void);
-extern int	arp_rcv(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev);
 extern int	arp_find(unsigned char *haddr, struct sk_buff *skb);
 extern int	arp_ioctl(unsigned int cmd, void __user *arg);
 extern void     arp_send(int type, int ptype, u32 dest_ip, 
--- linux-2.6.16-mm2-full/net/ipv4/arp.c.old	2006-04-04 00:18:10.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/arp.c	2006-04-04 00:18:31.000000000 +0200
@@ -928,7 +928,8 @@
  *	Receive an arp request from the device layer.
  */
 
-int arp_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct arphdr *arp;
 
@@ -1417,7 +1418,6 @@
 
 EXPORT_SYMBOL(arp_broken_ops);
 EXPORT_SYMBOL(arp_find);
-EXPORT_SYMBOL(arp_rcv);
 EXPORT_SYMBOL(arp_create);
 EXPORT_SYMBOL(arp_xmit);
 EXPORT_SYMBOL(arp_send);
--- linux-2.6.16-mm2-full/net/ipv4/devinet.c.old	2006-04-04 00:46:22.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/devinet.c	2006-04-04 00:46:31.000000000 +0200
@@ -1556,7 +1556,6 @@
 #endif
 }
 
-EXPORT_SYMBOL(devinet_ioctl);
 EXPORT_SYMBOL(in_dev_finish_destroy);
 EXPORT_SYMBOL(inet_select_addr);
 EXPORT_SYMBOL(inetdev_by_index);
--- linux-2.6.16-mm2-full/net/ipv4/fib_frontend.c.old	2006-04-04 00:46:57.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/fib_frontend.c	2006-04-04 00:47:05.000000000 +0200
@@ -667,4 +667,3 @@
 
 EXPORT_SYMBOL(inet_addr_type);
 EXPORT_SYMBOL(ip_dev_find);
-EXPORT_SYMBOL(ip_rt_ioctl);
--- linux-2.6.16-mm2-full/net/ipv4/inet_hashtables.c.old	2006-04-04 00:48:35.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/inet_hashtables.c	2006-04-04 00:49:43.000000000 +0200
@@ -43,8 +43,6 @@
 	return tb;
 }
 
-EXPORT_SYMBOL(inet_bind_bucket_create);
-
 /*
  * Caller must hold hashbucket lock for this tb with local BH disabled
  */
@@ -64,8 +62,6 @@
 	inet_csk(sk)->icsk_bind_hash = tb;
 }
 
-EXPORT_SYMBOL(inet_bind_hash);
-
 /*
  * Get rid of any references to a local port held by the given sock.
  */
--- linux-2.6.16-mm2-full/net/ipv4/tcp_input.c.old	2006-04-04 00:50:56.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/tcp_input.c	2006-04-04 00:51:03.000000000 +0200
@@ -4559,7 +4559,6 @@
 
 EXPORT_SYMBOL(sysctl_tcp_ecn);
 EXPORT_SYMBOL(sysctl_tcp_reordering);
-EXPORT_SYMBOL(sysctl_tcp_abc);
 EXPORT_SYMBOL(tcp_parse_options);
 EXPORT_SYMBOL(tcp_rcv_established);
 EXPORT_SYMBOL(tcp_rcv_state_process);
--- linux-2.6.16-mm2-full/net/ipv4/tcp_ipv4.c.old	2006-04-04 00:51:38.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/tcp_ipv4.c	2006-04-04 00:51:46.000000000 +0200
@@ -1858,5 +1858,4 @@
 #endif
 EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
-EXPORT_SYMBOL(sysctl_tcp_tw_reuse);
 
--- linux-2.6.16-mm2-full/net/ipv4/tcp_output.c.old	2006-04-04 00:52:13.000000000 +0200
+++ linux-2.6.16-mm2-full/net/ipv4/tcp_output.c	2006-04-04 00:52:32.000000000 +0200
@@ -59,9 +59,6 @@
 int sysctl_tcp_mtu_probing = 0;
 int sysctl_tcp_base_mss = 512;
 
-EXPORT_SYMBOL(sysctl_tcp_mtu_probing);
-EXPORT_SYMBOL(sysctl_tcp_base_mss);
-
 static void update_send_head(struct sock *sk, struct tcp_sock *tp,
 			     struct sk_buff *skb)
 {

