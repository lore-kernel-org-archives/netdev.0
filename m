From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net/core: EXPORT_SYMBOL cleanups
Date: Sat, 10 Jul 2010 09:22:04 +0200
Message-ID: <1278746524.2538.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42728 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840Ab0GJHWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 03:22:09 -0400
Received: by wwb24 with SMTP id 24so5625678wwb.1
        for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 00:22:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CodingStyle cleanups

EXPORT_SYMBOL should immediately follow the symbol declaration.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/datagram.c   |    8 +++-----
 net/core/flow.c       |    5 ++---
 net/core/gen_stats.c  |   14 ++++++--------
 net/core/iovec.c      |    9 ++++-----
 net/core/link_watch.c |    1 -
 net/core/net-sysfs.c  |    3 +--
 net/core/netevent.c   |    5 ++---
 net/core/netpoll.c    |   19 +++++++++----------
 net/core/rtnetlink.c  |    2 +-
 net/core/scm.c        |    9 ++++-----
 net/core/skbuff.c     |    1 -
 net/core/stream.c     |    6 ------
 net/core/utils.c      |    3 ---
 13 files changed, 32 insertions(+), 53 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index f5b6f43..251997a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -219,6 +219,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 	return __skb_recv_datagram(sk, flags | (noblock ? MSG_DONTWAIT : 0),
 				   &peeked, err);
 }
+EXPORT_SYMBOL(skb_recv_datagram);
 
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
@@ -288,7 +289,6 @@ int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 
 	return err;
 }
-
 EXPORT_SYMBOL(skb_kill_datagram);
 
 /**
@@ -373,6 +373,7 @@ int skb_copy_datagram_iovec(const struct sk_buff *skb, int offset,
 fault:
 	return -EFAULT;
 }
+EXPORT_SYMBOL(skb_copy_datagram_iovec);
 
 /**
  *	skb_copy_datagram_const_iovec - Copy a datagram to an iovec.
@@ -716,6 +717,7 @@ csum_error:
 fault:
 	return -EFAULT;
 }
+EXPORT_SYMBOL(skb_copy_and_csum_datagram_iovec);
 
 /**
  * 	datagram_poll - generic datagram poll
@@ -770,8 +772,4 @@ unsigned int datagram_poll(struct file *file, struct socket *sock,
 
 	return mask;
 }
-
 EXPORT_SYMBOL(datagram_poll);
-EXPORT_SYMBOL(skb_copy_and_csum_datagram_iovec);
-EXPORT_SYMBOL(skb_copy_datagram_iovec);
-EXPORT_SYMBOL(skb_recv_datagram);
diff --git a/net/core/flow.c b/net/core/flow.c
index 8c7c91a..f67dcbf 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -62,6 +62,7 @@ struct flow_cache {
 };
 
 atomic_t flow_cache_genid = ATOMIC_INIT(0);
+EXPORT_SYMBOL(flow_cache_genid);
 static struct flow_cache flow_cache_global;
 static struct kmem_cache *flow_cachep;
 
@@ -291,6 +292,7 @@ ret_object:
 	local_bh_enable();
 	return flo;
 }
+EXPORT_SYMBOL(flow_cache_lookup);
 
 static void flow_cache_flush_tasklet(unsigned long data)
 {
@@ -424,6 +426,3 @@ static int __init flow_cache_init_global(void)
 }
 
 module_init(flow_cache_init_global);
-
-EXPORT_SYMBOL(flow_cache_genid);
-EXPORT_SYMBOL(flow_cache_lookup);
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 393b1d8..0452eb2 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -73,6 +73,7 @@ gnet_stats_start_copy_compat(struct sk_buff *skb, int type, int tc_stats_type,
 
 	return 0;
 }
+EXPORT_SYMBOL(gnet_stats_start_copy_compat);
 
 /**
  * gnet_stats_start_copy_compat - start dumping procedure in compatibility mode
@@ -93,6 +94,7 @@ gnet_stats_start_copy(struct sk_buff *skb, int type, spinlock_t *lock,
 {
 	return gnet_stats_start_copy_compat(skb, type, 0, 0, lock, d);
 }
+EXPORT_SYMBOL(gnet_stats_start_copy);
 
 /**
  * gnet_stats_copy_basic - copy basic statistics into statistic TLV
@@ -123,6 +125,7 @@ gnet_stats_copy_basic(struct gnet_dump *d, struct gnet_stats_basic_packed *b)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(gnet_stats_copy_basic);
 
 /**
  * gnet_stats_copy_rate_est - copy rate estimator statistics into statistics TLV
@@ -154,6 +157,7 @@ gnet_stats_copy_rate_est(struct gnet_dump *d,
 
 	return 0;
 }
+EXPORT_SYMBOL(gnet_stats_copy_rate_est);
 
 /**
  * gnet_stats_copy_queue - copy queue statistics into statistics TLV
@@ -181,6 +185,7 @@ gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q)
 
 	return 0;
 }
+EXPORT_SYMBOL(gnet_stats_copy_queue);
 
 /**
  * gnet_stats_copy_app - copy application specific statistics into statistics TLV
@@ -208,6 +213,7 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 
 	return 0;
 }
+EXPORT_SYMBOL(gnet_stats_copy_app);
 
 /**
  * gnet_stats_finish_copy - finish dumping procedure
@@ -241,12 +247,4 @@ gnet_stats_finish_copy(struct gnet_dump *d)
 	spin_unlock_bh(d->lock);
 	return 0;
 }
-
-
-EXPORT_SYMBOL(gnet_stats_start_copy);
-EXPORT_SYMBOL(gnet_stats_start_copy_compat);
-EXPORT_SYMBOL(gnet_stats_copy_basic);
-EXPORT_SYMBOL(gnet_stats_copy_rate_est);
-EXPORT_SYMBOL(gnet_stats_copy_queue);
-EXPORT_SYMBOL(gnet_stats_copy_app);
 EXPORT_SYMBOL(gnet_stats_finish_copy);
diff --git a/net/core/iovec.c b/net/core/iovec.c
index 1e7f4e9..1cd98df 100644
--- a/net/core/iovec.c
+++ b/net/core/iovec.c
@@ -95,6 +95,7 @@ int memcpy_toiovec(struct iovec *iov, unsigned char *kdata, int len)
 
 	return 0;
 }
+EXPORT_SYMBOL(memcpy_toiovec);
 
 /*
  *	Copy kernel to iovec. Returns -EFAULT on error.
@@ -120,6 +121,7 @@ int memcpy_toiovecend(const struct iovec *iov, unsigned char *kdata,
 
 	return 0;
 }
+EXPORT_SYMBOL(memcpy_toiovecend);
 
 /*
  *	Copy iovec to kernel. Returns -EFAULT on error.
@@ -144,6 +146,7 @@ int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len)
 
 	return 0;
 }
+EXPORT_SYMBOL(memcpy_fromiovec);
 
 /*
  *	Copy iovec from kernel. Returns -EFAULT on error.
@@ -172,6 +175,7 @@ int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 
 	return 0;
 }
+EXPORT_SYMBOL(memcpy_fromiovecend);
 
 /*
  *	And now for the all-in-one: copy and checksum from a user iovec
@@ -256,9 +260,4 @@ out_fault:
 	err = -EFAULT;
 	goto out;
 }
-
 EXPORT_SYMBOL(csum_partial_copy_fromiovecend);
-EXPORT_SYMBOL(memcpy_fromiovec);
-EXPORT_SYMBOL(memcpy_fromiovecend);
-EXPORT_SYMBOL(memcpy_toiovec);
-EXPORT_SYMBOL(memcpy_toiovecend);
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index bdbce2f..01a1101 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -243,5 +243,4 @@ void linkwatch_fire_event(struct net_device *dev)
 
 	linkwatch_schedule_work(urgent);
 }
-
 EXPORT_SYMBOL(linkwatch_fire_event);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 914f42b..d2b5965 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -924,13 +924,12 @@ int netdev_class_create_file(struct class_attribute *class_attr)
 {
 	return class_create_file(&net_class, class_attr);
 }
+EXPORT_SYMBOL(netdev_class_create_file);
 
 void netdev_class_remove_file(struct class_attribute *class_attr)
 {
 	class_remove_file(&net_class, class_attr);
 }
-
-EXPORT_SYMBOL(netdev_class_create_file);
 EXPORT_SYMBOL(netdev_class_remove_file);
 
 int netdev_kobject_init(void)
diff --git a/net/core/netevent.c b/net/core/netevent.c
index 95f81de..865f0ce 100644
--- a/net/core/netevent.c
+++ b/net/core/netevent.c
@@ -35,6 +35,7 @@ int register_netevent_notifier(struct notifier_block *nb)
 	err = atomic_notifier_chain_register(&netevent_notif_chain, nb);
 	return err;
 }
+EXPORT_SYMBOL_GPL(register_netevent_notifier);
 
 /**
  *	netevent_unregister_notifier - unregister a netevent notifier block
@@ -50,6 +51,7 @@ int unregister_netevent_notifier(struct notifier_block *nb)
 {
 	return atomic_notifier_chain_unregister(&netevent_notif_chain, nb);
 }
+EXPORT_SYMBOL_GPL(unregister_netevent_notifier);
 
 /**
  *	call_netevent_notifiers - call all netevent notifier blocks
@@ -64,7 +66,4 @@ int call_netevent_notifiers(unsigned long val, void *v)
 {
 	return atomic_notifier_call_chain(&netevent_notif_chain, val, v);
 }
-
-EXPORT_SYMBOL_GPL(register_netevent_notifier);
-EXPORT_SYMBOL_GPL(unregister_netevent_notifier);
 EXPORT_SYMBOL_GPL(call_netevent_notifiers);
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ca6dc31..c2b7a8b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -197,11 +197,13 @@ void netpoll_poll_dev(struct net_device *dev)
 	service_arp_queue(dev->npinfo);
 
 }
+EXPORT_SYMBOL(netpoll_poll_dev);
 
 void netpoll_poll(struct netpoll *np)
 {
 	netpoll_poll_dev(np->dev);
 }
+EXPORT_SYMBOL(netpoll_poll);
 
 static void refill_skbs(void)
 {
@@ -313,6 +315,7 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 		schedule_delayed_work(&npinfo->tx_work,0);
 	}
 }
+EXPORT_SYMBOL(netpoll_send_skb);
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 {
@@ -374,6 +377,7 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 
 	netpoll_send_skb(np, skb);
 }
+EXPORT_SYMBOL(netpoll_send_udp);
 
 static void arp_reply(struct sk_buff *skb)
 {
@@ -600,6 +604,7 @@ void netpoll_print_options(struct netpoll *np)
 	printk(KERN_INFO "%s: remote ethernet address %pM\n",
 	                 np->name, np->remote_mac);
 }
+EXPORT_SYMBOL(netpoll_print_options);
 
 int netpoll_parse_options(struct netpoll *np, char *opt)
 {
@@ -692,6 +697,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 	       np->name, cur);
 	return -1;
 }
+EXPORT_SYMBOL(netpoll_parse_options);
 
 int __netpoll_setup(struct netpoll *np)
 {
@@ -848,6 +854,7 @@ put:
 	dev_put(ndev);
 	return err;
 }
+EXPORT_SYMBOL(netpoll_setup);
 
 static int __init netpoll_init(void)
 {
@@ -908,11 +915,13 @@ void netpoll_cleanup(struct netpoll *np)
 	dev_put(np->dev);
 	np->dev = NULL;
 }
+EXPORT_SYMBOL(netpoll_cleanup);
 
 int netpoll_trap(void)
 {
 	return atomic_read(&trapped);
 }
+EXPORT_SYMBOL(netpoll_trap);
 
 void netpoll_set_trap(int trap)
 {
@@ -921,14 +930,4 @@ void netpoll_set_trap(int trap)
 	else
 		atomic_dec(&trapped);
 }
-
-EXPORT_SYMBOL(netpoll_send_skb);
 EXPORT_SYMBOL(netpoll_set_trap);
-EXPORT_SYMBOL(netpoll_trap);
-EXPORT_SYMBOL(netpoll_print_options);
-EXPORT_SYMBOL(netpoll_parse_options);
-EXPORT_SYMBOL(netpoll_setup);
-EXPORT_SYMBOL(netpoll_cleanup);
-EXPORT_SYMBOL(netpoll_send_udp);
-EXPORT_SYMBOL(netpoll_poll_dev);
-EXPORT_SYMBOL(netpoll_poll);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5e773ea..f78d821 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -686,7 +686,7 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
-static inline size_t if_nlmsg_size(const struct net_device *dev)
+static noinline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
diff --git a/net/core/scm.c b/net/core/scm.c
index 681c976..413cab8 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -130,6 +130,7 @@ void __scm_destroy(struct scm_cookie *scm)
 		}
 	}
 }
+EXPORT_SYMBOL(__scm_destroy);
 
 int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 {
@@ -211,6 +212,7 @@ error:
 	scm_destroy(p);
 	return err;
 }
+EXPORT_SYMBOL(__scm_send);
 
 int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 {
@@ -249,6 +251,7 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 out:
 	return err;
 }
+EXPORT_SYMBOL(put_cmsg);
 
 void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 {
@@ -318,6 +321,7 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
 	 */
 	__scm_destroy(scm);
 }
+EXPORT_SYMBOL(scm_detach_fds);
 
 struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 {
@@ -335,9 +339,4 @@ struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl)
 	}
 	return new_fpl;
 }
-
-EXPORT_SYMBOL(__scm_destroy);
-EXPORT_SYMBOL(__scm_send);
-EXPORT_SYMBOL(put_cmsg);
-EXPORT_SYMBOL(scm_detach_fds);
 EXPORT_SYMBOL(scm_fp_dup);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 34432b4..76d33ca 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2483,7 +2483,6 @@ unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len)
 	skb_postpull_rcsum(skb, skb->data, len);
 	return skb->data += len;
 }
-
 EXPORT_SYMBOL_GPL(skb_pull_rcsum);
 
 /**
diff --git a/net/core/stream.c b/net/core/stream.c
index cc196f4..d959e0f 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -43,7 +43,6 @@ void sk_stream_write_space(struct sock *sk)
 		rcu_read_unlock();
 	}
 }
-
 EXPORT_SYMBOL(sk_stream_write_space);
 
 /**
@@ -81,7 +80,6 @@ int sk_stream_wait_connect(struct sock *sk, long *timeo_p)
 	} while (!done);
 	return 0;
 }
-
 EXPORT_SYMBOL(sk_stream_wait_connect);
 
 /**
@@ -109,7 +107,6 @@ void sk_stream_wait_close(struct sock *sk, long timeout)
 		finish_wait(sk_sleep(sk), &wait);
 	}
 }
-
 EXPORT_SYMBOL(sk_stream_wait_close);
 
 /**
@@ -174,7 +171,6 @@ do_interrupted:
 	err = sock_intr_errno(*timeo_p);
 	goto out;
 }
-
 EXPORT_SYMBOL(sk_stream_wait_memory);
 
 int sk_stream_error(struct sock *sk, int flags, int err)
@@ -185,7 +181,6 @@ int sk_stream_error(struct sock *sk, int flags, int err)
 		send_sig(SIGPIPE, current, 0);
 	return err;
 }
-
 EXPORT_SYMBOL(sk_stream_error);
 
 void sk_stream_kill_queues(struct sock *sk)
@@ -210,5 +205,4 @@ void sk_stream_kill_queues(struct sock *sk)
 	 * have gone away, only the net layer knows can touch it.
 	 */
 }
-
 EXPORT_SYMBOL(sk_stream_kill_queues);
diff --git a/net/core/utils.c b/net/core/utils.c
index 8382502..f418544 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -77,7 +77,6 @@ __be32 in_aton(const char *str)
 	}
 	return(htonl(l));
 }
-
 EXPORT_SYMBOL(in_aton);
 
 #define IN6PTON_XDIGIT		0x00010000
@@ -162,7 +161,6 @@ out:
 		*end = s;
 	return ret;
 }
-
 EXPORT_SYMBOL(in4_pton);
 
 int in6_pton(const char *src, int srclen,
@@ -280,7 +278,6 @@ out:
 		*end = s;
 	return ret;
 }
-
 EXPORT_SYMBOL(in6_pton);
 
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,


