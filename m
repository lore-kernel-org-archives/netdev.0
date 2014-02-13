From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] net: remove unnecessary return's
Date: Wed, 12 Feb 2014 20:51:22 -0800
Message-ID: <20140212205122.5783660e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:42278 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaBMEv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 23:51:27 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so10285373pab.9
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 20:51:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of my pet coding style peeves is the practice of
adding extra return; at the end of function.
Kill several instances of this in network code.

I suppose some coccinelle wizardy could do this automatically.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 net/batman-adv/gateway_client.c |    2 --
 net/ceph/osd_client.c           |    2 --
 net/core/request_sock.c         |    1 -
 net/ipv4/route.c                |    1 -
 net/ipv4/tcp_output.c           |    1 -
 net/l2tp/l2tp_core.c            |    2 --
 net/l2tp/l2tp_ppp.c             |    3 ---
 net/mac802154/mib.c             |    4 ----
 net/mac802154/rx.c              |    1 -
 net/sctp/transport.c            |    1 -
 net/wireless/chan.c             |    2 --
 11 files changed, 20 deletions(-)

--- a/net/core/request_sock.c	2014-02-12 08:21:56.742857227 -0800
+++ b/net/core/request_sock.c	2014-02-12 20:42:04.914745631 -0800
@@ -221,5 +221,4 @@ void reqsk_fastopen_remove(struct sock *
 out:
 	spin_unlock_bh(&fastopenq->lock);
 	sock_put(lsk);
-	return;
 }
--- a/net/ipv4/route.c	2014-02-12 08:21:56.764856910 -0800
+++ b/net/ipv4/route.c	2014-02-12 20:42:26.498457902 -0800
@@ -697,7 +697,6 @@ static void update_or_create_fnhe(struct
 
 out_unlock:
 	spin_unlock_bh(&fnhe_lock);
-	return;
 }
 
 static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flowi4 *fl4,
--- a/net/ipv4/tcp_output.c	2014-02-12 08:21:56.768856853 -0800
+++ b/net/ipv4/tcp_output.c	2014-02-12 20:42:46.905185882 -0800
@@ -2071,7 +2071,6 @@ rearm_timer:
 	if (likely(!err))
 		NET_INC_STATS_BH(sock_net(sk),
 				 LINUX_MIB_TCPLOSSPROBES);
-	return;
 }
 
 /* Push out any pending frames which were held back due to
--- a/net/l2tp/l2tp_core.c	2014-02-12 08:21:56.787856580 -0800
+++ b/net/l2tp/l2tp_core.c	2014-02-12 20:43:53.049304122 -0800
@@ -1809,8 +1809,6 @@ void l2tp_session_free(struct l2tp_sessi
 	}
 
 	kfree(session);
-
-	return;
 }
 EXPORT_SYMBOL_GPL(l2tp_session_free);
 
--- a/net/sctp/transport.c	2014-02-12 08:21:56.848855704 -0800
+++ b/net/sctp/transport.c	2014-02-12 20:41:15.051410364 -0800
@@ -652,5 +652,4 @@ void sctp_transport_immediate_rtx(struct
 		if (!mod_timer(&t->T3_rtx_timer, jiffies + t->rto))
 			sctp_transport_hold(t);
 	}
-	return;
 }
--- a/net/wireless/chan.c	2014-02-12 08:21:56.864855473 -0800
+++ b/net/wireless/chan.c	2014-02-12 20:44:22.519911266 -0800
@@ -701,6 +701,4 @@ cfg80211_get_chan_state(struct wireless_
 	case NUM_NL80211_IFTYPES:
 		WARN_ON(1);
 	}
-
-	return;
 }
--- a/net/batman-adv/gateway_client.c	2014-02-12 08:21:56.723857500 -0800
+++ b/net/batman-adv/gateway_client.c	2014-02-12 20:45:16.790187817 -0800
@@ -389,8 +389,6 @@ out:
 		batadv_neigh_ifinfo_free_ref(router_gw_tq);
 	if (router_orig_tq)
 		batadv_neigh_ifinfo_free_ref(router_orig_tq);
-
-	return;
 }
 
 /**
--- a/net/ceph/osd_client.c	2014-02-12 08:21:56.738857284 -0800
+++ b/net/ceph/osd_client.c	2014-02-12 20:47:00.116810485 -0800
@@ -2082,7 +2082,6 @@ bad:
 	pr_err("osdc handle_map corrupt msg\n");
 	ceph_msg_dump(msg);
 	up_write(&osdc->map_sem);
-	return;
 }
 
 /*
@@ -2281,7 +2280,6 @@ done_err:
 
 bad:
 	pr_err("osdc handle_watch_notify corrupt msg\n");
-	return;
 }
 
 /*
--- a/net/l2tp/l2tp_ppp.c	2014-02-12 08:21:56.788856566 -0800
+++ b/net/l2tp/l2tp_ppp.c	2014-02-12 20:47:27.828441095 -0800
@@ -454,13 +454,11 @@ static void pppol2tp_session_close(struc
 
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
-
 	if (sock) {
 		inet_shutdown(sock, 2);
 		/* Don't let the session go away before our socket does */
 		l2tp_session_inc_refcount(session);
 	}
-	return;
 }
 
 /* Really kill the session socket. (Called from sock_put() if
@@ -474,7 +472,6 @@ static void pppol2tp_session_destruct(st
 		BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 		l2tp_session_dec_refcount(session);
 	}
-	return;
 }
 
 /* Called when the PPPoX socket (session) is closed.
--- a/net/mac802154/mib.c	2014-02-12 08:21:56.801856379 -0800
+++ b/net/mac802154/mib.c	2014-02-12 20:46:11.533458098 -0800
@@ -62,8 +62,6 @@ static void hw_addr_notify(struct work_s
 		pr_debug("failed changed mask %lx\n", nw->changed);
 
 	kfree(nw);
-
-	return;
 }
 
 static void set_hw_addr_filt(struct net_device *dev, unsigned long changed)
@@ -79,8 +77,6 @@ static void set_hw_addr_filt(struct net_
 	work->dev = dev;
 	work->changed = changed;
 	queue_work(priv->hw->dev_workqueue, &work->work);
-
-	return;
 }
 
 void mac802154_dev_set_short_addr(struct net_device *dev, u16 val)
--- a/net/mac802154/rx.c	2014-02-12 08:21:56.801856379 -0800
+++ b/net/mac802154/rx.c	2014-02-12 20:46:30.229208880 -0800
@@ -80,7 +80,6 @@ mac802154_subif_rx(struct ieee802154_dev
 	mac802154_wpans_rx(priv, skb);
 out:
 	dev_kfree_skb(skb);
-	return;
 }
 
 static void mac802154_rx_worker(struct work_struct *work)
