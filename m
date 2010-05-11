From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Remove unnecessary returns from void
 function()s
Date: Tue, 11 May 2010 10:45:41 -0700
Message-ID: <1273599941.20514.235.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2146 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756242Ab0EKRpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 13:45:43 -0400
Received: from [192.168.1.151] (new-host-5.home [192.168.1.151])
	by mail.perches.com (Postfix) with ESMTP id E949024368
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 10:45:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes from net/ (but not any netfilter files)
all the unnecessary return; statements that precede the
last closing brace of void functions.

It does not remove the returns that are immediately
preceded by a label as gcc doesn't like that.

Done via:
$ grep -rP --include=*.[ch] -l "return;\n}" net/ | \
  xargs perl -i -e 'local $/ ; while (<>) { s/\n[ \t\n]+return;\n}/\n}/g; print; }'

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/9p/trans_rdma.c               |    1 -
 net/atm/br2684.c                  |    1 -
 net/atm/lec.c                     |    6 ------
 net/atm/mpc.c                     |   32 --------------------------------
 net/atm/mpoa_caches.c             |   20 --------------------
 net/bluetooth/hci_core.c          |    2 --
 net/bluetooth/l2cap.c             |    3 ---
 net/bluetooth/rfcomm/tty.c        |    2 --
 net/bluetooth/sco.c               |    1 -
 net/caif/caif_dev.c               |    1 -
 net/can/bcm.c                     |    2 --
 net/decnet/dn_dev.c               |    3 ---
 net/decnet/dn_route.c             |    1 -
 net/ipv4/cipso_ipv4.c             |    2 --
 net/ipv4/fib_trie.c               |    2 --
 net/ipv4/ip_gre.c                 |    1 -
 net/ipv4/ip_options.c             |    1 -
 net/ipv4/ipmr.c                   |    1 -
 net/ipv6/ndisc.c                  |    2 --
 net/ipv6/proc.c                   |    1 -
 net/ipv6/route.c                  |    2 --
 net/irda/iriap.c                  |    2 --
 net/irda/irnet/irnet_irda.c       |    3 ---
 net/iucv/af_iucv.c                |    1 -
 net/mac80211/debugfs.h            |    1 -
 net/mac80211/mesh.c               |    2 --
 net/mac80211/mesh_hwmp.c          |    1 -
 net/netlabel/netlabel_addrlist.h  |    2 --
 net/netlabel/netlabel_unlabeled.c |    1 -
 net/sched/cls_flow.c              |    1 -
 net/sched/sch_hfsc.c              |    1 -
 net/sched/sch_ingress.c           |    1 -
 net/sched/sch_mq.c                |    1 -
 net/sched/sch_multiq.c            |    1 -
 net/sched/sch_prio.c              |    1 -
 net/sched/sch_red.c               |    1 -
 net/sctp/associola.c              |    2 --
 net/sctp/outqueue.c               |    2 --
 net/sctp/proc.c                   |    3 ---
 net/sctp/sm_sideeffect.c          |    4 ----
 net/sctp/ulpqueue.c               |    2 --
 net/sunrpc/clnt.c                 |    1 -
 net/sunrpc/svcsock.c              |    1 -
 net/sunrpc/xprt.c                 |    1 -
 net/sunrpc/xprtsock.c             |    4 ----
 net/sysctl_net.c                  |    1 -
 net/wimax/stack.c                 |    2 --
 net/xfrm/xfrm_policy.c            |    1 -
 48 files changed, 0 insertions(+), 131 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 041101a..0ea20c3 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -308,7 +308,6 @@ handle_recv(struct p9_client *client, struct p9_trans_rdma *rdma,
 		   req, err, status);
 	rdma->state = P9_RDMA_FLUSHING;
 	client->status = Disconnected;
-	return;
 }
 
 static void
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index d6c7cea..6719af6 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -446,7 +446,6 @@ error:
 	net_dev->stats.rx_errors++;
 free_skb:
 	dev_kfree_skb(skb);
-	return;
 }
 
 /*
diff --git a/net/atm/lec.c b/net/atm/lec.c
index feeaf57..d98bde1 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -161,8 +161,6 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		skb_queue_tail(&sk->sk_receive_queue, skb2);
 		sk->sk_data_ready(sk, skb2->len);
 	}
-
-	return;
 }
 #endif /* defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE) */
 
@@ -640,7 +638,6 @@ static void lec_set_multicast_list(struct net_device *dev)
 	 * by default, all multicast frames arrive over the bus.
 	 * eventually support selective multicast service
 	 */
-	return;
 }
 
 static const struct net_device_ops lec_netdev_ops = {
@@ -1199,8 +1196,6 @@ static void __exit lane_module_cleanup(void)
 			dev_lec[i] = NULL;
 		}
 	}
-
-	return;
 }
 
 module_init(lane_module_init);
@@ -1334,7 +1329,6 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 		priv->lane2_ops->associate_indicator(dev, mac_addr,
 						     tlvs, sizeoftlvs);
 	}
-	return;
 }
 
 /*
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 436f2e1..622b471 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -455,7 +455,6 @@ static void lane2_assoc_ind(struct net_device *dev, const u8 *mac_addr,
 	if (end_of_tlvs - tlvs != 0)
 		pr_info("(%s) ignoring %Zd bytes of trailing TLV garbage\n",
 			dev->name, end_of_tlvs - tlvs);
-	return;
 }
 
 /*
@@ -684,8 +683,6 @@ static void mpc_vcc_close(struct atm_vcc *vcc, struct net_device *dev)
 
 	if (in_entry == NULL && eg_entry == NULL)
 		dprintk("(%s) unused vcc closed\n", dev->name);
-
-	return;
 }
 
 static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
@@ -783,8 +780,6 @@ static void mpc_push(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
 	netif_rx(new_skb);
-
-	return;
 }
 
 static struct atmdev_ops mpc_ops = { /* only send is required */
@@ -873,8 +868,6 @@ static void send_set_mps_ctrl_addr(const char *addr, struct mpoa_client *mpc)
 	mesg.type = SET_MPS_CTRL_ADDR;
 	memcpy(mesg.MPS_ctrl, addr, ATM_ESA_LEN);
 	msg_to_mpoad(&mesg, mpc);
-
-	return;
 }
 
 static void mpoad_close(struct atm_vcc *vcc)
@@ -911,8 +904,6 @@ static void mpoad_close(struct atm_vcc *vcc)
 	pr_info("(%s) going down\n",
 		(mpc->dev) ? mpc->dev->name : "<unknown>");
 	module_put(THIS_MODULE);
-
-	return;
 }
 
 /*
@@ -1122,7 +1113,6 @@ static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	pr_info("(%s) entry already in resolving state\n",
 		(mpc->dev) ? mpc->dev->name : "<unknown>");
 	mpc->in_ops->put(entry);
-	return;
 }
 
 /*
@@ -1166,7 +1156,6 @@ static void check_qos_and_open_shortcut(struct k_message *msg,
 	} else
 		memset(&msg->qos, 0, sizeof(struct atm_qos));
 	msg_to_mpoad(msg, client);
-	return;
 }
 
 static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc)
@@ -1240,8 +1229,6 @@ static void ingress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 		mpc->in_ops->put(entry);
 		entry = mpc->in_ops->get_with_mask(dst_ip, mpc, mask);
 	} while (entry != NULL);
-
-	return;
 }
 
 static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
@@ -1260,8 +1247,6 @@ static void egress_purge_rcvd(struct k_message *msg, struct mpoa_client *mpc)
 	write_unlock_irq(&mpc->egress_lock);
 
 	mpc->eg_ops->put(entry);
-
-	return;
 }
 
 static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
@@ -1295,8 +1280,6 @@ static void purge_egress_shortcut(struct atm_vcc *vcc, eg_cache_entry *entry)
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk, skb->len);
 	dprintk("exiting\n");
-
-	return;
 }
 
 /*
@@ -1325,8 +1308,6 @@ static void mps_death(struct k_message *msg, struct mpoa_client *mpc)
 
 	mpc->in_ops->destroy_cache(mpc);
 	mpc->eg_ops->destroy_cache(mpc);
-
-	return;
 }
 
 static void MPOA_cache_impos_rcvd(struct k_message *msg,
@@ -1353,8 +1334,6 @@ static void MPOA_cache_impos_rcvd(struct k_message *msg,
 	write_unlock_irq(&mpc->egress_lock);
 
 	mpc->eg_ops->put(entry);
-
-	return;
 }
 
 static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg,
@@ -1392,8 +1371,6 @@ static void set_mpc_ctrl_addr_rcvd(struct k_message *mesg,
 			pr_info("(%s) targetless LE_ARP request failed\n",
 				mpc->dev->name);
 	}
-
-	return;
 }
 
 static void set_mps_mac_addr_rcvd(struct k_message *msg,
@@ -1409,8 +1386,6 @@ static void set_mps_mac_addr_rcvd(struct k_message *msg,
 		return;
 	}
 	client->number_of_mps_macs = 1;
-
-	return;
 }
 
 /*
@@ -1436,7 +1411,6 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 
 	msg->type = action;
 	msg_to_mpoad(msg, mpc);
-	return;
 }
 
 static void mpc_timer_refresh(void)
@@ -1445,8 +1419,6 @@ static void mpc_timer_refresh(void)
 	mpc_timer.data = mpc_timer.expires;
 	mpc_timer.function = mpc_cache_check;
 	add_timer(&mpc_timer);
-
-	return;
 }
 
 static void mpc_cache_check(unsigned long checking_time)
@@ -1471,8 +1443,6 @@ static void mpc_cache_check(unsigned long checking_time)
 		mpc = mpc->next;
 	}
 	mpc_timer_refresh();
-
-	return;
 }
 
 static int atm_mpoa_ioctl(struct socket *sock, unsigned int cmd,
@@ -1561,8 +1531,6 @@ static void __exit atm_mpoa_cleanup(void)
 		kfree(qos);
 		qos = nextqos;
 	}
-
-	return;
 }
 
 module_init(atm_mpoa_init);
diff --git a/net/atm/mpoa_caches.c b/net/atm/mpoa_caches.c
index e773d83..d1b2d9a 100644
--- a/net/atm/mpoa_caches.c
+++ b/net/atm/mpoa_caches.c
@@ -182,8 +182,6 @@ static void in_cache_put(in_cache_entry *entry)
 		memset(entry, 0, sizeof(in_cache_entry));
 		kfree(entry);
 	}
-
-	return;
 }
 
 /*
@@ -221,8 +219,6 @@ static void in_cache_remove_entry(in_cache_entry *entry,
 		}
 		vcc_release_async(vcc, -EPIPE);
 	}
-
-	return;
 }
 
 /* Call this every MPC-p2 seconds... Not exactly correct solution,
@@ -248,8 +244,6 @@ static void clear_count_and_expired(struct mpoa_client *client)
 		entry = next_entry;
 	}
 	write_unlock_bh(&client->ingress_lock);
-
-	return;
 }
 
 /* Call this every MPC-p4 seconds. */
@@ -334,8 +328,6 @@ static void in_destroy_cache(struct mpoa_client *mpc)
 	while (mpc->in_cache != NULL)
 		mpc->in_ops->remove_entry(mpc->in_cache, mpc);
 	write_unlock_irq(&mpc->ingress_lock);
-
-	return;
 }
 
 static eg_cache_entry *eg_cache_get_by_cache_id(__be32 cache_id,
@@ -427,8 +419,6 @@ static void eg_cache_put(eg_cache_entry *entry)
 		memset(entry, 0, sizeof(eg_cache_entry));
 		kfree(entry);
 	}
-
-	return;
 }
 
 /*
@@ -463,8 +453,6 @@ static void eg_cache_remove_entry(eg_cache_entry *entry,
 		}
 		vcc_release_async(vcc, -EPIPE);
 	}
-
-	return;
 }
 
 static eg_cache_entry *eg_cache_add_entry(struct k_message *msg,
@@ -509,8 +497,6 @@ static void update_eg_cache_entry(eg_cache_entry *entry, uint16_t holding_time)
 	do_gettimeofday(&(entry->tv));
 	entry->entry_state = EGRESS_RESOLVED;
 	entry->ctrl_info.holding_time = holding_time;
-
-	return;
 }
 
 static void clear_expired(struct mpoa_client *client)
@@ -537,8 +523,6 @@ static void clear_expired(struct mpoa_client *client)
 		entry = next_entry;
 	}
 	write_unlock_irq(&client->egress_lock);
-
-	return;
 }
 
 static void eg_destroy_cache(struct mpoa_client *mpc)
@@ -547,8 +531,6 @@ static void eg_destroy_cache(struct mpoa_client *mpc)
 	while (mpc->eg_cache != NULL)
 		mpc->eg_ops->remove_entry(mpc->eg_cache, mpc);
 	write_unlock_irq(&mpc->egress_lock);
-
-	return;
 }
 
 
@@ -584,6 +566,4 @@ void atm_mpoa_init_cache(struct mpoa_client *mpc)
 {
 	mpc->in_ops = &ingress_ops;
 	mpc->eg_ops = &egress_ops;
-
-	return;
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 5e83f8e..2f768de 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1316,8 +1316,6 @@ void hci_send_acl(struct hci_conn *conn, struct sk_buff *skb, __u16 flags)
 	}
 
 	tasklet_schedule(&hdev->tx_task);
-
-	return;
 }
 EXPORT_SYMBOL(hci_send_acl);
 
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 673a368..1b682a5 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1322,8 +1322,6 @@ static void l2cap_drop_acked_frames(struct sock *sk)
 
 	if (!l2cap_pi(sk)->unacked_frames)
 		del_timer(&l2cap_pi(sk)->retrans_timer);
-
-	return;
 }
 
 static inline void l2cap_do_send(struct sock *sk, struct sk_buff *skb)
@@ -4667,7 +4665,6 @@ void l2cap_load(void)
 	/* Dummy function to trigger automatic L2CAP module loading by
 	 * other modules that use L2CAP sockets but don't use any other
 	 * symbols from it. */
-	return;
 }
 EXPORT_SYMBOL(l2cap_load);
 
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index cab71ea..309b6c2 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -1014,8 +1014,6 @@ static void rfcomm_tty_set_termios(struct tty_struct *tty, struct ktermios *old)
 		rfcomm_send_rpn(dev->dlc->session, 1, dev->dlc->dlci, baud,
 				data_bits, stop_bits, parity,
 				RFCOMM_RPN_FLOW_NONE, x_on, x_off, changes);
-
-	return;
 }
 
 static void rfcomm_tty_throttle(struct tty_struct *tty)
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index 4767928..d0927d1 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -273,7 +273,6 @@ static inline void sco_recv_frame(struct sco_conn *conn, struct sk_buff *skb)
 
 drop:
 	kfree_skb(skb);
-	return;
 }
 
 /* -------- Socket interface ---------- */
diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 024fd5b..e2b86f1 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -112,7 +112,6 @@ static void caif_device_destroy(struct net_device *dev)
 	spin_unlock_bh(&caifdevs->lock);
 
 	kfree(caifd);
-	return;
 }
 
 static int transmit(struct cflayer *layer, struct cfpkt *pkt)
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 907dc87..9c65e9d 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -713,8 +713,6 @@ static void bcm_remove_op(struct bcm_op *op)
 		kfree(op->last_frames);
 
 	kfree(op);
-
-	return;
 }
 
 static void bcm_rx_unreg(struct net_device *dev, struct bcm_op *op)
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 615dbe3..4c409b4 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1220,17 +1220,14 @@ void dn_dev_down(struct net_device *dev)
 
 void dn_dev_init_pkt(struct sk_buff *skb)
 {
-	return;
 }
 
 void dn_dev_veri_pkt(struct sk_buff *skb)
 {
-	return;
 }
 
 void dn_dev_hello(struct sk_buff *skb)
 {
-	return;
 }
 
 void dn_dev_devices_off(void)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a8432e3..812e6df 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -264,7 +264,6 @@ static struct dst_entry *dn_dst_negative_advice(struct dst_entry *dst)
 
 static void dn_dst_link_failure(struct sk_buff *skb)
 {
-	return;
 }
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index c97cd9f..3a92a76 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -290,8 +290,6 @@ void cipso_v4_cache_invalidate(void)
 		cipso_v4_cache[iter].size = 0;
 		spin_unlock_bh(&cipso_v4_cache[iter].lock);
 	}
-
-	return;
 }
 
 /**
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index c98f115..79d057a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1022,8 +1022,6 @@ static void trie_rebalance(struct trie *t, struct tnode *tn)
 
 	rcu_assign_pointer(t->trie, (struct node *)tn);
 	tnode_free_flush();
-
-	return;
 }
 
 /* only used from updater-side */
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fe381d1..a5a5501 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -502,7 +502,6 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	t->err_time = jiffies;
 out:
 	rcu_read_unlock();
-	return;
 }
 
 static inline void ipgre_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 4c09a31..39dc39e 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -238,7 +238,6 @@ void ip_options_fragment(struct sk_buff * skb)
 	opt->rr_needaddr = 0;
 	opt->ts_needaddr = 0;
 	opt->ts_needtime = 0;
-	return;
 }
 
 /*
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index f3f1c6b..48b9ae7 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1605,7 +1605,6 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 
 out_free:
 	kfree_skb(skb);
-	return;
 }
 
 static int ipmr_find_vif(struct mr_table *mrt, struct net_device *dev)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3f7c12b..0abdc24 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -890,8 +890,6 @@ out:
 		in6_ifa_put(ifp);
 	else
 		in6_dev_put(idev);
-
-	return;
 }
 
 static void ndisc_recv_na(struct sk_buff *skb)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 458eabf..566798d 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -168,7 +168,6 @@ static void snmp6_seq_show_icmpv6msg(struct seq_file *seq, void __percpu **mib)
 			i & 0x100 ?  "Out" : "In", i & 0xff);
 		seq_printf(seq, "%-32s\t%lu\n", name, val);
 	}
-	return;
 }
 
 static void snmp6_seq_show_item(struct seq_file *seq, void __percpu **mib,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 05ebd78..294cbe8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -316,7 +316,6 @@ static void rt6_probe(struct rt6_info *rt)
 #else
 static inline void rt6_probe(struct rt6_info *rt)
 {
-	return;
 }
 #endif
 
@@ -1553,7 +1552,6 @@ void rt6_redirect(struct in6_addr *dest, struct in6_addr *src,
 
 out:
 	dst_release(&rt->u.dst);
-	return;
 }
 
 /*
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index 79a1e5a..fce364c 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -685,8 +685,6 @@ static void iriap_getvaluebyclass_indication(struct iriap_cb *self,
 	/* We have a match; send the value.  */
 	iriap_getvaluebyclass_response(self, obj->id, IAS_SUCCESS,
 				       attrib->value);
-
-	return;
 }
 
 /*
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index df18ab4..e98e40d 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -678,7 +678,6 @@ irda_irnet_destroy(irnet_socket *	self)
   self->stsap_sel = 0;
 
   DEXIT(IRDA_SOCK_TRACE, "\n");
-  return;
 }
 
 
@@ -928,7 +927,6 @@ irnet_disconnect_server(irnet_socket *	self,
   irttp_listen(self->tsap);
 
   DEXIT(IRDA_SERV_TRACE, "\n");
-  return;
 }
 
 /*------------------------------------------------------------------*/
@@ -1013,7 +1011,6 @@ irnet_destroy_server(void)
   irda_irnet_destroy(&irnet_server.s);
 
   DEXIT(IRDA_SERV_TRACE, "\n");
-  return;
 }
 
 
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 8be324f..c8b4599 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -136,7 +136,6 @@ static void afiucv_pm_complete(struct device *dev)
 #ifdef CONFIG_PM_DEBUG
 	printk(KERN_WARNING "afiucv_pm_complete\n");
 #endif
-	return;
 }
 
 /**
diff --git a/net/mac80211/debugfs.h b/net/mac80211/debugfs.h
index 68e6a20..09cc9be 100644
--- a/net/mac80211/debugfs.h
+++ b/net/mac80211/debugfs.h
@@ -7,7 +7,6 @@ extern int mac80211_open_file_generic(struct inode *inode, struct file *file);
 #else
 static inline void debugfs_hw_add(struct ieee80211_local *local)
 {
-	return;
 }
 #endif
 
diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index 7e93524..bde8103 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -287,8 +287,6 @@ void mesh_mgmt_ies_add(struct sk_buff *skb, struct ieee80211_sub_if_data *sdata)
 	*pos++ |= sdata->u.mesh.accepting_plinks ?
 	    MESHCONF_CAPAB_ACCEPT_PLINKS : 0x00;
 	*pos++ = 0x00;
-
-	return;
 }
 
 u32 mesh_table_hash(u8 *addr, struct ieee80211_sub_if_data *sdata, struct mesh_table *tbl)
diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index d89ed7f..0705018 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -624,7 +624,6 @@ static void hwmp_prep_frame_process(struct ieee80211_sub_if_data *sdata,
 fail:
 	rcu_read_unlock();
 	sdata->u.mesh.mshstats.dropped_frames_no_route++;
-	return;
 }
 
 static void hwmp_perr_frame_process(struct ieee80211_sub_if_data *sdata,
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index 07ae7fd..1c1c093 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -130,7 +130,6 @@ static inline void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 					     int src, const char *dev,
 					     __be32 addr, __be32 mask)
 {
-	return;
 }
 #endif
 
@@ -203,7 +202,6 @@ static inline void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 					     const struct in6_addr *addr,
 					     const struct in6_addr *mask)
 {
-	return;
 }
 #endif
 #endif /* IPV6 */
diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index a3d64aa..e2b0a68 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -670,7 +670,6 @@ static void netlbl_unlhsh_condremove_iface(struct netlbl_unlhsh_iface *iface)
 
 unlhsh_condremove_failure:
 	spin_unlock(&netlbl_unlhsh_lock);
-	return;
 }
 
 /**
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6ed61b1..f73542d 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -602,7 +602,6 @@ static unsigned long flow_get(struct tcf_proto *tp, u32 handle)
 
 static void flow_put(struct tcf_proto *tp, unsigned long f)
 {
-	return;
 }
 
 static int flow_dump(struct tcf_proto *tp, unsigned long fh,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b38b39c..03c597b 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -617,7 +617,6 @@ rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 	rtsc->y = y;
 	rtsc->dx = dx;
 	rtsc->dy = dy;
-	return;
 }
 
 static void
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index a9e646b..f10e34a 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -44,7 +44,6 @@ static void ingress_put(struct Qdisc *sch, unsigned long cl)
 
 static void ingress_walk(struct Qdisc *sch, struct qdisc_walker *walker)
 {
-	return;
 }
 
 static struct tcf_proto **ingress_find_tcf(struct Qdisc *sch, unsigned long cl)
diff --git a/net/sched/sch_mq.c b/net/sched/sch_mq.c
index b2aba3f..fe91e50 100644
--- a/net/sched/sch_mq.c
+++ b/net/sched/sch_mq.c
@@ -174,7 +174,6 @@ static unsigned long mq_get(struct Qdisc *sch, u32 classid)
 
 static void mq_put(struct Qdisc *sch, unsigned long cl)
 {
-	return;
 }
 
 static int mq_dump_class(struct Qdisc *sch, unsigned long cl,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index c50876c..6ae2512 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -340,7 +340,6 @@ static unsigned long multiq_bind(struct Qdisc *sch, unsigned long parent,
 
 static void multiq_put(struct Qdisc *q, unsigned long cl)
 {
-	return;
 }
 
 static int multiq_dump_class(struct Qdisc *sch, unsigned long cl,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 81672e0..0748fb1 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -303,7 +303,6 @@ static unsigned long prio_bind(struct Qdisc *sch, unsigned long parent, u32 clas
 
 static void prio_put(struct Qdisc *q, unsigned long cl)
 {
-	return;
 }
 
 static int prio_dump_class(struct Qdisc *sch, unsigned long cl, struct sk_buff *skb,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 072cdf4..8d42bb3 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -303,7 +303,6 @@ static unsigned long red_get(struct Qdisc *sch, u32 classid)
 
 static void red_put(struct Qdisc *sch, unsigned long arg)
 {
-	return;
 }
 
 static void red_walk(struct Qdisc *sch, struct qdisc_walker *walker)
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 3912420..e41feff 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -816,8 +816,6 @@ void sctp_assoc_del_nonprimary_peers(struct sctp_association *asoc,
 		if (t != primary)
 			sctp_assoc_rm_peer(asoc, t);
 	}
-
-	return;
 }
 
 /* Engage in transport control operations.
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 5d05717..c04b2eb 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -80,7 +80,6 @@ static inline void sctp_outq_head_data(struct sctp_outq *q,
 {
 	list_add(&ch->list, &q->out_chunk_list);
 	q->out_qlen += ch->skb->len;
-	return;
 }
 
 /* Take data from the front of the queue. */
@@ -103,7 +102,6 @@ static inline void sctp_outq_tail_data(struct sctp_outq *q,
 {
 	list_add_tail(&ch->list, &q->out_chunk_list);
 	q->out_qlen += ch->skb->len;
-	return;
 }
 
 /*
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 784bcc9..61aacfb 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -181,7 +181,6 @@ static void * sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void sctp_eps_seq_stop(struct seq_file *seq, void *v)
 {
-	return;
 }
 
 
@@ -286,7 +285,6 @@ static void * sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 
 static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
 {
-	return;
 }
 
 
@@ -409,7 +407,6 @@ static void *sctp_remaddr_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 
 static void sctp_remaddr_seq_stop(struct seq_file *seq, void *v)
 {
-	return;
 }
 
 static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 3b7230e..c8f05ca 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -857,8 +857,6 @@ static void sctp_cmd_process_fwdtsn(struct sctp_ulpq *ulpq,
 	sctp_walk_fwdtsn(skip, chunk) {
 		sctp_ulpq_skip(ulpq, ntohs(skip->stream), ntohs(skip->ssn));
 	}
-
-	return;
 }
 
 /* Helper function to remove the association non-primary peer
@@ -877,8 +875,6 @@ static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
 			sctp_assoc_del_peer(asoc, &t->ipaddr);
 		}
 	}
-
-	return;
 }
 
 /* Helper function to set sk_err on a 1-1 style socket. */
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 3a44853..c7f7e49 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -955,7 +955,6 @@ void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn)
 	 * ordering and deliver them if needed.
 	 */
 	sctp_ulpq_reap_ordered(ulpq, sid);
-	return;
 }
 
 static __u16 sctp_ulpq_renege_list(struct sctp_ulpq *ulpq,
@@ -1064,7 +1063,6 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 	}
 
 	sk_mem_reclaim(asoc->base.sk);
-	return;
 }
 
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 19c9983..462462e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1518,7 +1518,6 @@ call_refreshresult(struct rpc_task *task)
 	task->tk_action = call_refresh;
 	if (status != -ETIMEDOUT)
 		rpc_delay(task, 3*HZ);
-	return;
 }
 
 static __be32 *
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ce0d5b3..76e504b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -150,7 +150,6 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 		}
 		break;
 	}
-	return;
 }
 
 /*
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 699ade6..2e3d502 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -716,7 +716,6 @@ void xprt_connect(struct rpc_task *task)
 		xprt->stat.connect_start = jiffies;
 		xprt->ops->connect(task);
 	}
-	return;
 }
 
 static void xprt_connect_status(struct rpc_task *task)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9847c30..6e0df66 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1050,8 +1050,6 @@ static inline void xs_tcp_read_common(struct rpc_xprt *xprt,
 		if (transport->tcp_flags & TCP_RCV_LAST_FRAG)
 			transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
 	}
-
-	return;
 }
 
 /*
@@ -2210,7 +2208,6 @@ static int bc_send_request(struct rpc_task *task)
 
 static void bc_close(struct rpc_xprt *xprt)
 {
-	return;
 }
 
 /*
@@ -2220,7 +2217,6 @@ static void bc_close(struct rpc_xprt *xprt)
 
 static void bc_destroy(struct rpc_xprt *xprt)
 {
-	return;
 }
 
 static struct rpc_xprt_ops xs_udp_ops = {
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 5319600..ca84212 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -82,7 +82,6 @@ static int __net_init sysctl_net_init(struct net *net)
 static void __net_exit sysctl_net_exit(struct net *net)
 {
 	WARN_ON(!list_empty(&net->sysctls.list));
-	return;
 }
 
 static struct pernet_operations sysctl_pernet_ops = {
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 1ed65db..7380c89 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -320,7 +320,6 @@ void __wimax_state_change(struct wimax_dev *wimax_dev, enum wimax_st new_state)
 out:
 	d_fnend(3, dev, "(wimax_dev %p new_state %u [old %u]) = void\n",
 		wimax_dev, new_state, old_state);
-	return;
 }
 
 
@@ -362,7 +361,6 @@ void wimax_state_change(struct wimax_dev *wimax_dev, enum wimax_st new_state)
 	if (wimax_dev->state > __WIMAX_ST_NULL)
 		__wimax_state_change(wimax_dev, new_state);
 	mutex_unlock(&wimax_dev->mutex);
-	return;
 }
 EXPORT_SYMBOL_GPL(wimax_state_change);
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 31f4ba4..9cb3914 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2209,7 +2209,6 @@ EXPORT_SYMBOL(xfrm_dst_ifdown);
 static void xfrm_link_failure(struct sk_buff *skb)
 {
 	/* Impossible. Such dst must be popped before reaches point of failure. */
-	return;
 }
 
 static struct dst_entry *xfrm_negative_advice(struct dst_entry *dst)


