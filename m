From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCHES] modules: convert several net proto families
Date: Mon, 28 Apr 2003 12:06:30 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030428150629.GC19677@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	This one converts several net proto families to the new module
infrastructure. I slipped by mistake a simple cleanup in net/core/dev.c,
sorry, but it is trivial.

- Arnaldo

===================================================================

ChangeSet@1.1141, 2003-04-28 11:13:08-03:00, acme@conectiva.com.br
  o rose/rose_dev: use SET_MODULE_OWNER, removing calls to MOD_{INC,DEC}_USE_COUNT

ChangeSet@1.1140, 2003-04-28 11:11:54-03:00, acme@conectiva.com.br
  o netrom/nr_dev: use SET_MODULE_OWNER, removing calls to MOD_{INC,DEC}_USE_COUNT

ChangeSet@1.1139, 2003-04-28 11:10:11-03:00, acme@conectiva.com.br
  o af_x25: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1138, 2003-04-28 11:07:45-03:00, acme@conectiva.com.br
  o af_wanpipe: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1137, 2003-04-28 11:05:15-03:00, acme@conectiva.com.br
  o af_rose: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1136, 2003-04-28 11:01:16-03:00, acme@conectiva.com.br
  o af_packet: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1135, 2003-04-28 10:58:48-03:00, acme@conectiva.com.br
  o af_netrom: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1134, 2003-04-28 10:55:26-03:00, acme@conectiva.com.br
  o af_key: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1133, 2003-04-28 10:46:43-03:00, acme@conectiva.com.br
  o af_irda: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1132, 2003-04-28 10:39:41-03:00, acme@conectiva.com.br
  o af_econet: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

ChangeSet@1.1131, 2003-04-28 10:37:20-03:00, acme@conectiva.com.br
  o af_ax25: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.

 ax25/af_ax25.c         |    5 +----
 core/dev.c             |    2 +-
 econet/af_econet.c     |    5 +----
 irda/af_irda.c         |    7 +------
 key/af_key.c           |    7 +------
 netrom/af_netrom.c     |   29 ++++++++++-------------------
 netrom/nr_dev.c        |    3 +--
 packet/af_packet.c     |    4 +---
 rose/af_rose.c         |   28 ++++++++++------------------
 rose/rose_dev.c        |    3 +--
 wanrouter/af_wanpipe.c |    9 +--------
 x25/af_x25.c           |   15 +++++----------
 12 files changed, 34 insertions(+), 83 deletions(-)


diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Mon Apr 28 11:43:49 2003
+++ b/net/ax25/af_ax25.c	Mon Apr 28 11:43:49 2003
@@ -68,8 +68,6 @@
 	}
 
 	kfree(ax25);
-
-	MOD_DEC_USE_COUNT;
 }
 
 static void ax25_free_sock(struct sock *sk)
@@ -507,8 +505,6 @@
 	if ((ax25 = kmalloc(sizeof(*ax25), GFP_ATOMIC)) == NULL)
 		return NULL;
 
-	MOD_INC_USE_COUNT;
-
 	memset(ax25, 0x00, sizeof(*ax25));
 
 	skb_queue_head_init(&ax25->write_queue);
@@ -1912,6 +1908,7 @@
 static struct net_proto_family ax25_family_ops = {
 	.family =	PF_AX25,
 	.create =	ax25_create,
+	.owner	=	THIS_MODULE,
 };
 
 static struct proto_ops ax25_proto_ops = {
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Mon Apr 28 11:43:49 2003
+++ b/net/core/dev.c	Mon Apr 28 11:43:49 2003
@@ -1434,7 +1434,7 @@
 }
 
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
-int (*br_handle_frame_hook)(struct sk_buff *skb) = NULL;
+int (*br_handle_frame_hook)(struct sk_buff *skb);
 
 static __inline__ int handle_bridge(struct sk_buff *skb,
 				     struct packet_type *pt_prev)
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Mon Apr 28 11:43:49 2003
+++ b/net/econet/af_econet.c	Mon Apr 28 11:43:49 2003
@@ -502,7 +502,6 @@
 
 	if (!atomic_read(&sk->wmem_alloc) && !atomic_read(&sk->rmem_alloc)) {
 		sk_free(sk);
-		MOD_DEC_USE_COUNT;
 		return;
 	}
 
@@ -547,7 +546,6 @@
 	}
 
 	sk_free(sk);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -566,7 +564,6 @@
 		return -ESOCKTNOSUPPORT;
 
 	sock->state = SS_UNCONNECTED;
-	MOD_INC_USE_COUNT;
 
 	err = -ENOBUFS;
 	sk = sk_alloc(PF_ECONET, GFP_KERNEL, 1, NULL);
@@ -591,7 +588,6 @@
 out_free:
 	sk_free(sk);
 out:
-	MOD_DEC_USE_COUNT;
 	return err;
 }
 
@@ -693,6 +689,7 @@
 static struct net_proto_family econet_family_ops = {
 	.family =	PF_ECONET,
 	.create =	econet_create,
+	.owner	=	THIS_MODULE,
 };
 
 static struct proto_ops SOCKOPS_WRAPPED(econet_ops) = {
diff -Nru a/net/irda/af_irda.c b/net/irda/af_irda.c
--- a/net/irda/af_irda.c	Mon Apr 28 11:43:49 2003
+++ b/net/irda/af_irda.c	Mon Apr 28 11:43:49 2003
@@ -1132,9 +1132,6 @@
 	self->nslots = DISCOVERY_DEFAULT_SLOTS;
 	self->daddr = DEV_ADDR_ANY;	/* Until we get connected */
 	self->saddr = 0x0;		/* so IrLMP assign us any link */
-
-	MOD_INC_USE_COUNT;
-
 	return 0;
 }
 
@@ -1177,9 +1174,6 @@
 	}
 #endif /* CONFIG_IRDA_ULTRA */
 	kfree(self);
-	MOD_DEC_USE_COUNT;
-
-	return;
 }
 
 /*
@@ -2409,6 +2403,7 @@
 static struct net_proto_family irda_family_ops = {
 	.family = PF_IRDA,
 	.create = irda_create,
+	.owner	= THIS_MODULE,
 };
 
 static struct proto_ops SOCKOPS_WRAPPED(irda_stream_ops) = {
diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	Mon Apr 28 11:43:49 2003
+++ b/net/key/af_key.c	Mon Apr 28 11:43:49 2003
@@ -63,8 +63,6 @@
 	kfree(pfkey_sk(sk));
 
 	atomic_dec(&pfkey_socks_nr);
-
-	MOD_DEC_USE_COUNT;
 }
 
 static void pfkey_table_grab(void)
@@ -150,8 +148,6 @@
 	if (protocol != PF_KEY_V2)
 		return -EPROTONOSUPPORT;
 
-	MOD_INC_USE_COUNT;
-
 	err = -ENOMEM;
 	sk = sk_alloc(PF_KEY, GFP_KERNEL, 1, NULL);
 	if (sk == NULL)
@@ -176,9 +172,7 @@
 	pfkey_insert(sk);
 
 	return 0;
-
 out:
-	MOD_DEC_USE_COUNT;
 	return err;
 }
 
@@ -2792,6 +2786,7 @@
 static struct net_proto_family pfkey_family_ops = {
 	.family	=	PF_KEY,
 	.create	=	pfkey_create,
+	.owner	=	THIS_MODULE,
 };
 
 #ifdef CONFIG_PROC_FS
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	Mon Apr 28 11:43:49 2003
+++ b/net/netrom/af_netrom.c	Mon Apr 28 11:43:49 2003
@@ -62,34 +62,25 @@
 
 static struct proto_ops nr_proto_ops;
 
-static void nr_free_sock(struct sock *sk)
-{
-	sk_free(sk);
-
-	MOD_DEC_USE_COUNT;
-}
-
 static struct sock *nr_alloc_sock(void)
 {
-	struct sock *sk;
 	nr_cb *nr;
+	struct sock *sk = sk_alloc(PF_NETROM, GFP_ATOMIC, 1, NULL);
 
-	MOD_INC_USE_COUNT;
-	if ((sk = sk_alloc(PF_NETROM, GFP_ATOMIC, 1, NULL)) == NULL)
-		goto decmod;
+	if (!sk)
+		goto out;
 
 	nr = nr_sk(sk) = kmalloc(sizeof(*nr), GFP_ATOMIC);
 	if (!nr)
 		goto frees;
 
 	memset(nr, 0x00, sizeof(*nr));
-
 	nr->sk = sk;
-
-out:	return sk;
-frees:	sk_free(sk);
+out:
+	return sk;
+frees:
+	sk_free(sk);
 	sk = NULL;
-decmod:	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -300,9 +291,8 @@
 		sk->timer.function = nr_destroy_timer;
 		sk->timer.data     = (unsigned long)sk;
 		add_timer(&sk->timer);
-	} else {
-		nr_free_sock(sk);
-	}
+	} else
+		sk_free(sk);
 }
 
 /*
@@ -1232,6 +1222,7 @@
 static struct net_proto_family nr_family_ops = {
 	.family		=	PF_NETROM,
 	.create		=	nr_create,
+	.owner		=	THIS_MODULE,
 };
 
 static struct proto_ops nr_proto_ops = {
diff -Nru a/net/netrom/nr_dev.c b/net/netrom/nr_dev.c
--- a/net/netrom/nr_dev.c	Mon Apr 28 11:43:49 2003
+++ b/net/netrom/nr_dev.c	Mon Apr 28 11:43:49 2003
@@ -170,7 +170,6 @@
 
 static int nr_open(struct net_device *dev)
 {
-	MOD_INC_USE_COUNT;
 	netif_start_queue(dev);
 	ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
 	return 0;
@@ -180,7 +179,6 @@
 {
 	netif_stop_queue(dev);
 	ax25_listen_release((ax25_address *)dev->dev_addr, NULL);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -199,6 +197,7 @@
 
 int nr_init(struct net_device *dev)
 {
+	SET_MODULE_OWNER(dev);
 	dev->mtu		= NR_MAX_PACKET_SIZE;
 	dev->hard_start_xmit	= nr_xmit;
 	dev->open		= nr_open;
diff -Nru a/net/packet/af_packet.c b/net/packet/af_packet.c
--- a/net/packet/af_packet.c	Mon Apr 28 11:43:49 2003
+++ b/net/packet/af_packet.c	Mon Apr 28 11:43:49 2003
@@ -209,7 +209,6 @@
 #ifdef PACKET_REFCNT_DEBUG
 	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
 #endif
-	MOD_DEC_USE_COUNT;
 }
 
 
@@ -939,7 +938,6 @@
 		return -ESOCKTNOSUPPORT;
 
 	sock->state = SS_UNCONNECTED;
-	MOD_INC_USE_COUNT;
 
 	err = -ENOBUFS;
 	sk = sk_alloc(PF_PACKET, GFP_KERNEL, 1, NULL);
@@ -992,7 +990,6 @@
 out_free:
 	sk_free(sk);
 out:
-	MOD_DEC_USE_COUNT;
 	return err;
 }
 
@@ -1752,6 +1749,7 @@
 static struct net_proto_family packet_family_ops = {
 	.family =	PF_PACKET,
 	.create =	packet_create,
+	.owner	=	THIS_MODULE,
 };
 
 static struct notifier_block packet_netdev_notifier = {
diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	Mon Apr 28 11:43:49 2003
+++ b/net/rose/af_rose.c	Mon Apr 28 11:43:49 2003
@@ -124,22 +124,13 @@
 	return 0;
 }
 
-static void rose_free_sock(struct sock *sk)
-{
-	sk_free(sk);
-
-	MOD_DEC_USE_COUNT;
-}
-
 static struct sock *rose_alloc_sock(void)
 {
-	struct sock *sk;
 	rose_cb *rose;
+	struct sock *sk = sk_alloc(PF_ROSE, GFP_ATOMIC, 1, NULL);
 
-	MOD_INC_USE_COUNT;
-
-	if ((sk = sk_alloc(PF_ROSE, GFP_ATOMIC, 1, NULL)) == NULL)
-		goto decmod;
+	if (!sk)
+		goto out;
 
 	rose = rose_sk(sk) = kmalloc(sizeof(*rose), GFP_ATOMIC);
 	if (!rose)
@@ -147,10 +138,11 @@
 
 	memset(rose, 0x00, sizeof(*rose));
 	rose->sk = sk;
-out:	return sk;
-frees:	sk_free(sk);
+out:
+	return sk;
+frees:
+	sk_free(sk);
 	sk = NULL;
-decmod:	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -380,9 +372,8 @@
 		sk->timer.function = rose_destroy_timer;
 		sk->timer.data     = (unsigned long)sk;
 		add_timer(&sk->timer);
-	} else {
-		rose_free_sock(sk);
-	}
+	} else
+		sk_free(sk);
 }
 
 /*
@@ -1428,6 +1419,7 @@
 static struct net_proto_family rose_family_ops = {
 	.family		=	PF_ROSE,
 	.create		=	rose_create,
+	.owner		=	THIS_MODULE,
 };
 
 static struct proto_ops rose_proto_ops = {
diff -Nru a/net/rose/rose_dev.c b/net/rose/rose_dev.c
--- a/net/rose/rose_dev.c	Mon Apr 28 11:43:49 2003
+++ b/net/rose/rose_dev.c	Mon Apr 28 11:43:49 2003
@@ -135,7 +135,6 @@
 
 static int rose_open(struct net_device *dev)
 {
-	MOD_INC_USE_COUNT;
 	netif_start_queue(dev);
 	rose_add_loopback_node((rose_address *)dev->dev_addr);
 	return 0;
@@ -145,7 +144,6 @@
 {
 	netif_stop_queue(dev);
 	rose_del_loopback_node((rose_address *)dev->dev_addr);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -169,6 +167,7 @@
 
 int rose_init(struct net_device *dev)
 {
+	SET_MODULE_OWNER(dev);
 	dev->mtu		= ROSE_MAX_PACKET_SIZE - 2;
 	dev->hard_start_xmit	= rose_xmit;
 	dev->open		= rose_open;
diff -Nru a/net/wanrouter/af_wanpipe.c b/net/wanrouter/af_wanpipe.c
--- a/net/wanrouter/af_wanpipe.c	Mon Apr 28 11:43:49 2003
+++ b/net/wanrouter/af_wanpipe.c	Mon Apr 28 11:43:49 2003
@@ -509,8 +509,6 @@
 	wan_opt->tx_timer.data	   = (unsigned long)sk;
 	wan_opt->tx_timer.function = wanpipe_delayed_transmit;
 
-	MOD_INC_USE_COUNT;
-
 	sock_init_data(NULL, sk);
 	return sk;
 }
@@ -846,7 +844,6 @@
 		}
 		sock_put(sk);
 		atomic_dec(&wanpipe_socks_nr);
-		MOD_DEC_USE_COUNT;
 		return;
 	}
 
@@ -1032,7 +1029,6 @@
 	}
 	sock_put(sk);
 	atomic_dec(&wanpipe_socks_nr);
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -1197,7 +1193,6 @@
 	}
 	sock_put(sk);
 	atomic_dec(&wanpipe_socks_nr);
-	MOD_DEC_USE_COUNT;
 	return;
 }
 
@@ -1237,7 +1232,6 @@
 	}
 	sock_put(sk);
 	atomic_dec(&wanpipe_socks_nr);
-	MOD_DEC_USE_COUNT;
 	return;
 }
 
@@ -1262,8 +1256,6 @@
 	}
 	sock_put(sk);
 	atomic_dec(&wanpipe_socks_nr);
-	MOD_DEC_USE_COUNT;
-	return;
 }
 
 
@@ -2579,6 +2571,7 @@
 static struct net_proto_family wanpipe_family_ops = {
 	.family = PF_WANPIPE,
 	.create = wanpipe_create,
+	.owner	= THIS_MODULE,
 };
 
 struct notifier_block wanpipe_netdev_notifier = {
diff -Nru a/net/x25/af_x25.c b/net/x25/af_x25.c
--- a/net/x25/af_x25.c	Mon Apr 28 11:43:49 2003
+++ b/net/x25/af_x25.c	Mon Apr 28 11:43:49 2003
@@ -359,10 +359,8 @@
 		sk->timer.function = x25_destroy_timer;
 		sk->timer.data     = (unsigned long)sk;
 		add_timer(&sk->timer);
-	} else {
+	} else
 		sk_free(sk);
-		MOD_DEC_USE_COUNT;
-	}
 	release_sock(sk);
 	sock_put(sk);
 }
@@ -442,13 +440,11 @@
 
 static struct sock *x25_alloc_socket(void)
 {
-	struct sock *sk;
 	struct x25_opt *x25;
+	struct sock *sk = sk_alloc(AF_X25, GFP_ATOMIC, 1, NULL);
 
-	MOD_INC_USE_COUNT;
-
-	if ((sk = sk_alloc(AF_X25, GFP_ATOMIC, 1, NULL)) == NULL)
-		goto decmod;
+	if (!sk)
+		goto out;
 
 	x25 = x25_sk(sk) = kmalloc(sizeof(*x25), GFP_ATOMIC);
 	if (!x25)
@@ -469,8 +465,6 @@
 frees:
 	sk_free(sk);
 	sk = NULL;
-decmod:
-	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -1324,6 +1318,7 @@
 struct net_proto_family x25_family_ops = {
 	.family =	AF_X25,
 	.create =	x25_create,
+	.owner	=	THIS_MODULE,
 };
 
 static struct proto_ops SOCKOPS_WRAPPED(x25_proto_ops) = {
