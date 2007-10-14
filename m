From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 10/10] [NETFILTER]: Replace sk_buff ** with sk_buff *
Date: Sun, 14 Oct 2007 12:27:49 +0800
Message-ID: <E1Igv4v-00031H-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1438 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751692AbXJNE2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Replace sk_buff ** with sk_buff *

With all the users of the double pointers removed, this patch mops up by
finally replacing all occurances of sk_buff ** in the netfilter API by
sk_buff *.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/if_bridge.h                      |    2 
 include/linux/netfilter.h                      |   24 +++++-----
 include/linux/netfilter/nf_conntrack_amanda.h  |    2 
 include/linux/netfilter/nf_conntrack_ftp.h     |    2 
 include/linux/netfilter/nf_conntrack_h323.h    |   18 +++----
 include/linux/netfilter/nf_conntrack_irc.h     |    2 
 include/linux/netfilter/nf_conntrack_pptp.h    |    4 -
 include/linux/netfilter/nf_conntrack_sip.h     |    4 -
 include/linux/netfilter/nf_conntrack_tftp.h    |    2 
 include/linux/netfilter/x_tables.h             |    2 
 include/linux/netfilter_arp/arp_tables.h       |    2 
 include/linux/netfilter_bridge/ebtables.h      |    4 -
 include/linux/netfilter_ipv4.h                 |    4 -
 include/linux/netfilter_ipv4/ip_tables.h       |    2 
 include/linux/netfilter_ipv6/ip6_tables.h      |    2 
 include/net/ip_vs.h                            |   12 ++---
 include/net/netfilter/nf_conntrack_core.h      |   10 ++--
 include/net/netfilter/nf_conntrack_helper.h    |    2 
 include/net/netfilter/nf_nat_core.h            |    4 -
 include/net/netfilter/nf_nat_helper.h          |    6 +-
 include/net/netfilter/nf_nat_protocol.h        |    2 
 include/net/netfilter/nf_nat_rule.h            |    2 
 net/bridge/br.c                                |    2 
 net/bridge/br_input.c                          |    2 
 net/bridge/br_netfilter.c                      |   33 +++++---------
 net/bridge/netfilter/ebt_arpreply.c            |    3 -
 net/bridge/netfilter/ebt_dnat.c                |    6 +-
 net/bridge/netfilter/ebt_mark.c                |   10 ++--
 net/bridge/netfilter/ebt_redirect.c            |   10 ++--
 net/bridge/netfilter/ebt_snat.c                |   12 ++---
 net/bridge/netfilter/ebtable_broute.c          |    4 -
 net/bridge/netfilter/ebtable_filter.c          |    4 -
 net/bridge/netfilter/ebtable_nat.c             |    8 +--
 net/bridge/netfilter/ebtables.c                |   12 ++---
 net/decnet/netfilter/dn_rtmsg.c                |    4 -
 net/ipv4/ipvs/ip_vs_app.c                      |   32 ++++++-------
 net/ipv4/ipvs/ip_vs_core.c                     |   36 ++++++---------
 net/ipv4/ipvs/ip_vs_ftp.c                      |   18 +++----
 net/ipv4/ipvs/ip_vs_proto_tcp.c                |   50 +++++++++------------
 net/ipv4/ipvs/ip_vs_proto_udp.c                |   50 +++++++++------------
 net/ipv4/ipvs/ip_vs_xmit.c                     |    2 
 net/ipv4/netfilter.c                           |   58 ++++++++++++-------------
 net/ipv4/netfilter/arp_tables.c                |   20 ++++----
 net/ipv4/netfilter/arpt_mangle.c               |   16 +++---
 net/ipv4/netfilter/arptable_filter.c           |    4 -
 net/ipv4/netfilter/ip_tables.c                 |   20 ++++----
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   14 +++---
 net/ipv4/netfilter/ipt_ECN.c                   |   27 +++++------
 net/ipv4/netfilter/ipt_LOG.c                   |    4 -
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    6 +-
 net/ipv4/netfilter/ipt_NETMAP.c                |    8 +--
 net/ipv4/netfilter/ipt_REDIRECT.c              |    6 +-
 net/ipv4/netfilter/ipt_REJECT.c                |   22 ++++-----
 net/ipv4/netfilter/ipt_SAME.c                  |    4 -
 net/ipv4/netfilter/ipt_TOS.c                   |    8 +--
 net/ipv4/netfilter/ipt_TTL.c                   |    6 +-
 net/ipv4/netfilter/ipt_ULOG.c                  |    4 -
 net/ipv4/netfilter/iptable_filter.c            |   12 ++---
 net/ipv4/netfilter/iptable_mangle.c            |   22 ++++-----
 net/ipv4/netfilter/iptable_raw.c               |   12 ++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   30 ++++++------
 net/ipv4/netfilter/nf_nat_amanda.c             |    4 -
 net/ipv4/netfilter/nf_nat_core.c               |   50 ++++++++++-----------
 net/ipv4/netfilter/nf_nat_ftp.c                |   18 +++----
 net/ipv4/netfilter/nf_nat_h323.c               |   58 ++++++++++++-------------
 net/ipv4/xfrm4_output.c                        |    4 -
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   44 +++++++++---------
 net/ipv6/xfrm6_output.c                        |    4 -
 net/netfilter/nf_queue.c                       |    4 -
 net/netfilter/xt_SECMARK.c                     |    4 -
 net/netfilter/xt_TCPMSS.c                      |   52 +++++++++++-----------
 net/netfilter/xt_TRACE.c                       |    4 -
 net/sched/act_ipt.c                            |    6 --
 net/sched/sch_ingress.c                        |    5 --
 74 files changed, 469 insertions(+), 503 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 99e3a1a..58e43e5 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -107,7 +107,7 @@ struct __fdb_entry
 extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __user *));
 extern struct sk_buff *(*br_handle_frame_hook)(struct net_bridge_port *p,
 					       struct sk_buff *skb);
-extern int (*br_should_route_hook)(struct sk_buff **pskb);
+extern int (*br_should_route_hook)(struct sk_buff *skb);
 
 #endif
 
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2505348..16adac6 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -51,7 +51,7 @@ struct sk_buff;
 struct net_device;
 
 typedef unsigned int nf_hookfn(unsigned int hooknum,
-			       struct sk_buff **skb,
+			       struct sk_buff *skb,
 			       const struct net_device *in,
 			       const struct net_device *out,
 			       int (*okfn)(struct sk_buff *));
@@ -183,7 +183,7 @@ void nf_log_packet(int pf,
 		   struct nf_loginfo *li,
 		   const char *fmt, ...);
 
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 		 struct net_device *indev, struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *), int thresh);
 
@@ -195,7 +195,7 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
  *	value indicates the packet has been consumed by the hook.
  */
 static inline int nf_hook_thresh(int pf, unsigned int hook,
-				 struct sk_buff **pskb,
+				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
 				 int (*okfn)(struct sk_buff *), int thresh,
@@ -207,14 +207,14 @@ static inline int nf_hook_thresh(int pf, unsigned int hook,
 	if (list_empty(&nf_hooks[pf][hook]))
 		return 1;
 #endif
-	return nf_hook_slow(pf, hook, pskb, indev, outdev, okfn, thresh);
+	return nf_hook_slow(pf, hook, skb, indev, outdev, okfn, thresh);
 }
 
-static inline int nf_hook(int pf, unsigned int hook, struct sk_buff **pskb,
+static inline int nf_hook(int pf, unsigned int hook, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, pskb, indev, outdev, okfn, INT_MIN, 1);
+	return nf_hook_thresh(pf, hook, skb, indev, outdev, okfn, INT_MIN, 1);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -241,13 +241,13 @@ static inline int nf_hook(int pf, unsigned int hook, struct sk_buff **pskb,
 
 #define NF_HOOK_THRESH(pf, hook, skb, indev, outdev, okfn, thresh)	       \
 ({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, thresh, 1)) == 1)\
+if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, thresh, 1)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
 
 #define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)		       \
 ({int __ret;								       \
-if ((__ret=nf_hook_thresh(pf, hook, &(skb), indev, outdev, okfn, INT_MIN, cond)) == 1)\
+if ((__ret=nf_hook_thresh(pf, hook, (skb), indev, outdev, okfn, INT_MIN, cond)) == 1)\
 	__ret = (okfn)(skb);						       \
 __ret;})
 
@@ -317,7 +317,7 @@ struct nf_afinfo {
 				    unsigned int dataoff, u_int8_t protocol);
 	void		(*saveroute)(const struct sk_buff *skb,
 				     struct nf_info *info);
-	int		(*reroute)(struct sk_buff **skb,
+	int		(*reroute)(struct sk_buff *skb,
 				   const struct nf_info *info);
 	int		route_key_size;
 };
@@ -371,15 +371,15 @@ extern struct proc_dir_entry *proc_net_netfilter;
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 #define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
 static inline int nf_hook_thresh(int pf, unsigned int hook,
-				 struct sk_buff **pskb,
+				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
 				 int (*okfn)(struct sk_buff *), int thresh,
 				 int cond)
 {
-	return okfn(*pskb);
+	return okfn(skb);
 }
-static inline int nf_hook(int pf, unsigned int hook, struct sk_buff **pskb,
+static inline int nf_hook(int pf, unsigned int hook, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sk_buff *))
 {
diff --git a/include/linux/netfilter/nf_conntrack_amanda.h b/include/linux/netfilter/nf_conntrack_amanda.h
index 26c2235..0bb5a69 100644
--- a/include/linux/netfilter/nf_conntrack_amanda.h
+++ b/include/linux/netfilter/nf_conntrack_amanda.h
@@ -2,7 +2,7 @@
 #define _NF_CONNTRACK_AMANDA_H
 /* AMANDA tracking. */
 
-extern unsigned int (*nf_nat_amanda_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
 					  enum ip_conntrack_info ctinfo,
 					  unsigned int matchoff,
 					  unsigned int matchlen,
diff --git a/include/linux/netfilter/nf_conntrack_ftp.h b/include/linux/netfilter/nf_conntrack_ftp.h
index b7c360f..47727d7 100644
--- a/include/linux/netfilter/nf_conntrack_ftp.h
+++ b/include/linux/netfilter/nf_conntrack_ftp.h
@@ -32,7 +32,7 @@ struct nf_conntrack_expect;
 
 /* For NAT to hook in when we find a packet which describes what other
  * connection we should expect. */
-extern unsigned int (*nf_nat_ftp_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       enum nf_ct_ftp_type type,
 				       unsigned int matchoff,
diff --git a/include/linux/netfilter/nf_conntrack_h323.h b/include/linux/netfilter/nf_conntrack_h323.h
index 08e2f49..aabd24a 100644
--- a/include/linux/netfilter/nf_conntrack_h323.h
+++ b/include/linux/netfilter/nf_conntrack_h323.h
@@ -36,27 +36,27 @@ extern void nf_conntrack_h245_expect(struct nf_conn *new,
 				     struct nf_conntrack_expect *this);
 extern void nf_conntrack_q931_expect(struct nf_conn *new,
 				     struct nf_conntrack_expect *this);
-extern int (*set_h245_addr_hook) (struct sk_buff **pskb,
+extern int (*set_h245_addr_hook) (struct sk_buff *skb,
 				  unsigned char **data, int dataoff,
 				  H245_TransportAddress *taddr,
 				  union nf_conntrack_address *addr,
 				  __be16 port);
-extern int (*set_h225_addr_hook) (struct sk_buff **pskb,
+extern int (*set_h225_addr_hook) (struct sk_buff *skb,
 				  unsigned char **data, int dataoff,
 				  TransportAddress *taddr,
 				  union nf_conntrack_address *addr,
 				  __be16 port);
-extern int (*set_sig_addr_hook) (struct sk_buff **pskb,
+extern int (*set_sig_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned char **data,
 				 TransportAddress *taddr, int count);
-extern int (*set_ras_addr_hook) (struct sk_buff **pskb,
+extern int (*set_ras_addr_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned char **data,
 				 TransportAddress *taddr, int count);
-extern int (*nat_rtp_rtcp_hook) (struct sk_buff **pskb,
+extern int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned char **data, int dataoff,
@@ -64,24 +64,24 @@ extern int (*nat_rtp_rtcp_hook) (struct sk_buff **pskb,
 				 __be16 port, __be16 rtp_port,
 				 struct nf_conntrack_expect *rtp_exp,
 				 struct nf_conntrack_expect *rtcp_exp);
-extern int (*nat_t120_hook) (struct sk_buff **pskb, struct nf_conn *ct,
+extern int (*nat_t120_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
 			     unsigned char **data, int dataoff,
 			     H245_TransportAddress *taddr, __be16 port,
 			     struct nf_conntrack_expect *exp);
-extern int (*nat_h245_hook) (struct sk_buff **pskb, struct nf_conn *ct,
+extern int (*nat_h245_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
 			     unsigned char **data, int dataoff,
 			     TransportAddress *taddr, __be16 port,
 			     struct nf_conntrack_expect *exp);
-extern int (*nat_callforwarding_hook) (struct sk_buff **pskb,
+extern int (*nat_callforwarding_hook) (struct sk_buff *skb,
 				       struct nf_conn *ct,
 				       enum ip_conntrack_info ctinfo,
 				       unsigned char **data, int dataoff,
 				       TransportAddress *taddr,
 				       __be16 port,
 				       struct nf_conntrack_expect *exp);
-extern int (*nat_q931_hook) (struct sk_buff **pskb, struct nf_conn *ct,
+extern int (*nat_q931_hook) (struct sk_buff *skb, struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo,
 			     unsigned char **data, TransportAddress *taddr,
 			     int idx, __be16 port,
diff --git a/include/linux/netfilter/nf_conntrack_irc.h b/include/linux/netfilter/nf_conntrack_irc.h
index 2ab6b82..36282bf 100644
--- a/include/linux/netfilter/nf_conntrack_irc.h
+++ b/include/linux/netfilter/nf_conntrack_irc.h
@@ -5,7 +5,7 @@
 
 #define IRC_PORT	6667
 
-extern unsigned int (*nf_nat_irc_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_irc_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       unsigned int matchoff,
 				       unsigned int matchlen,
diff --git a/include/linux/netfilter/nf_conntrack_pptp.h b/include/linux/netfilter/nf_conntrack_pptp.h
index c93061f..2343549 100644
--- a/include/linux/netfilter/nf_conntrack_pptp.h
+++ b/include/linux/netfilter/nf_conntrack_pptp.h
@@ -301,13 +301,13 @@ struct nf_conn;
 struct nf_conntrack_expect;
 
 extern int
-(*nf_nat_pptp_hook_outbound)(struct sk_buff **pskb,
+(*nf_nat_pptp_hook_outbound)(struct sk_buff *skb,
 			     struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			     struct PptpControlHeader *ctlh,
 			     union pptp_ctrl_union *pptpReq);
 
 extern int
-(*nf_nat_pptp_hook_inbound)(struct sk_buff **pskb,
+(*nf_nat_pptp_hook_inbound)(struct sk_buff *skb,
 			    struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			    struct PptpControlHeader *ctlh,
 			    union pptp_ctrl_union *pptpReq);
diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index bb7f204..9fff197 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -21,11 +21,11 @@ enum sip_header_pos {
 	POS_SDP_HEADER,
 };
 
-extern unsigned int (*nf_nat_sip_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       struct nf_conn *ct,
 				       const char **dptr);
-extern unsigned int (*nf_nat_sdp_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_sdp_hook)(struct sk_buff *skb,
 				       enum ip_conntrack_info ctinfo,
 				       struct nf_conntrack_expect *exp,
 				       const char *dptr);
diff --git a/include/linux/netfilter/nf_conntrack_tftp.h b/include/linux/netfilter/nf_conntrack_tftp.h
index 0d79b7a..c78d38f 100644
--- a/include/linux/netfilter/nf_conntrack_tftp.h
+++ b/include/linux/netfilter/nf_conntrack_tftp.h
@@ -13,7 +13,7 @@ struct tftphdr {
 #define TFTP_OPCODE_ACK		4
 #define TFTP_OPCODE_ERROR	5
 
-extern unsigned int (*nf_nat_tftp_hook)(struct sk_buff **pskb,
+extern unsigned int (*nf_nat_tftp_hook)(struct sk_buff *skb,
 				        enum ip_conntrack_info ctinfo,
 				        struct nf_conntrack_expect *exp);
 
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 64f425a..03e6ce9 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -191,7 +191,7 @@ struct xt_target
 	/* Returns verdict. Argument order changed since 2.6.9, as this
 	   must now handle non-linear skbs, using skb_copy_bits and
 	   skb_ip_make_writable. */
-	unsigned int (*target)(struct sk_buff **pskb,
+	unsigned int (*target)(struct sk_buff *skb,
 			       const struct net_device *in,
 			       const struct net_device *out,
 			       unsigned int hooknum,
diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 584cd1b..2fc73fa 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -287,7 +287,7 @@ struct arpt_error
 extern int arpt_register_table(struct arpt_table *table,
 			       const struct arpt_replace *repl);
 extern void arpt_unregister_table(struct arpt_table *table);
-extern unsigned int arpt_do_table(struct sk_buff **pskb,
+extern unsigned int arpt_do_table(struct sk_buff *skb,
 				  unsigned int hook,
 				  const struct net_device *in,
 				  const struct net_device *out,
diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 94e0a7d..892f5b7 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -237,7 +237,7 @@ struct ebt_target
 	struct list_head list;
 	const char name[EBT_FUNCTION_MAXNAMELEN];
 	/* returns one of the standard verdicts */
-	int (*target)(struct sk_buff **pskb, unsigned int hooknr,
+	int (*target)(struct sk_buff *skb, unsigned int hooknr,
 	   const struct net_device *in, const struct net_device *out,
 	   const void *targetdata, unsigned int datalen);
 	/* 0 == let it in */
@@ -294,7 +294,7 @@ extern int ebt_register_watcher(struct ebt_watcher *watcher);
 extern void ebt_unregister_watcher(struct ebt_watcher *watcher);
 extern int ebt_register_target(struct ebt_target *target);
 extern void ebt_unregister_target(struct ebt_target *target);
-extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff **pskb,
+extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
    struct ebt_table *table);
 
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index ceae87a..1a63adf 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -75,8 +75,8 @@ enum nf_ip_hook_priorities {
 #define SO_ORIGINAL_DST 80
 
 #ifdef __KERNEL__
-extern int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type);
-extern int ip_xfrm_me_harder(struct sk_buff **pskb);
+extern int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type);
+extern int ip_xfrm_me_harder(struct sk_buff *skb);
 extern __sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
 				   unsigned int dataoff, u_int8_t protocol);
 #endif /*__KERNEL__*/
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index e992cd6..d79ed69 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -337,7 +337,7 @@ struct ipt_error
 	.target.errorname = "ERROR",					       \
 }
 
-extern unsigned int ipt_do_table(struct sk_buff **pskb,
+extern unsigned int ipt_do_table(struct sk_buff *skb,
 				 unsigned int hook,
 				 const struct net_device *in,
 				 const struct net_device *out,
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 9a720f0..7dc481c 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -336,7 +336,7 @@ extern void ip6t_init(void) __init;
 extern int ip6t_register_table(struct xt_table *table,
 			       const struct ip6t_replace *repl);
 extern void ip6t_unregister_table(struct xt_table *table);
-extern unsigned int ip6t_do_table(struct sk_buff **pskb,
+extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  unsigned int hook,
 				  const struct net_device *in,
 				  const struct net_device *out,
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 5da3b4a..4187056 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -464,10 +464,10 @@ struct ip_vs_protocol {
 			unsigned int proto_off,
 			int inverse);
 
-	int (*snat_handler)(struct sk_buff **pskb,
+	int (*snat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
-	int (*dnat_handler)(struct sk_buff **pskb,
+	int (*dnat_handler)(struct sk_buff *skb,
 			    struct ip_vs_protocol *pp, struct ip_vs_conn *cp);
 
 	int (*csum_check)(struct sk_buff *skb, struct ip_vs_protocol *pp);
@@ -654,11 +654,11 @@ struct ip_vs_app
 
 	/* output hook: return false if can't linearize. diff set for TCP.  */
 	int (*pkt_out)(struct ip_vs_app *, struct ip_vs_conn *,
-		       struct sk_buff **, int *diff);
+		       struct sk_buff *, int *diff);
 
 	/* input hook: return false if can't linearize. diff set for TCP. */
 	int (*pkt_in)(struct ip_vs_app *, struct ip_vs_conn *,
-		      struct sk_buff **, int *diff);
+		      struct sk_buff *, int *diff);
 
 	/* ip_vs_app initializer */
 	int (*init_conn)(struct ip_vs_app *, struct ip_vs_conn *);
@@ -832,8 +832,8 @@ register_ip_vs_app_inc(struct ip_vs_app *app, __u16 proto, __u16 port);
 extern int ip_vs_app_inc_get(struct ip_vs_app *inc);
 extern void ip_vs_app_inc_put(struct ip_vs_app *inc);
 
-extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff **pskb);
-extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff **pskb);
+extern int ip_vs_app_pkt_out(struct ip_vs_conn *, struct sk_buff *skb);
+extern int ip_vs_app_pkt_in(struct ip_vs_conn *, struct sk_buff *skb);
 extern int ip_vs_skb_replace(struct sk_buff *skb, gfp_t pri,
 			     char *o_buf, int o_len, char *n_buf, int n_len);
 extern int ip_vs_app_init(void);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 4056f5f..a532e7b 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -22,7 +22,7 @@
    of connection tracking. */
 extern unsigned int nf_conntrack_in(int pf,
 				    unsigned int hooknum,
-				    struct sk_buff **pskb);
+				    struct sk_buff *skb);
 
 extern int nf_conntrack_init(void);
 extern void nf_conntrack_cleanup(void);
@@ -60,17 +60,17 @@ nf_ct_invert_tuple(struct nf_conntrack_tuple *inverse,
 extern struct nf_conntrack_tuple_hash *
 nf_conntrack_find_get(const struct nf_conntrack_tuple *tuple);
 
-extern int __nf_conntrack_confirm(struct sk_buff **pskb);
+extern int __nf_conntrack_confirm(struct sk_buff *skb);
 
 /* Confirm a connection: returns NF_DROP if packet must be dropped. */
-static inline int nf_conntrack_confirm(struct sk_buff **pskb)
+static inline int nf_conntrack_confirm(struct sk_buff *skb)
 {
-	struct nf_conn *ct = (struct nf_conn *)(*pskb)->nfct;
+	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
 	int ret = NF_ACCEPT;
 
 	if (ct) {
 		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
-			ret = __nf_conntrack_confirm(pskb);
+			ret = __nf_conntrack_confirm(skb);
 		nf_ct_deliver_cached_events(ct);
 	}
 	return ret;
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 0dcc4c8..d7b2d54 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -29,7 +29,7 @@ struct nf_conntrack_helper
 
 	/* Function to call when data passes; return verdict, or -1 to
            invalidate. */
-	int (*help)(struct sk_buff **pskb,
+	int (*help)(struct sk_buff *skb,
 		    unsigned int protoff,
 		    struct nf_conn *ct,
 		    enum ip_conntrack_info conntrackinfo);
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index c3cd127..f29eeb9 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -10,12 +10,12 @@
 extern unsigned int nf_nat_packet(struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
 				  unsigned int hooknum,
-				  struct sk_buff **pskb);
+				  struct sk_buff *skb);
 
 extern int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 					 enum ip_conntrack_info ctinfo,
 					 unsigned int hooknum,
-					 struct sk_buff **pskb);
+					 struct sk_buff *skb);
 
 static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
diff --git a/include/net/netfilter/nf_nat_helper.h b/include/net/netfilter/nf_nat_helper.h
index ec98ecf..58dd226 100644
--- a/include/net/netfilter/nf_nat_helper.h
+++ b/include/net/netfilter/nf_nat_helper.h
@@ -7,21 +7,21 @@
 struct sk_buff;
 
 /* These return true or false. */
-extern int nf_nat_mangle_tcp_packet(struct sk_buff **skb,
+extern int nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 				    struct nf_conn *ct,
 				    enum ip_conntrack_info ctinfo,
 				    unsigned int match_offset,
 				    unsigned int match_len,
 				    const char *rep_buffer,
 				    unsigned int rep_len);
-extern int nf_nat_mangle_udp_packet(struct sk_buff **skb,
+extern int nf_nat_mangle_udp_packet(struct sk_buff *skb,
 				    struct nf_conn *ct,
 				    enum ip_conntrack_info ctinfo,
 				    unsigned int match_offset,
 				    unsigned int match_len,
 				    const char *rep_buffer,
 				    unsigned int rep_len);
-extern int nf_nat_seq_adjust(struct sk_buff **pskb,
+extern int nf_nat_seq_adjust(struct sk_buff *skb,
 			     struct nf_conn *ct,
 			     enum ip_conntrack_info ctinfo);
 
diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index 14c7b2d..04578bf 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -18,7 +18,7 @@ struct nf_nat_protocol
 
 	/* Translate a packet to the target according to manip type.
 	   Return true if succeeded. */
-	int (*manip_pkt)(struct sk_buff **pskb,
+	int (*manip_pkt)(struct sk_buff *skb,
 			 unsigned int iphdroff,
 			 const struct nf_conntrack_tuple *tuple,
 			 enum nf_nat_manip_type maniptype);
diff --git a/include/net/netfilter/nf_nat_rule.h b/include/net/netfilter/nf_nat_rule.h
index f974318..75d1825 100644
--- a/include/net/netfilter/nf_nat_rule.h
+++ b/include/net/netfilter/nf_nat_rule.h
@@ -6,7 +6,7 @@
 
 extern int nf_nat_rule_init(void) __init;
 extern void nf_nat_rule_cleanup(void);
-extern int nf_nat_rule_find(struct sk_buff **pskb,
+extern int nf_nat_rule_find(struct sk_buff *skb,
 			    unsigned int hooknum,
 			    const struct net_device *in,
 			    const struct net_device *out,
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 848b8fa..93867bb 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -23,7 +23,7 @@
 
 #include "br_private.h"
 
-int (*br_should_route_hook) (struct sk_buff **pskb) = NULL;
+int (*br_should_route_hook)(struct sk_buff *skb);
 
 static struct llc_sap *br_stp_sap;
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f8e0a2f..3cedd4e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -149,7 +149,7 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 	case BR_STATE_FORWARDING:
 
 		if (br_should_route_hook) {
-			if (br_should_route_hook(&skb))
+			if (br_should_route_hook(skb))
 				return skb;
 			dest = eth_hdr(skb)->h_dest;
 		}
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8245f05..246bf23 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -503,13 +503,12 @@ inhdr_error:
  * receiving device) to make netfilter happy, the REDIRECT
  * target in particular.  Save the original destination IP
  * address to be able to detect DNAT afterwards. */
-static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
 	struct iphdr *iph;
-	struct sk_buff *skb = *pskb;
 	__u32 len = nf_bridge_encap_header_len(skb);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
@@ -584,13 +583,11 @@ out:
  * took place when the packet entered the bridge), but we
  * register an IPv4 PRE_ROUTING 'sabotage' hook that will
  * prevent this from happening. */
-static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *in,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff *skb = *pskb;
-
 	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -625,12 +622,11 @@ static int br_nf_forward_finish(struct sk_buff *skb)
  * but we are still able to filter on the 'real' indev/outdev
  * because of the physdev module. For ARP, indev and outdev are the
  * bridge ports. */
-static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 				     const struct net_device *in,
 				     const struct net_device *out,
 				     int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 	struct net_device *parent;
 	int pf;
@@ -648,7 +644,7 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff **pskb,
 	else
 		pf = PF_INET6;
 
-	nf_bridge_pull_encap_header(*pskb);
+	nf_bridge_pull_encap_header(skb);
 
 	nf_bridge = skb->nf_bridge;
 	if (skb->pkt_type == PACKET_OTHERHOST) {
@@ -666,12 +662,11 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff **pskb,
 	return NF_STOLEN;
 }
 
-static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff *skb = *pskb;
 	struct net_device **d = (struct net_device **)(skb->cb);
 
 #ifdef CONFIG_SYSCTL
@@ -682,12 +677,12 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff **pskb,
 	if (skb->protocol != htons(ETH_P_ARP)) {
 		if (!IS_VLAN_ARP(skb))
 			return NF_ACCEPT;
-		nf_bridge_pull_encap_header(*pskb);
+		nf_bridge_pull_encap_header(skb);
 	}
 
 	if (arp_hdr(skb)->ar_pln != 4) {
 		if (IS_VLAN_ARP(skb))
-			nf_bridge_push_encap_header(*pskb);
+			nf_bridge_push_encap_header(skb);
 		return NF_ACCEPT;
 	}
 	*d = (struct net_device *)in;
@@ -709,13 +704,12 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff **pskb,
  * NF_BR_PRI_FIRST, so no relevant PF_BRIDGE/INPUT functions have been nor
  * will be executed.
  */
-static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    int (*okfn)(struct sk_buff *))
 {
 	struct net_device *realindev;
-	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 
 	if (!skb->nf_bridge)
@@ -752,13 +746,12 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
-static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff **pskb,
+static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 				       const struct net_device *in,
 				       const struct net_device *out,
 				       int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff *skb = *pskb;
-	struct nf_bridge_info *nf_bridge = (*pskb)->nf_bridge;
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	int pf;
 
@@ -828,13 +821,13 @@ print_error:
 /* IP/SABOTAGE *****************************************************/
 /* Don't hand locally destined packets to PF_INET(6)/PRE_ROUTING
  * for the second time. */
-static unsigned int ip_sabotage_in(unsigned int hook, struct sk_buff **pskb,
+static unsigned int ip_sabotage_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *in,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if ((*pskb)->nf_bridge &&
-	    !((*pskb)->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
+	if (skb->nf_bridge &&
+	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
 		return NF_STOP;
 	}
 
diff --git a/net/bridge/netfilter/ebt_arpreply.c b/net/bridge/netfilter/ebt_arpreply.c
index ffe468a..48a80e4 100644
--- a/net/bridge/netfilter/ebt_arpreply.c
+++ b/net/bridge/netfilter/ebt_arpreply.c
@@ -15,7 +15,7 @@
 #include <net/arp.h>
 #include <linux/module.h>
 
-static int ebt_target_reply(struct sk_buff **pskb, unsigned int hooknr,
+static int ebt_target_reply(struct sk_buff *skb, unsigned int hooknr,
    const struct net_device *in, const struct net_device *out,
    const void *data, unsigned int datalen)
 {
@@ -23,7 +23,6 @@ static int ebt_target_reply(struct sk_buff **pskb, unsigned int hooknr,
 	__be32 _sip, *siptr, _dip, *diptr;
 	struct arphdr _ah, *ap;
 	unsigned char _sha[ETH_ALEN], *shp;
-	struct sk_buff *skb = *pskb;
 
 	ap = skb_header_pointer(skb, 0, sizeof(_ah), &_ah);
 	if (ap == NULL)
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 9d74dee..74262e9 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -14,16 +14,16 @@
 #include <linux/module.h>
 #include <net/sock.h>
 
-static int ebt_target_dnat(struct sk_buff **pskb, unsigned int hooknr,
+static int ebt_target_dnat(struct sk_buff *skb, unsigned int hooknr,
    const struct net_device *in, const struct net_device *out,
    const void *data, unsigned int datalen)
 {
 	struct ebt_nat_info *info = (struct ebt_nat_info *)data;
 
-	if (skb_make_writable(*pskb, 0))
+	if (skb_make_writable(skb, 0))
 		return NF_DROP;
 
-	memcpy(eth_hdr(*pskb)->h_dest, info->mac, ETH_ALEN);
+	memcpy(eth_hdr(skb)->h_dest, info->mac, ETH_ALEN);
 	return info->target;
 }
 
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index 62d23c7..6cba543 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter_bridge/ebt_mark_t.h>
 #include <linux/module.h>
 
-static int ebt_target_mark(struct sk_buff **pskb, unsigned int hooknr,
+static int ebt_target_mark(struct sk_buff *skb, unsigned int hooknr,
    const struct net_device *in, const struct net_device *out,
    const void *data, unsigned int datalen)
 {
@@ -25,13 +25,13 @@ static int ebt_target_mark(struct sk_buff **pskb, unsigned int hooknr,
 	int action = info->target & -16;
 
 	if (action == MARK_SET_VALUE)
-		(*pskb)->mark = info->mark;
+		skb->mark = info->mark;
 	else if (action == MARK_OR_VALUE)
-		(*pskb)->mark |= info->mark;
+		skb->mark |= info->mark;
 	else if (action == MARK_AND_VALUE)
-		(*pskb)->mark &= info->mark;
+		skb->mark &= info->mark;
 	else
-		(*pskb)->mark ^= info->mark;
+		skb->mark ^= info->mark;
 
 	return info->target | ~EBT_VERDICT_BITS;
 }
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 81371cd..422cb83 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -15,21 +15,21 @@
 #include <net/sock.h>
 #include "../br_private.h"
 
-static int ebt_target_redirect(struct sk_buff **pskb, unsigned int hooknr,
+static int ebt_target_redirect(struct sk_buff *skb, unsigned int hooknr,
    const struct net_device *in, const struct net_device *out,
    const void *data, unsigned int datalen)
 {
 	struct ebt_redirect_info *info = (struct ebt_redirect_info *)data;
 
-	if (skb_make_writable(*pskb, 0))
+	if (skb_make_writable(skb, 0))
 		return NF_DROP;
 
 	if (hooknr != NF_BR_BROUTING)
-		memcpy(eth_hdr(*pskb)->h_dest,
+		memcpy(eth_hdr(skb)->h_dest,
 		       in->br_port->br->dev->dev_addr, ETH_ALEN);
 	else
-		memcpy(eth_hdr(*pskb)->h_dest, in->dev_addr, ETH_ALEN);
-	(*pskb)->pkt_type = PACKET_HOST;
+		memcpy(eth_hdr(skb)->h_dest, in->dev_addr, ETH_ALEN);
+	skb->pkt_type = PACKET_HOST;
 	return info->target;
 }
 
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index b0c6368..425ac92 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -16,26 +16,26 @@
 #include <linux/if_arp.h>
 #include <net/arp.h>
 
-static int ebt_target_snat(struct sk_buff **pskb, unsigned int hooknr,
+static int ebt_target_snat(struct sk_buff *skb, unsigned int hooknr,
    const struct net_device *in, const struct net_device *out,
    const void *data, unsigned int datalen)
 {
 	struct ebt_nat_info *info = (struct ebt_nat_info *) data;
 
-	if (skb_make_writable(*pskb, 0))
+	if (skb_make_writable(skb, 0))
 		return NF_DROP;
 
-	memcpy(eth_hdr(*pskb)->h_source, info->mac, ETH_ALEN);
+	memcpy(eth_hdr(skb)->h_source, info->mac, ETH_ALEN);
 	if (!(info->target & NAT_ARP_BIT) &&
-	    eth_hdr(*pskb)->h_proto == htons(ETH_P_ARP)) {
+	    eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) {
 		struct arphdr _ah, *ap;
 
-		ap = skb_header_pointer(*pskb, 0, sizeof(_ah), &_ah);
+		ap = skb_header_pointer(skb, 0, sizeof(_ah), &_ah);
 		if (ap == NULL)
 			return EBT_DROP;
 		if (ap->ar_hln != ETH_ALEN)
 			goto out;
-		if (skb_store_bits(*pskb, sizeof(_ah), info->mac,ETH_ALEN))
+		if (skb_store_bits(skb, sizeof(_ah), info->mac,ETH_ALEN))
 			return EBT_DROP;
 	}
 out:
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index d37ce04..e44519e 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -51,11 +51,11 @@ static struct ebt_table broute_table =
 	.me		= THIS_MODULE,
 };
 
-static int ebt_broute(struct sk_buff **pskb)
+static int ebt_broute(struct sk_buff *skb)
 {
 	int ret;
 
-	ret = ebt_do_table(NF_BR_BROUTING, pskb, (*pskb)->dev, NULL,
+	ret = ebt_do_table(NF_BR_BROUTING, skb, skb->dev, NULL,
 	   &broute_table);
 	if (ret == NF_DROP)
 		return 1; /* route it */
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 81d8414..210493f 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -61,10 +61,10 @@ static struct ebt_table frame_filter =
 };
 
 static unsigned int
-ebt_hook (unsigned int hook, struct sk_buff **pskb, const struct net_device *in,
+ebt_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, pskb, in, out, &frame_filter);
+	return ebt_do_table(hook, skb, in, out, &frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] = {
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 9c50488..3e58c2e 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -61,17 +61,17 @@ static struct ebt_table frame_nat =
 };
 
 static unsigned int
-ebt_nat_dst(unsigned int hook, struct sk_buff **pskb, const struct net_device *in
+ebt_nat_dst(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, pskb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, &frame_nat);
 }
 
 static unsigned int
-ebt_nat_src(unsigned int hook, struct sk_buff **pskb, const struct net_device *in
+ebt_nat_src(unsigned int hook, struct sk_buff *skb, const struct net_device *in
    , const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, pskb, in, out, &frame_nat);
+	return ebt_do_table(hook, skb, in, out, &frame_nat);
 }
 
 static struct nf_hook_ops ebt_ops_nat[] = {
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 6018d0e..d5a09ea 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -142,7 +142,7 @@ static inline int ebt_basic_match(struct ebt_entry *e, struct ethhdr *h,
 }
 
 /* Do some firewalling */
-unsigned int ebt_do_table (unsigned int hook, struct sk_buff **pskb,
+unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
    struct ebt_table *table)
 {
@@ -172,19 +172,19 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff **pskb,
 	base = private->entries;
 	i = 0;
 	while (i < nentries) {
-		if (ebt_basic_match(point, eth_hdr(*pskb), in, out))
+		if (ebt_basic_match(point, eth_hdr(skb), in, out))
 			goto letscontinue;
 
-		if (EBT_MATCH_ITERATE(point, ebt_do_match, *pskb, in, out) != 0)
+		if (EBT_MATCH_ITERATE(point, ebt_do_match, skb, in, out) != 0)
 			goto letscontinue;
 
 		/* increase counter */
 		(*(counter_base + i)).pcnt++;
-		(*(counter_base + i)).bcnt+=(**pskb).len;
+		(*(counter_base + i)).bcnt += skb->len;
 
 		/* these should only watch: not modify, nor tell us
 		   what to do with the packet */
-		EBT_WATCHER_ITERATE(point, ebt_do_watcher, *pskb, hook, in,
+		EBT_WATCHER_ITERATE(point, ebt_do_watcher, skb, hook, in,
 		   out);
 
 		t = (struct ebt_entry_target *)
@@ -193,7 +193,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff **pskb,
 		if (!t->u.target->target)
 			verdict = ((struct ebt_standard_target *)t)->verdict;
 		else
-			verdict = t->u.target->target(pskb, hook,
+			verdict = t->u.target->target(skb, hook,
 			   in, out, t->data, t->target_size);
 		if (verdict == EBT_ACCEPT) {
 			read_unlock_bh(&table->lock);
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index f7fba77..43fcd29 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -88,12 +88,12 @@ static void dnrmg_send_peer(struct sk_buff *skb)
 
 
 static unsigned int dnrmg_hook(unsigned int hook,
-			struct sk_buff **pskb,
+			struct sk_buff *skb,
 			const struct net_device *in,
 			const struct net_device *out,
 			int (*okfn)(struct sk_buff *))
 {
-	dnrmg_send_peer(*pskb);
+	dnrmg_send_peer(skb);
 	return NF_ACCEPT;
 }
 
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 8ca5f48..664cb8e 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -329,18 +329,18 @@ static inline void vs_seq_update(struct ip_vs_conn *cp, struct ip_vs_seq *vseq,
 	spin_unlock(&cp->lock);
 }
 
-static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb,
+static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff *skb,
 				  struct ip_vs_app *app)
 {
 	int diff;
-	const unsigned int tcp_offset = ip_hdrlen(*pskb);
+	const unsigned int tcp_offset = ip_hdrlen(skb);
 	struct tcphdr *th;
 	__u32 seq;
 
-	if (!skb_make_writable(*pskb, tcp_offset + sizeof(*th)))
+	if (!skb_make_writable(skb, tcp_offset + sizeof(*th)))
 		return 0;
 
-	th = (struct tcphdr *)(skb_network_header(*pskb) + tcp_offset);
+	th = (struct tcphdr *)(skb_network_header(skb) + tcp_offset);
 
 	/*
 	 *	Remember seq number in case this pkt gets resized
@@ -361,7 +361,7 @@ static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb,
 	if (app->pkt_out == NULL)
 		return 1;
 
-	if (!app->pkt_out(app, cp, pskb, &diff))
+	if (!app->pkt_out(app, cp, skb, &diff))
 		return 0;
 
 	/*
@@ -379,7 +379,7 @@ static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb,
  *	called by ipvs packet handler, assumes previously checked cp!=NULL
  *	returns false if it can't handle packet (oom)
  */
-int ip_vs_app_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb)
+int ip_vs_app_pkt_out(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_app *app;
 
@@ -392,7 +392,7 @@ int ip_vs_app_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb)
 
 	/* TCP is complicated */
 	if (cp->protocol == IPPROTO_TCP)
-		return app_tcp_pkt_out(cp, pskb, app);
+		return app_tcp_pkt_out(cp, skb, app);
 
 	/*
 	 *	Call private output hook function
@@ -400,22 +400,22 @@ int ip_vs_app_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb)
 	if (app->pkt_out == NULL)
 		return 1;
 
-	return app->pkt_out(app, cp, pskb, NULL);
+	return app->pkt_out(app, cp, skb, NULL);
 }
 
 
-static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb,
+static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff *skb,
 				 struct ip_vs_app *app)
 {
 	int diff;
-	const unsigned int tcp_offset = ip_hdrlen(*pskb);
+	const unsigned int tcp_offset = ip_hdrlen(skb);
 	struct tcphdr *th;
 	__u32 seq;
 
-	if (!skb_make_writable(*pskb, tcp_offset + sizeof(*th)))
+	if (!skb_make_writable(skb, tcp_offset + sizeof(*th)))
 		return 0;
 
-	th = (struct tcphdr *)(skb_network_header(*pskb) + tcp_offset);
+	th = (struct tcphdr *)(skb_network_header(skb) + tcp_offset);
 
 	/*
 	 *	Remember seq number in case this pkt gets resized
@@ -436,7 +436,7 @@ static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb,
 	if (app->pkt_in == NULL)
 		return 1;
 
-	if (!app->pkt_in(app, cp, pskb, &diff))
+	if (!app->pkt_in(app, cp, skb, &diff))
 		return 0;
 
 	/*
@@ -454,7 +454,7 @@ static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb,
  *	called by ipvs packet handler, assumes previously checked cp!=NULL.
  *	returns false if can't handle packet (oom).
  */
-int ip_vs_app_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb)
+int ip_vs_app_pkt_in(struct ip_vs_conn *cp, struct sk_buff *skb)
 {
 	struct ip_vs_app *app;
 
@@ -467,7 +467,7 @@ int ip_vs_app_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb)
 
 	/* TCP is complicated */
 	if (cp->protocol == IPPROTO_TCP)
-		return app_tcp_pkt_in(cp, pskb, app);
+		return app_tcp_pkt_in(cp, skb, app);
 
 	/*
 	 *	Call private input hook function
@@ -475,7 +475,7 @@ int ip_vs_app_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb)
 	if (app->pkt_in == NULL)
 		return 1;
 
-	return app->pkt_in(app, cp, pskb, NULL);
+	return app->pkt_in(app, cp, skb, NULL);
 }
 
 
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 09cac38..c6ed765 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -488,12 +488,12 @@ int ip_vs_leave(struct ip_vs_service *svc, struct sk_buff *skb,
  *      for VS/NAT.
  */
 static unsigned int ip_vs_post_routing(unsigned int hooknum,
-				       struct sk_buff **pskb,
+				       struct sk_buff *skb,
 				       const struct net_device *in,
 				       const struct net_device *out,
 				       int (*okfn)(struct sk_buff *))
 {
-	if (!((*pskb)->ipvs_property))
+	if (!skb->ipvs_property)
 		return NF_ACCEPT;
 	/* The packet was sent from IPVS, exit this chain */
 	return NF_STOP;
@@ -569,9 +569,8 @@ void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  *	(Only used in VS/NAT)
  */
-static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
+static int ip_vs_out_icmp(struct sk_buff *skb, int *related)
 {
-	struct sk_buff *skb = *pskb;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -685,11 +684,10 @@ static inline int is_tcp_reset(const struct sk_buff *skb)
  *      rewrite addresses of the packet and send it on its way...
  */
 static unsigned int
-ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
+ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 	  const struct net_device *in, const struct net_device *out,
 	  int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff  *skb = *pskb;
 	struct iphdr	*iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
@@ -702,11 +700,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 
 	iph = ip_hdr(skb);
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_out_icmp(pskb, &related);
+		int related, verdict = ip_vs_out_icmp(skb, &related);
 
 		if (related)
 			return verdict;
-		skb = *pskb;
 		iph = ip_hdr(skb);
 	}
 
@@ -765,9 +762,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 		goto drop;
 
 	/* mangle the packet */
-	if (pp->snat_handler && !pp->snat_handler(pskb, pp, cp))
+	if (pp->snat_handler && !pp->snat_handler(skb, pp, cp))
 		goto drop;
-	skb = *pskb;
 	ip_hdr(skb)->saddr = cp->vaddr;
 	ip_send_check(ip_hdr(skb));
 
@@ -777,9 +773,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
-	if (ip_route_me_harder(pskb, RTN_LOCAL) != 0)
+	if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
 		goto drop;
-	skb = *pskb;
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
@@ -794,7 +789,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 
   drop:
 	ip_vs_conn_put(cp);
-	kfree_skb(*pskb);
+	kfree_skb(skb);
 	return NF_STOLEN;
 }
 
@@ -806,9 +801,8 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
  *	Currently handles error types - unreachable, quench, ttl exceeded.
  */
 static int
-ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
+ip_vs_in_icmp(struct sk_buff *skb, int *related, unsigned int hooknum)
 {
-	struct sk_buff *skb = *pskb;
 	struct iphdr *iph;
 	struct icmphdr	_icmph, *ic;
 	struct iphdr	_ciph, *cih;	/* The ip header contained within the ICMP */
@@ -901,11 +895,10 @@ ip_vs_in_icmp(struct sk_buff **pskb, int *related, unsigned int hooknum)
  *	and send it on its way...
  */
 static unsigned int
-ip_vs_in(unsigned int hooknum, struct sk_buff **pskb,
+ip_vs_in(unsigned int hooknum, struct sk_buff *skb,
 	 const struct net_device *in, const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff	*skb = *pskb;
 	struct iphdr	*iph;
 	struct ip_vs_protocol *pp;
 	struct ip_vs_conn *cp;
@@ -927,11 +920,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff **pskb,
 
 	iph = ip_hdr(skb);
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
-		int related, verdict = ip_vs_in_icmp(pskb, &related, hooknum);
+		int related, verdict = ip_vs_in_icmp(skb, &related, hooknum);
 
 		if (related)
 			return verdict;
-		skb = *pskb;
 		iph = ip_hdr(skb);
 	}
 
@@ -1012,16 +1004,16 @@ ip_vs_in(unsigned int hooknum, struct sk_buff **pskb,
  *      and send them to ip_vs_in_icmp.
  */
 static unsigned int
-ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff **pskb,
+ip_vs_forward_icmp(unsigned int hooknum, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
 	int r;
 
-	if (ip_hdr(*pskb)->protocol != IPPROTO_ICMP)
+	if (ip_hdr(skb)->protocol != IPPROTO_ICMP)
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp(pskb, &r, hooknum);
+	return ip_vs_in_icmp(skb, &r, hooknum);
 }
 
 
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index 4167d41..59aa166 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -136,7 +136,7 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
  * xxx,xxx,xxx,xxx is the server address, ppp,ppp is the server port number.
  */
 static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
-			 struct sk_buff **pskb, int *diff)
+			 struct sk_buff *skb, int *diff)
 {
 	struct iphdr *iph;
 	struct tcphdr *th;
@@ -156,14 +156,14 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 
 	/* Linear packets are much easier to deal with. */
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
 	if (cp->app_data == &ip_vs_ftp_pasv) {
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 		th = (struct tcphdr *)&(((char *)iph)[iph->ihl*4]);
 		data = (char *)th + (th->doff << 2);
-		data_limit = skb_tail_pointer(*pskb);
+		data_limit = skb_tail_pointer(skb);
 
 		if (ip_vs_ftp_get_addrport(data, data_limit,
 					   SERVER_STRING,
@@ -214,7 +214,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 			memcpy(start, buf, buf_len);
 			ret = 1;
 		} else {
-			ret = !ip_vs_skb_replace(*pskb, GFP_ATOMIC, start,
+			ret = !ip_vs_skb_replace(skb, GFP_ATOMIC, start,
 					  end-start, buf, buf_len);
 		}
 
@@ -239,7 +239,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
  * the client.
  */
 static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
-			struct sk_buff **pskb, int *diff)
+			struct sk_buff *skb, int *diff)
 {
 	struct iphdr *iph;
 	struct tcphdr *th;
@@ -257,20 +257,20 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 
 	/* Linear packets are much easier to deal with. */
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
 	/*
 	 * Detecting whether it is passive
 	 */
-	iph = ip_hdr(*pskb);
+	iph = ip_hdr(skb);
 	th = (struct tcphdr *)&(((char *)iph)[iph->ihl*4]);
 
 	/* Since there may be OPTIONS in the TCP packet and the HLEN is
 	   the length of the header in 32-bit multiples, it is accurate
 	   to calculate data address by th+HLEN*4 */
 	data = data_start = (char *)th + (th->doff << 2);
-	data_limit = skb_tail_pointer(*pskb);
+	data_limit = skb_tail_pointer(skb);
 
 	while (data <= data_limit - 6) {
 		if (strnicmp(data, "PASV\r\n", 6) == 0) {
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index b65b1a3..12dc0d6 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -123,27 +123,27 @@ tcp_fast_csum_update(struct tcphdr *tcph, __be32 oldip, __be32 newip,
 
 
 static int
-tcp_snat_handler(struct sk_buff **pskb,
+tcp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
-	const unsigned int tcphoff = ip_hdrlen(*pskb);
+	const unsigned int tcphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
-	if (!skb_make_writable(*pskb, tcphoff+sizeof(*tcph)))
+	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(skb, pp))
 			return 0;
 
 		/* Call application helper if needed */
-		if (!ip_vs_app_pkt_out(cp, pskb))
+		if (!ip_vs_app_pkt_out(cp, skb))
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(*pskb) + tcphoff;
+	tcph = (void *)ip_hdr(skb) + tcphoff;
 	tcph->source = cp->vport;
 
 	/* Adjust TCP checksums */
@@ -151,17 +151,15 @@ tcp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
-			(*pskb)->ip_summed = CHECKSUM_NONE;
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		tcph->check = 0;
-		(*pskb)->csum = skb_checksum(*pskb, tcphoff,
-					     (*pskb)->len - tcphoff, 0);
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
 		tcph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
-						(*pskb)->len - tcphoff,
-						cp->protocol,
-						(*pskb)->csum);
+						skb->len - tcphoff,
+						cp->protocol, skb->csum);
 		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
 			  pp->name, tcph->check,
 			  (char*)&(tcph->check) - (char*)tcph);
@@ -171,30 +169,30 @@ tcp_snat_handler(struct sk_buff **pskb,
 
 
 static int
-tcp_dnat_handler(struct sk_buff **pskb,
+tcp_dnat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct tcphdr *tcph;
-	const unsigned int tcphoff = ip_hdrlen(*pskb);
+	const unsigned int tcphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
-	if (!skb_make_writable(*pskb, tcphoff+sizeof(*tcph)))
+	if (!skb_make_writable(skb, tcphoff+sizeof(*tcph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(skb, pp))
 			return 0;
 
 		/*
 		 *	Attempt ip_vs_app call.
 		 *	It will fix ip_vs_conn and iph ack_seq stuff
 		 */
-		if (!ip_vs_app_pkt_in(cp, pskb))
+		if (!ip_vs_app_pkt_in(cp, skb))
 			return 0;
 	}
 
-	tcph = (void *)ip_hdr(*pskb) + tcphoff;
+	tcph = (void *)ip_hdr(skb) + tcphoff;
 	tcph->dest = cp->dport;
 
 	/*
@@ -204,18 +202,16 @@ tcp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(tcph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
-			(*pskb)->ip_summed = CHECKSUM_NONE;
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		tcph->check = 0;
-		(*pskb)->csum = skb_checksum(*pskb, tcphoff,
-					     (*pskb)->len - tcphoff, 0);
+		skb->csum = skb_checksum(skb, tcphoff, skb->len - tcphoff, 0);
 		tcph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
-						(*pskb)->len - tcphoff,
-						cp->protocol,
-						(*pskb)->csum);
-		(*pskb)->ip_summed = CHECKSUM_UNNECESSARY;
+						skb->len - tcphoff,
+						cp->protocol, skb->csum);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	return 1;
 }
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index c70aa40..1fa7b33 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -130,29 +130,29 @@ udp_fast_csum_update(struct udphdr *uhdr, __be32 oldip, __be32 newip,
 }
 
 static int
-udp_snat_handler(struct sk_buff **pskb,
+udp_snat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct udphdr *udph;
-	const unsigned int udphoff = ip_hdrlen(*pskb);
+	const unsigned int udphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
-	if (!skb_make_writable(*pskb, udphoff+sizeof(*udph)))
+	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(skb, pp))
 			return 0;
 
 		/*
 		 *	Call application helper if needed
 		 */
-		if (!ip_vs_app_pkt_out(cp, pskb))
+		if (!ip_vs_app_pkt_out(cp, skb))
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(*pskb) + udphoff;
+	udph = (void *)ip_hdr(skb) + udphoff;
 	udph->source = cp->vport;
 
 	/*
@@ -162,17 +162,15 @@ udp_snat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->daddr, cp->vaddr,
 				     cp->dport, cp->vport);
-		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
-			(*pskb)->ip_summed = CHECKSUM_NONE;
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		udph->check = 0;
-		(*pskb)->csum = skb_checksum(*pskb, udphoff,
-					     (*pskb)->len - udphoff, 0);
+		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
 		udph->check = csum_tcpudp_magic(cp->vaddr, cp->caddr,
-						(*pskb)->len - udphoff,
-						cp->protocol,
-						(*pskb)->csum);
+						skb->len - udphoff,
+						cp->protocol, skb->csum);
 		if (udph->check == 0)
 			udph->check = CSUM_MANGLED_0;
 		IP_VS_DBG(11, "O-pkt: %s O-csum=%d (+%zd)\n",
@@ -184,30 +182,30 @@ udp_snat_handler(struct sk_buff **pskb,
 
 
 static int
-udp_dnat_handler(struct sk_buff **pskb,
+udp_dnat_handler(struct sk_buff *skb,
 		 struct ip_vs_protocol *pp, struct ip_vs_conn *cp)
 {
 	struct udphdr *udph;
-	unsigned int udphoff = ip_hdrlen(*pskb);
+	unsigned int udphoff = ip_hdrlen(skb);
 
 	/* csum_check requires unshared skb */
-	if (!skb_make_writable(*pskb, udphoff+sizeof(*udph)))
+	if (!skb_make_writable(skb, udphoff+sizeof(*udph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(skb, pp))
 			return 0;
 
 		/*
 		 *	Attempt ip_vs_app call.
 		 *	It will fix ip_vs_conn
 		 */
-		if (!ip_vs_app_pkt_in(cp, pskb))
+		if (!ip_vs_app_pkt_in(cp, skb))
 			return 0;
 	}
 
-	udph = (void *)ip_hdr(*pskb) + udphoff;
+	udph = (void *)ip_hdr(skb) + udphoff;
 	udph->dest = cp->dport;
 
 	/*
@@ -217,20 +215,18 @@ udp_dnat_handler(struct sk_buff **pskb,
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(udph, cp->vaddr, cp->daddr,
 				     cp->vport, cp->dport);
-		if ((*pskb)->ip_summed == CHECKSUM_COMPLETE)
-			(*pskb)->ip_summed = CHECKSUM_NONE;
+		if (skb->ip_summed == CHECKSUM_COMPLETE)
+			skb->ip_summed = CHECKSUM_NONE;
 	} else {
 		/* full checksum calculation */
 		udph->check = 0;
-		(*pskb)->csum = skb_checksum(*pskb, udphoff,
-					     (*pskb)->len - udphoff, 0);
+		skb->csum = skb_checksum(skb, udphoff, skb->len - udphoff, 0);
 		udph->check = csum_tcpudp_magic(cp->caddr, cp->daddr,
-						(*pskb)->len - udphoff,
-						cp->protocol,
-						(*pskb)->csum);
+						skb->len - udphoff,
+						cp->protocol, skb->csum);
 		if (udph->check == 0)
 			udph->check = CSUM_MANGLED_0;
-		(*pskb)->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 	return 1;
 }
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index afd90d4..d0a92de 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -264,7 +264,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	skb->dst = &rt->u.dst;
 
 	/* mangle the packet */
-	if (pp->dnat_handler && !pp->dnat_handler(&skb, pp, cp))
+	if (pp->dnat_handler && !pp->dnat_handler(skb, pp, cp))
 		goto tx_error;
 	ip_hdr(skb)->daddr = cp->daddr;
 	ip_send_check(ip_hdr(skb));
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index d1e3012..5539deb 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -9,9 +9,9 @@
 #include <net/ip.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
-int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
+int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 {
-	const struct iphdr *iph = ip_hdr(*pskb);
+	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
 	struct dst_entry *odst;
@@ -30,14 +30,14 @@ int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
 		if (type == RTN_LOCAL)
 			fl.nl_u.ip4_u.saddr = iph->saddr;
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
-		fl.oif = (*pskb)->sk ? (*pskb)->sk->sk_bound_dev_if : 0;
-		fl.mark = (*pskb)->mark;
+		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+		fl.mark = skb->mark;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
 		/* Drop old route. */
-		dst_release((*pskb)->dst);
-		(*pskb)->dst = &rt->u.dst;
+		dst_release(skb->dst);
+		skb->dst = &rt->u.dst;
 	} else {
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
@@ -45,8 +45,8 @@ int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
-		odst = (*pskb)->dst;
-		if (ip_route_input(*pskb, iph->daddr, iph->saddr,
+		odst = skb->dst;
+		if (ip_route_input(skb, iph->daddr, iph->saddr,
 				   RT_TOS(iph->tos), rt->u.dst.dev) != 0) {
 			dst_release(&rt->u.dst);
 			return -1;
@@ -55,21 +55,20 @@ int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
 		dst_release(odst);
 	}
 
-	if ((*pskb)->dst->error)
+	if (skb->dst->error)
 		return -1;
 
 #ifdef CONFIG_XFRM
-	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED) &&
-	    xfrm_decode_session(*pskb, &fl, AF_INET) == 0)
-		if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0))
+	if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(skb, &fl, AF_INET) == 0)
+		if (xfrm_lookup(&skb->dst, &fl, skb->sk, 0))
 			return -1;
 #endif
 
 	/* Change in oif may mean change in hh_len. */
-	hh_len = (*pskb)->dst->dev->hard_header_len;
-	if (skb_headroom(*pskb) < hh_len &&
-	    pskb_expand_head(*pskb, hh_len - skb_headroom(*pskb), 0,
-			     GFP_ATOMIC))
+	hh_len = skb->dst->dev->hard_header_len;
+	if (skb_headroom(skb) < hh_len &&
+	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
 		return -1;
 
 	return 0;
@@ -77,33 +76,32 @@ int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
 EXPORT_SYMBOL(ip_route_me_harder);
 
 #ifdef CONFIG_XFRM
-int ip_xfrm_me_harder(struct sk_buff **pskb)
+int ip_xfrm_me_harder(struct sk_buff *skb)
 {
 	struct flowi fl;
 	unsigned int hh_len;
 	struct dst_entry *dst;
 
-	if (IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)
+	if (IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED)
 		return 0;
-	if (xfrm_decode_session(*pskb, &fl, AF_INET) < 0)
+	if (xfrm_decode_session(skb, &fl, AF_INET) < 0)
 		return -1;
 
-	dst = (*pskb)->dst;
+	dst = skb->dst;
 	if (dst->xfrm)
 		dst = ((struct xfrm_dst *)dst)->route;
 	dst_hold(dst);
 
-	if (xfrm_lookup(&dst, &fl, (*pskb)->sk, 0) < 0)
+	if (xfrm_lookup(&dst, &fl, skb->sk, 0) < 0)
 		return -1;
 
-	dst_release((*pskb)->dst);
-	(*pskb)->dst = dst;
+	dst_release(skb->dst);
+	skb->dst = dst;
 
 	/* Change in oif may mean change in hh_len. */
-	hh_len = (*pskb)->dst->dev->hard_header_len;
-	if (skb_headroom(*pskb) < hh_len &&
-	    pskb_expand_head(*pskb, hh_len - skb_headroom(*pskb), 0,
-			     GFP_ATOMIC))
+	hh_len = skb->dst->dev->hard_header_len;
+	if (skb_headroom(skb) < hh_len &&
+	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
 		return -1;
 	return 0;
 }
@@ -137,17 +135,17 @@ static void nf_ip_saveroute(const struct sk_buff *skb, struct nf_info *info)
 	}
 }
 
-static int nf_ip_reroute(struct sk_buff **pskb, const struct nf_info *info)
+static int nf_ip_reroute(struct sk_buff *skb, const struct nf_info *info)
 {
 	const struct ip_rt_info *rt_info = nf_info_reroute(info);
 
 	if (info->hook == NF_IP_LOCAL_OUT) {
-		const struct iphdr *iph = ip_hdr(*pskb);
+		const struct iphdr *iph = ip_hdr(skb);
 
 		if (!(iph->tos == rt_info->tos
 		      && iph->daddr == rt_info->daddr
 		      && iph->saddr == rt_info->saddr))
-			return ip_route_me_harder(pskb, RTN_UNSPEC);
+			return ip_route_me_harder(skb, RTN_UNSPEC);
 	}
 	return 0;
 }
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 29114a9..2909c92 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -197,7 +197,7 @@ static inline int arp_checkentry(const struct arpt_arp *arp)
 	return 1;
 }
 
-static unsigned int arpt_error(struct sk_buff **pskb,
+static unsigned int arpt_error(struct sk_buff *skb,
 			       const struct net_device *in,
 			       const struct net_device *out,
 			       unsigned int hooknum,
@@ -215,7 +215,7 @@ static inline struct arpt_entry *get_entry(void *base, unsigned int offset)
 	return (struct arpt_entry *)(base + offset);
 }
 
-unsigned int arpt_do_table(struct sk_buff **pskb,
+unsigned int arpt_do_table(struct sk_buff *skb,
 			   unsigned int hook,
 			   const struct net_device *in,
 			   const struct net_device *out,
@@ -231,9 +231,9 @@ unsigned int arpt_do_table(struct sk_buff **pskb,
 	struct xt_table_info *private;
 
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
-	if (!pskb_may_pull((*pskb), (sizeof(struct arphdr) +
-				     (2 * (*pskb)->dev->addr_len) +
-				     (2 * sizeof(u32)))))
+	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
+				 (2 * skb->dev->addr_len) +
+				 (2 * sizeof(u32)))))
 		return NF_DROP;
 
 	indev = in ? in->name : nulldevname;
@@ -245,14 +245,14 @@ unsigned int arpt_do_table(struct sk_buff **pskb,
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
-	arp = arp_hdr(*pskb);
+	arp = arp_hdr(skb);
 	do {
-		if (arp_packet_match(arp, (*pskb)->dev, indev, outdev, &e->arp)) {
+		if (arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
 			struct arpt_entry_target *t;
 			int hdr_len;
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
-				(2 * (*pskb)->dev->addr_len);
+				(2 * skb->dev->addr_len);
 			ADD_COUNTER(e->counters, hdr_len, 1);
 
 			t = arpt_get_target(e);
@@ -290,14 +290,14 @@ unsigned int arpt_do_table(struct sk_buff **pskb,
 				/* Targets which reenter must return
 				 * abs. verdicts
 				 */
-				verdict = t->u.kernel.target->target(pskb,
+				verdict = t->u.kernel.target->target(skb,
 								     in, out,
 								     hook,
 								     t->u.kernel.target,
 								     t->data);
 
 				/* Target might have changed stuff. */
-				arp = arp_hdr(*pskb);
+				arp = arp_hdr(skb);
 
 				if (verdict == ARPT_CONTINUE)
 					e = (void *)e + e->next_offset;
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index 0181f91..45fa4e2 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -9,7 +9,7 @@ MODULE_AUTHOR("Bart De Schuymer <bdschuym@pandora.be>");
 MODULE_DESCRIPTION("arptables arp payload mangle target");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in, const struct net_device *out,
        unsigned int hooknum, const struct xt_target *target,
        const void *targinfo)
@@ -19,38 +19,38 @@ target(struct sk_buff **pskb,
 	unsigned char *arpptr;
 	int pln, hln;
 
-	if (skb_make_writable(*pskb, (*pskb)->len))
+	if (skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
-	arp = arp_hdr(*pskb);
-	arpptr = skb_network_header(*pskb) + sizeof(*arp);
+	arp = arp_hdr(skb);
+	arpptr = skb_network_header(skb) + sizeof(*arp);
 	pln = arp->ar_pln;
 	hln = arp->ar_hln;
 	/* We assume that pln and hln were checked in the match */
 	if (mangle->flags & ARPT_MANGLE_SDEV) {
 		if (ARPT_DEV_ADDR_LEN_MAX < hln ||
-		   (arpptr + hln > skb_tail_pointer(*pskb)))
+		   (arpptr + hln > skb_tail_pointer(skb)))
 			return NF_DROP;
 		memcpy(arpptr, mangle->src_devaddr, hln);
 	}
 	arpptr += hln;
 	if (mangle->flags & ARPT_MANGLE_SIP) {
 		if (ARPT_MANGLE_ADDR_LEN_MAX < pln ||
-		   (arpptr + pln > skb_tail_pointer(*pskb)))
+		   (arpptr + pln > skb_tail_pointer(skb)))
 			return NF_DROP;
 		memcpy(arpptr, &mangle->u_s.src_ip, pln);
 	}
 	arpptr += pln;
 	if (mangle->flags & ARPT_MANGLE_TDEV) {
 		if (ARPT_DEV_ADDR_LEN_MAX < hln ||
-		   (arpptr + hln > skb_tail_pointer(*pskb)))
+		   (arpptr + hln > skb_tail_pointer(skb)))
 			return NF_DROP;
 		memcpy(arpptr, mangle->tgt_devaddr, hln);
 	}
 	arpptr += hln;
 	if (mangle->flags & ARPT_MANGLE_TIP) {
 		if (ARPT_MANGLE_ADDR_LEN_MAX < pln ||
-		   (arpptr + pln > skb_tail_pointer(*pskb)))
+		   (arpptr + pln > skb_tail_pointer(skb)))
 			return NF_DROP;
 		memcpy(arpptr, &mangle->u_t.tgt_ip, pln);
 	}
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 75c0230..302d3da 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -56,12 +56,12 @@ static struct arpt_table packet_filter = {
 
 /* The work comes in here from netfilter.c */
 static unsigned int arpt_hook(unsigned int hook,
-			      struct sk_buff **pskb,
+			      struct sk_buff *skb,
 			      const struct net_device *in,
 			      const struct net_device *out,
 			      int (*okfn)(struct sk_buff *))
 {
-	return arpt_do_table(pskb, hook, in, out, &packet_filter);
+	return arpt_do_table(skb, hook, in, out, &packet_filter);
 }
 
 static struct nf_hook_ops arpt_ops[] = {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 6486894..4b10b98 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -169,7 +169,7 @@ ip_checkentry(const struct ipt_ip *ip)
 }
 
 static unsigned int
-ipt_error(struct sk_buff **pskb,
+ipt_error(struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  unsigned int hooknum,
@@ -312,7 +312,7 @@ static void trace_packet(struct sk_buff *skb,
 
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
-ipt_do_table(struct sk_buff **pskb,
+ipt_do_table(struct sk_buff *skb,
 	     unsigned int hook,
 	     const struct net_device *in,
 	     const struct net_device *out,
@@ -331,8 +331,8 @@ ipt_do_table(struct sk_buff **pskb,
 	struct xt_table_info *private;
 
 	/* Initialization */
-	ip = ip_hdr(*pskb);
-	datalen = (*pskb)->len - ip->ihl * 4;
+	ip = ip_hdr(skb);
+	datalen = skb->len - ip->ihl * 4;
 	indev = in ? in->name : nulldevname;
 	outdev = out ? out->name : nulldevname;
 	/* We handle fragments by dealing with the first fragment as
@@ -359,7 +359,7 @@ ipt_do_table(struct sk_buff **pskb,
 			struct ipt_entry_target *t;
 
 			if (IPT_MATCH_ITERATE(e, do_match,
-					      *pskb, in, out,
+					      skb, in, out,
 					      offset, &hotdrop) != 0)
 				goto no_match;
 
@@ -371,8 +371,8 @@ ipt_do_table(struct sk_buff **pskb,
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
 			/* The packet is traced: log it */
-			if (unlikely((*pskb)->nf_trace))
-				trace_packet(*pskb, hook, in, out,
+			if (unlikely(skb->nf_trace))
+				trace_packet(skb, hook, in, out,
 					     table->name, private, e);
 #endif
 			/* Standard target? */
@@ -410,7 +410,7 @@ ipt_do_table(struct sk_buff **pskb,
 				((struct ipt_entry *)table_base)->comefrom
 					= 0xeeeeeeec;
 #endif
-				verdict = t->u.kernel.target->target(pskb,
+				verdict = t->u.kernel.target->target(skb,
 								     in, out,
 								     hook,
 								     t->u.kernel.target,
@@ -428,8 +428,8 @@ ipt_do_table(struct sk_buff **pskb,
 					= 0x57acc001;
 #endif
 				/* Target might have changed stuff. */
-				ip = ip_hdr(*pskb);
-				datalen = (*pskb)->len - ip->ihl * 4;
+				ip = ip_hdr(skb);
+				datalen = skb->len - ip->ihl * 4;
 
 				if (verdict == IPT_CONTINUE)
 					e = (void *)e + e->next_offset;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 27f14e1..2f544da 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -289,7 +289,7 @@ clusterip_responsible(const struct clusterip_config *config, u_int32_t hash)
  ***********************************************************************/
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -305,7 +305,7 @@ target(struct sk_buff **pskb,
 	 * is only decremented by destroy() - and ip_tables guarantees
 	 * that the ->target() function isn't called after ->destroy() */
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	if (ct == NULL) {
 		printk(KERN_ERR "CLUSTERIP: no conntrack!\n");
 			/* FIXME: need to drop invalid ones, since replies
@@ -316,7 +316,7 @@ target(struct sk_buff **pskb,
 
 	/* special case: ICMP error handling. conntrack distinguishes between
 	 * error messages (RELATED) and information requests (see below) */
-	if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP
+	if (ip_hdr(skb)->protocol == IPPROTO_ICMP
 	    && (ctinfo == IP_CT_RELATED
 		|| ctinfo == IP_CT_RELATED+IP_CT_IS_REPLY))
 		return XT_CONTINUE;
@@ -325,7 +325,7 @@ target(struct sk_buff **pskb,
 	 * TIMESTAMP, INFO_REQUEST or ADDRESS type icmp packets from here
 	 * on, which all have an ID field [relevant for hashing]. */
 
-	hash = clusterip_hashfn(*pskb, cipinfo->config);
+	hash = clusterip_hashfn(skb, cipinfo->config);
 
 	switch (ctinfo) {
 		case IP_CT_NEW:
@@ -355,7 +355,7 @@ target(struct sk_buff **pskb,
 
 	/* despite being received via linklayer multicast, this is
 	 * actually a unicast IP packet. TCP doesn't like PACKET_MULTICAST */
-	(*pskb)->pkt_type = PACKET_HOST;
+	skb->pkt_type = PACKET_HOST;
 
 	return XT_CONTINUE;
 }
@@ -505,12 +505,12 @@ static void arp_print(struct arp_payload *payload)
 
 static unsigned int
 arp_mangle(unsigned int hook,
-	   struct sk_buff **pskb,
+	   struct sk_buff *skb,
 	   const struct net_device *in,
 	   const struct net_device *out,
 	   int (*okfn)(struct sk_buff *))
 {
-	struct arphdr *arp = arp_hdr(*pskb);
+	struct arphdr *arp = arp_hdr(skb);
 	struct arp_payload *payload;
 	struct clusterip_config *c;
 
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
index 92744be..add1100 100644
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -26,15 +26,15 @@ MODULE_DESCRIPTION("iptables ECN modification module");
 /* set ECT codepoint from IP header.
  * 	return false if there was an error. */
 static inline bool
-set_ect_ip(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
+set_ect_ip(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 {
-	struct iphdr *iph = ip_hdr(*pskb);
+	struct iphdr *iph = ip_hdr(skb);
 
 	if ((iph->tos & IPT_ECN_IP_MASK) != (einfo->ip_ect & IPT_ECN_IP_MASK)) {
 		__u8 oldtos;
-		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
 			return false;
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 		oldtos = iph->tos;
 		iph->tos &= ~IPT_ECN_IP_MASK;
 		iph->tos |= (einfo->ip_ect & IPT_ECN_IP_MASK);
@@ -45,14 +45,13 @@ set_ect_ip(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 
 /* Return false if there was an error. */
 static inline bool
-set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
+set_ect_tcp(struct sk_buff *skb, const struct ipt_ECN_info *einfo)
 {
 	struct tcphdr _tcph, *tcph;
 	__be16 oldval;
 
 	/* Not enought header? */
-	tcph = skb_header_pointer(*pskb, ip_hdrlen(*pskb),
-				  sizeof(_tcph), &_tcph);
+	tcph = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_tcph), &_tcph);
 	if (!tcph)
 		return false;
 
@@ -62,9 +61,9 @@ set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 	     tcph->cwr == einfo->proto.tcp.cwr))
 		return true;
 
-	if (!skb_make_writable(*pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
+	if (!skb_make_writable(skb, ip_hdrlen(skb) + sizeof(*tcph)))
 		return false;
-	tcph = (void *)ip_hdr(*pskb) + ip_hdrlen(*pskb);
+	tcph = (void *)ip_hdr(skb) + ip_hdrlen(skb);
 
 	oldval = ((__be16 *)tcph)[6];
 	if (einfo->operation & IPT_ECN_OP_SET_ECE)
@@ -72,13 +71,13 @@ set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
 	if (einfo->operation & IPT_ECN_OP_SET_CWR)
 		tcph->cwr = einfo->proto.tcp.cwr;
 
-	nf_proto_csum_replace2(&tcph->check, *pskb,
+	nf_proto_csum_replace2(&tcph->check, skb,
 				oldval, ((__be16 *)tcph)[6], 0);
 	return true;
 }
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -88,12 +87,12 @@ target(struct sk_buff **pskb,
 	const struct ipt_ECN_info *einfo = targinfo;
 
 	if (einfo->operation & IPT_ECN_OP_SET_IP)
-		if (!set_ect_ip(pskb, einfo))
+		if (!set_ect_ip(skb, einfo))
 			return NF_DROP;
 
 	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR)
-	    && ip_hdr(*pskb)->protocol == IPPROTO_TCP)
-		if (!set_ect_tcp(pskb, einfo))
+	    && ip_hdr(skb)->protocol == IPPROTO_TCP)
+		if (!set_ect_tcp(skb, einfo))
 			return NF_DROP;
 
 	return XT_CONTINUE;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 127a5e8..4b5e821 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -418,7 +418,7 @@ ipt_log_packet(unsigned int pf,
 }
 
 static unsigned int
-ipt_log_target(struct sk_buff **pskb,
+ipt_log_target(struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
 	       unsigned int hooknum,
@@ -432,7 +432,7 @@ ipt_log_target(struct sk_buff **pskb,
 	li.u.log.level = loginfo->level;
 	li.u.log.logflags = loginfo->logflags;
 
-	ipt_log_packet(PF_INET, hooknum, *pskb, in, out, &li,
+	ipt_log_packet(PF_INET, hooknum, skb, in, out, &li,
 		       loginfo->prefix);
 	return XT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 3e0b562..44b516e 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -52,7 +52,7 @@ masquerade_check(const char *tablename,
 }
 
 static unsigned int
-masquerade_target(struct sk_buff **pskb,
+masquerade_target(struct sk_buff *skb,
 		  const struct net_device *in,
 		  const struct net_device *out,
 		  unsigned int hooknum,
@@ -69,7 +69,7 @@ masquerade_target(struct sk_buff **pskb,
 
 	NF_CT_ASSERT(hooknum == NF_IP_POST_ROUTING);
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	nat = nfct_nat(ct);
 
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED
@@ -82,7 +82,7 @@ masquerade_target(struct sk_buff **pskb,
 		return NF_ACCEPT;
 
 	mr = targinfo;
-	rt = (struct rtable *)(*pskb)->dst;
+	rt = (struct rtable *)skb->dst;
 	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
 	if (!newsrc) {
 		printk("MASQUERADE: %s ate my IP address\n", out->name);
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index 41a011d..f869929 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -43,7 +43,7 @@ check(const char *tablename,
 }
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -59,14 +59,14 @@ target(struct sk_buff **pskb,
 	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING
 		     || hooknum == NF_IP_POST_ROUTING
 		     || hooknum == NF_IP_LOCAL_OUT);
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 
 	netmask = ~(mr->range[0].min_ip ^ mr->range[0].max_ip);
 
 	if (hooknum == NF_IP_PRE_ROUTING || hooknum == NF_IP_LOCAL_OUT)
-		new_ip = ip_hdr(*pskb)->daddr & ~netmask;
+		new_ip = ip_hdr(skb)->daddr & ~netmask;
 	else
-		new_ip = ip_hdr(*pskb)->saddr & ~netmask;
+		new_ip = ip_hdr(skb)->saddr & ~netmask;
 	new_ip |= mr->range[0].min_ip & netmask;
 
 	newrange = ((struct nf_nat_range)
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 6ac7a23..f7cf7d6 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -47,7 +47,7 @@ redirect_check(const char *tablename,
 }
 
 static unsigned int
-redirect_target(struct sk_buff **pskb,
+redirect_target(struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
 		unsigned int hooknum,
@@ -63,7 +63,7 @@ redirect_target(struct sk_buff **pskb,
 	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING
 		     || hooknum == NF_IP_LOCAL_OUT);
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
 	/* Local packets: make them go to loopback */
@@ -76,7 +76,7 @@ redirect_target(struct sk_buff **pskb,
 		newdst = 0;
 
 		rcu_read_lock();
-		indev = __in_dev_get_rcu((*pskb)->dev);
+		indev = __in_dev_get_rcu(skb->dev);
 		if (indev && (ifa = indev->ifa_list))
 			newdst = ifa->ifa_local;
 		rcu_read_unlock();
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index cb038c8..dcf4d21 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -131,7 +131,7 @@ static void send_reset(struct sk_buff *oldskb, int hook)
 	   )
 		addr_type = RTN_LOCAL;
 
-	if (ip_route_me_harder(&nskb, addr_type))
+	if (ip_route_me_harder(nskb, addr_type))
 		goto free_nskb;
 
 	nskb->ip_summed = CHECKSUM_NONE;
@@ -162,7 +162,7 @@ static inline void send_unreach(struct sk_buff *skb_in, int code)
 	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
 }
 
-static unsigned int reject(struct sk_buff **pskb,
+static unsigned int reject(struct sk_buff *skb,
 			   const struct net_device *in,
 			   const struct net_device *out,
 			   unsigned int hooknum,
@@ -173,7 +173,7 @@ static unsigned int reject(struct sk_buff **pskb,
 
 	/* Our naive response construction doesn't deal with IP
 	   options, and probably shouldn't try. */
-	if (ip_hdrlen(*pskb) != sizeof(struct iphdr))
+	if (ip_hdrlen(skb) != sizeof(struct iphdr))
 		return NF_DROP;
 
 	/* WARNING: This code causes reentry within iptables.
@@ -181,28 +181,28 @@ static unsigned int reject(struct sk_buff **pskb,
 	   must return an absolute verdict. --RR */
 	switch (reject->with) {
 	case IPT_ICMP_NET_UNREACHABLE:
-		send_unreach(*pskb, ICMP_NET_UNREACH);
+		send_unreach(skb, ICMP_NET_UNREACH);
 		break;
 	case IPT_ICMP_HOST_UNREACHABLE:
-		send_unreach(*pskb, ICMP_HOST_UNREACH);
+		send_unreach(skb, ICMP_HOST_UNREACH);
 		break;
 	case IPT_ICMP_PROT_UNREACHABLE:
-		send_unreach(*pskb, ICMP_PROT_UNREACH);
+		send_unreach(skb, ICMP_PROT_UNREACH);
 		break;
 	case IPT_ICMP_PORT_UNREACHABLE:
-		send_unreach(*pskb, ICMP_PORT_UNREACH);
+		send_unreach(skb, ICMP_PORT_UNREACH);
 		break;
 	case IPT_ICMP_NET_PROHIBITED:
-		send_unreach(*pskb, ICMP_NET_ANO);
+		send_unreach(skb, ICMP_NET_ANO);
 		break;
 	case IPT_ICMP_HOST_PROHIBITED:
-		send_unreach(*pskb, ICMP_HOST_ANO);
+		send_unreach(skb, ICMP_HOST_ANO);
 		break;
 	case IPT_ICMP_ADMIN_PROHIBITED:
-		send_unreach(*pskb, ICMP_PKT_FILTERED);
+		send_unreach(skb, ICMP_PKT_FILTERED);
 		break;
 	case IPT_TCP_RESET:
-		send_reset(*pskb, hooknum);
+		send_reset(skb, hooknum);
 	case IPT_ICMP_ECHOREPLY:
 		/* Doesn't happen. */
 		break;
diff --git a/net/ipv4/netfilter/ipt_SAME.c b/net/ipv4/netfilter/ipt_SAME.c
index 97641f1..8988571 100644
--- a/net/ipv4/netfilter/ipt_SAME.c
+++ b/net/ipv4/netfilter/ipt_SAME.c
@@ -104,7 +104,7 @@ same_destroy(const struct xt_target *target, void *targinfo)
 }
 
 static unsigned int
-same_target(struct sk_buff **pskb,
+same_target(struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
 		unsigned int hooknum,
@@ -121,7 +121,7 @@ same_target(struct sk_buff **pskb,
 
 	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING ||
 			hooknum == NF_IP_POST_ROUTING);
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 
 	t = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
index 87b689a..d4573ba 100644
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -21,7 +21,7 @@ MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables TOS mangling module");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -29,13 +29,13 @@ target(struct sk_buff **pskb,
        const void *targinfo)
 {
 	const struct ipt_tos_target_info *tosinfo = targinfo;
-	struct iphdr *iph = ip_hdr(*pskb);
+	struct iphdr *iph = ip_hdr(skb);
 
 	if ((iph->tos & IPTOS_TOS_MASK) != tosinfo->tos) {
 		__u8 oldtos;
-		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
 			return NF_DROP;
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 		oldtos = iph->tos;
 		iph->tos = (iph->tos & IPTOS_PREC_MASK) | tosinfo->tos;
 		nf_csum_replace2(&iph->check, htons(oldtos), htons(iph->tos));
diff --git a/net/ipv4/netfilter/ipt_TTL.c b/net/ipv4/netfilter/ipt_TTL.c
index 3dd4676..c620a05 100644
--- a/net/ipv4/netfilter/ipt_TTL.c
+++ b/net/ipv4/netfilter/ipt_TTL.c
@@ -20,7 +20,7 @@ MODULE_DESCRIPTION("IP tables TTL modification module");
 MODULE_LICENSE("GPL");
 
 static unsigned int
-ipt_ttl_target(struct sk_buff **pskb,
+ipt_ttl_target(struct sk_buff *skb,
 	       const struct net_device *in, const struct net_device *out,
 	       unsigned int hooknum, const struct xt_target *target,
 	       const void *targinfo)
@@ -29,10 +29,10 @@ ipt_ttl_target(struct sk_buff **pskb,
 	const struct ipt_TTL_info *info = targinfo;
 	int new_ttl;
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
-	iph = ip_hdr(*pskb);
+	iph = ip_hdr(skb);
 
 	switch (info->mode) {
 		case IPT_TTL_SET:
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index c636d6d..212b830 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -279,7 +279,7 @@ alloc_failure:
 	spin_unlock_bh(&ulog_lock);
 }
 
-static unsigned int ipt_ulog_target(struct sk_buff **pskb,
+static unsigned int ipt_ulog_target(struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    unsigned int hooknum,
@@ -288,7 +288,7 @@ static unsigned int ipt_ulog_target(struct sk_buff **pskb,
 {
 	struct ipt_ulog_info *loginfo = (struct ipt_ulog_info *) targinfo;
 
-	ipt_ulog_packet(hooknum, *pskb, in, out, loginfo, NULL);
+	ipt_ulog_packet(hooknum, skb, in, out, loginfo, NULL);
 
 	return XT_CONTINUE;
 }
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 4f51c1d..ba3262c 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -62,31 +62,31 @@ static struct xt_table packet_filter = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ipt_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(pskb, hook, in, out, &packet_filter);
+	return ipt_do_table(skb, hook, in, out, &packet_filter);
 }
 
 static unsigned int
 ipt_local_out_hook(unsigned int hook,
-		   struct sk_buff **pskb,
+		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr)
-	    || ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("iptable_filter: ignoring short SOCK_RAW "
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
 
-	return ipt_do_table(pskb, hook, in, out, &packet_filter);
+	return ipt_do_table(skb, hook, in, out, &packet_filter);
 }
 
 static struct nf_hook_ops ipt_ops[] = {
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 902446f..b4360a6 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -75,17 +75,17 @@ static struct xt_table packet_mangler = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ipt_route_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(pskb, hook, in, out, &packet_mangler);
+	return ipt_do_table(skb, hook, in, out, &packet_mangler);
 }
 
 static unsigned int
 ipt_local_hook(unsigned int hook,
-		   struct sk_buff **pskb,
+		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
@@ -97,8 +97,8 @@ ipt_local_hook(unsigned int hook,
 	u_int32_t mark;
 
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr)
-	    || ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr)
+	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("iptable_mangle: ignoring short SOCK_RAW "
 			       "packet.\n");
@@ -106,22 +106,22 @@ ipt_local_hook(unsigned int hook,
 	}
 
 	/* Save things which could affect route */
-	mark = (*pskb)->mark;
-	iph = ip_hdr(*pskb);
+	mark = skb->mark;
+	iph = ip_hdr(skb);
 	saddr = iph->saddr;
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = ipt_do_table(pskb, hook, in, out, &packet_mangler);
+	ret = ipt_do_table(skb, hook, in, out, &packet_mangler);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE) {
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 
 		if (iph->saddr != saddr ||
 		    iph->daddr != daddr ||
-		    (*pskb)->mark != mark ||
+		    skb->mark != mark ||
 		    iph->tos != tos)
-			if (ip_route_me_harder(pskb, RTN_UNSPEC))
+			if (ip_route_me_harder(skb, RTN_UNSPEC))
 				ret = NF_DROP;
 	}
 
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index d6e5033..5de6e57 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -47,30 +47,30 @@ static struct xt_table packet_raw = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ipt_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(pskb, hook, in, out, &packet_raw);
+	return ipt_do_table(skb, hook, in, out, &packet_raw);
 }
 
 static unsigned int
 ipt_local_hook(unsigned int hook,
-	       struct sk_buff **pskb,
+	       struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
 	       int (*okfn)(struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("iptable_raw: ignoring short SOCK_RAW"
 			       "packet.\n");
 		return NF_ACCEPT;
 	}
-	return ipt_do_table(pskb, hook, in, out, &packet_raw);
+	return ipt_do_table(skb, hook, in, out, &packet_raw);
 }
 
 /* 'raw' is the very first table. */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 48fdd9e..831e9b2 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -100,17 +100,17 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 }
 
 static unsigned int ipv4_confirm(unsigned int hooknum,
-				 struct sk_buff **pskb,
+				 struct sk_buff *skb,
 				 const struct net_device *in,
 				 const struct net_device *out,
 				 int (*okfn)(struct sk_buff *))
 {
 	/* We've seen it coming out the other side: confirm it */
-	return nf_conntrack_confirm(pskb);
+	return nf_conntrack_confirm(skb);
 }
 
 static unsigned int ipv4_conntrack_help(unsigned int hooknum,
-				      struct sk_buff **pskb,
+				      struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
@@ -121,7 +121,7 @@ static unsigned int ipv4_conntrack_help(unsigned int hooknum,
 	struct nf_conntrack_helper *helper;
 
 	/* This is where we call the helper: as the packet goes out. */
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY)
 		return NF_ACCEPT;
 
@@ -132,24 +132,24 @@ static unsigned int ipv4_conntrack_help(unsigned int hooknum,
 	helper = rcu_dereference(help->helper);
 	if (!helper)
 		return NF_ACCEPT;
-	return helper->help(pskb, skb_network_offset(*pskb) + ip_hdrlen(*pskb),
+	return helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
 			    ct, ctinfo);
 }
 
 static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
-					  struct sk_buff **pskb,
+					  struct sk_buff *skb,
 					  const struct net_device *in,
 					  const struct net_device *out,
 					  int (*okfn)(struct sk_buff *))
 {
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
-	if ((*pskb)->nfct)
+	if (skb->nfct)
 		return NF_ACCEPT;
 
 	/* Gather fragments. */
-	if (ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		if (nf_ct_ipv4_gather_frags(*pskb,
+	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
+		if (nf_ct_ipv4_gather_frags(skb,
 					    hooknum == NF_IP_PRE_ROUTING ?
 					    IP_DEFRAG_CONNTRACK_IN :
 					    IP_DEFRAG_CONNTRACK_OUT))
@@ -159,28 +159,28 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 }
 
 static unsigned int ipv4_conntrack_in(unsigned int hooknum,
-				      struct sk_buff **pskb,
+				      struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return nf_conntrack_in(PF_INET, hooknum, pskb);
+	return nf_conntrack_in(PF_INET, hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(unsigned int hooknum,
-					 struct sk_buff **pskb,
+					 struct sk_buff *skb,
 					 const struct net_device *in,
 					 const struct net_device *out,
 					 int (*okfn)(struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr)
-	    || ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(PF_INET, hooknum, pskb);
+	return nf_conntrack_in(PF_INET, hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
index bd93a1d..35a5aa6 100644
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ b/net/ipv4/netfilter/nf_nat_amanda.c
@@ -24,7 +24,7 @@ MODULE_DESCRIPTION("Amanda NAT helper");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_nat_amanda");
 
-static unsigned int help(struct sk_buff **pskb,
+static unsigned int help(struct sk_buff *skb,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned int matchoff,
 			 unsigned int matchlen,
@@ -53,7 +53,7 @@ static unsigned int help(struct sk_buff **pskb,
 		return NF_DROP;
 
 	sprintf(buffer, "%u", port);
-	ret = nf_nat_mangle_udp_packet(pskb, exp->master, ctinfo,
+	ret = nf_nat_mangle_udp_packet(skb, exp->master, ctinfo,
 				       matchoff, matchlen,
 				       buffer, strlen(buffer));
 	if (ret != NF_ACCEPT)
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 3b5eb7c..56e93f6 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -349,7 +349,7 @@ EXPORT_SYMBOL(nf_nat_setup_info);
 /* Returns true if succeeded. */
 static int
 manip_pkt(u_int16_t proto,
-	  struct sk_buff **pskb,
+	  struct sk_buff *skb,
 	  unsigned int iphdroff,
 	  const struct nf_conntrack_tuple *target,
 	  enum nf_nat_manip_type maniptype)
@@ -357,19 +357,19 @@ manip_pkt(u_int16_t proto,
 	struct iphdr *iph;
 	struct nf_nat_protocol *p;
 
-	if (!skb_make_writable(*pskb, iphdroff + sizeof(*iph)))
+	if (!skb_make_writable(skb, iphdroff + sizeof(*iph)))
 		return 0;
 
-	iph = (void *)(*pskb)->data + iphdroff;
+	iph = (void *)skb->data + iphdroff;
 
 	/* Manipulate protcol part. */
 
 	/* rcu_read_lock()ed by nf_hook_slow */
 	p = __nf_nat_proto_find(proto);
-	if (!p->manip_pkt(pskb, iphdroff, target, maniptype))
+	if (!p->manip_pkt(skb, iphdroff, target, maniptype))
 		return 0;
 
-	iph = (void *)(*pskb)->data + iphdroff;
+	iph = (void *)skb->data + iphdroff;
 
 	if (maniptype == IP_NAT_MANIP_SRC) {
 		nf_csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
@@ -385,7 +385,7 @@ manip_pkt(u_int16_t proto,
 unsigned int nf_nat_packet(struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned int hooknum,
-			   struct sk_buff **pskb)
+			   struct sk_buff *skb)
 {
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
@@ -407,7 +407,7 @@ unsigned int nf_nat_packet(struct nf_conn *ct,
 		/* We are aiming to look like inverse of other direction. */
 		nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
 
-		if (!manip_pkt(target.dst.protonum, pskb, 0, &target, mtype))
+		if (!manip_pkt(target.dst.protonum, skb, 0, &target, mtype))
 			return NF_DROP;
 	}
 	return NF_ACCEPT;
@@ -418,7 +418,7 @@ EXPORT_SYMBOL_GPL(nf_nat_packet);
 int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
 				  unsigned int hooknum,
-				  struct sk_buff **pskb)
+				  struct sk_buff *skb)
 {
 	struct {
 		struct icmphdr icmp;
@@ -426,24 +426,24 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	} *inside;
 	struct nf_conntrack_l4proto *l4proto;
 	struct nf_conntrack_tuple inner, target;
-	int hdrlen = ip_hdrlen(*pskb);
+	int hdrlen = ip_hdrlen(skb);
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
 	enum nf_nat_manip_type manip = HOOK2MANIP(hooknum);
 
-	if (!skb_make_writable(*pskb, hdrlen + sizeof(*inside)))
+	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
 		return 0;
 
-	inside = (void *)(*pskb)->data + ip_hdrlen(*pskb);
+	inside = (void *)skb->data + ip_hdrlen(skb);
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
-	if (nf_ip_checksum(*pskb, hooknum, hdrlen, 0))
+	if (nf_ip_checksum(skb, hooknum, hdrlen, 0))
 		return 0;
 
 	/* Must be RELATED */
-	NF_CT_ASSERT((*pskb)->nfctinfo == IP_CT_RELATED ||
-		     (*pskb)->nfctinfo == IP_CT_RELATED+IP_CT_IS_REPLY);
+	NF_CT_ASSERT(skb->nfctinfo == IP_CT_RELATED ||
+		     skb->nfctinfo == IP_CT_RELATED+IP_CT_IS_REPLY);
 
 	/* Redirects on non-null nats must be dropped, else they'll
 	   start talking to each other without our translation, and be
@@ -458,15 +458,15 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	}
 
 	pr_debug("icmp_reply_translation: translating error %p manip %u "
-		 "dir %s\n", *pskb, manip,
+		 "dir %s\n", skb, manip,
 		 dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY");
 
 	/* rcu_read_lock()ed by nf_hook_slow */
 	l4proto = __nf_ct_l4proto_find(PF_INET, inside->ip.protocol);
 
-	if (!nf_ct_get_tuple(*pskb,
-			     ip_hdrlen(*pskb) + sizeof(struct icmphdr),
-			     (ip_hdrlen(*pskb) +
+	if (!nf_ct_get_tuple(skb,
+			     ip_hdrlen(skb) + sizeof(struct icmphdr),
+			     (ip_hdrlen(skb) +
 			      sizeof(struct icmphdr) + inside->ip.ihl * 4),
 			     (u_int16_t)AF_INET,
 			     inside->ip.protocol,
@@ -478,19 +478,19 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	   pass all hooks (locally-generated ICMP).  Consider incoming
 	   packet: PREROUTING (DST manip), routing produces ICMP, goes
 	   through POSTROUTING (which must correct the DST manip). */
-	if (!manip_pkt(inside->ip.protocol, pskb,
-		       ip_hdrlen(*pskb) + sizeof(inside->icmp),
+	if (!manip_pkt(inside->ip.protocol, skb,
+		       ip_hdrlen(skb) + sizeof(inside->icmp),
 		       &ct->tuplehash[!dir].tuple,
 		       !manip))
 		return 0;
 
-	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Reloading "inside" here since manip_pkt inner. */
-		inside = (void *)(*pskb)->data + ip_hdrlen(*pskb);
+		inside = (void *)skb->data + ip_hdrlen(skb);
 		inside->icmp.checksum = 0;
 		inside->icmp.checksum =
-			csum_fold(skb_checksum(*pskb, hdrlen,
-					       (*pskb)->len - hdrlen, 0));
+			csum_fold(skb_checksum(skb, hdrlen,
+					       skb->len - hdrlen, 0));
 	}
 
 	/* Change outer to look the reply to an incoming packet
@@ -506,7 +506,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 
 	if (ct->status & statusbit) {
 		nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
-		if (!manip_pkt(0, pskb, 0, &target, manip))
+		if (!manip_pkt(0, skb, 0, &target, manip))
 			return 0;
 	}
 
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index 3663bd8..e1a16d3 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -28,7 +28,7 @@ MODULE_ALIAS("ip_nat_ftp");
 /* FIXME: Time out? --RR */
 
 static int
-mangle_rfc959_packet(struct sk_buff **pskb,
+mangle_rfc959_packet(struct sk_buff *skb,
 		     __be32 newip,
 		     u_int16_t port,
 		     unsigned int matchoff,
@@ -43,13 +43,13 @@ mangle_rfc959_packet(struct sk_buff **pskb,
 
 	pr_debug("calling nf_nat_mangle_tcp_packet\n");
 
-	return nf_nat_mangle_tcp_packet(pskb, ct, ctinfo, matchoff,
+	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
 					matchlen, buffer, strlen(buffer));
 }
 
 /* |1|132.235.1.2|6275| */
 static int
-mangle_eprt_packet(struct sk_buff **pskb,
+mangle_eprt_packet(struct sk_buff *skb,
 		   __be32 newip,
 		   u_int16_t port,
 		   unsigned int matchoff,
@@ -63,13 +63,13 @@ mangle_eprt_packet(struct sk_buff **pskb,
 
 	pr_debug("calling nf_nat_mangle_tcp_packet\n");
 
-	return nf_nat_mangle_tcp_packet(pskb, ct, ctinfo, matchoff,
+	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
 					matchlen, buffer, strlen(buffer));
 }
 
 /* |1|132.235.1.2|6275| */
 static int
-mangle_epsv_packet(struct sk_buff **pskb,
+mangle_epsv_packet(struct sk_buff *skb,
 		   __be32 newip,
 		   u_int16_t port,
 		   unsigned int matchoff,
@@ -83,11 +83,11 @@ mangle_epsv_packet(struct sk_buff **pskb,
 
 	pr_debug("calling nf_nat_mangle_tcp_packet\n");
 
-	return nf_nat_mangle_tcp_packet(pskb, ct, ctinfo, matchoff,
+	return nf_nat_mangle_tcp_packet(skb, ct, ctinfo, matchoff,
 					matchlen, buffer, strlen(buffer));
 }
 
-static int (*mangle[])(struct sk_buff **, __be32, u_int16_t,
+static int (*mangle[])(struct sk_buff *, __be32, u_int16_t,
 		       unsigned int, unsigned int, struct nf_conn *,
 		       enum ip_conntrack_info)
 = {
@@ -99,7 +99,7 @@ static int (*mangle[])(struct sk_buff **, __be32, u_int16_t,
 
 /* So, this packet has hit the connection tracking matching code.
    Mangle it, and change the expectation to match the new version. */
-static unsigned int nf_nat_ftp(struct sk_buff **pskb,
+static unsigned int nf_nat_ftp(struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
 			       enum nf_ct_ftp_type type,
 			       unsigned int matchoff,
@@ -132,7 +132,7 @@ static unsigned int nf_nat_ftp(struct sk_buff **pskb,
 	if (port == 0)
 		return NF_DROP;
 
-	if (!mangle[type](pskb, newip, port, matchoff, matchlen, ct, ctinfo)) {
+	if (!mangle[type](skb, newip, port, matchoff, matchlen, ct, ctinfo)) {
 		nf_ct_unexpect_related(exp);
 		return NF_DROP;
 	}
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index c1b059a..a868c8c 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -22,12 +22,12 @@
 #include <linux/netfilter/nf_conntrack_h323.h>
 
 /****************************************************************************/
-static int set_addr(struct sk_buff **pskb,
+static int set_addr(struct sk_buff *skb,
 		    unsigned char **data, int dataoff,
 		    unsigned int addroff, __be32 ip, __be16 port)
 {
 	enum ip_conntrack_info ctinfo;
-	struct nf_conn *ct = nf_ct_get(*pskb, &ctinfo);
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
 	struct {
 		__be32 ip;
 		__be16 port;
@@ -38,8 +38,8 @@ static int set_addr(struct sk_buff **pskb,
 	buf.port = port;
 	addroff += dataoff;
 
-	if (ip_hdr(*pskb)->protocol == IPPROTO_TCP) {
-		if (!nf_nat_mangle_tcp_packet(pskb, ct, ctinfo,
+	if (ip_hdr(skb)->protocol == IPPROTO_TCP) {
+		if (!nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
@@ -49,14 +49,13 @@ static int set_addr(struct sk_buff **pskb,
 		}
 
 		/* Relocate data pointer */
-		th = skb_header_pointer(*pskb, ip_hdrlen(*pskb),
+		th = skb_header_pointer(skb, ip_hdrlen(skb),
 					sizeof(_tcph), &_tcph);
 		if (th == NULL)
 			return -1;
-		*data = (*pskb)->data + ip_hdrlen(*pskb) +
-		    th->doff * 4 + dataoff;
+		*data = skb->data + ip_hdrlen(skb) + th->doff * 4 + dataoff;
 	} else {
-		if (!nf_nat_mangle_udp_packet(pskb, ct, ctinfo,
+		if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 					      addroff, sizeof(buf),
 					      (char *) &buf, sizeof(buf))) {
 			if (net_ratelimit())
@@ -67,36 +66,35 @@ static int set_addr(struct sk_buff **pskb,
 		/* nf_nat_mangle_udp_packet uses skb_make_writable() to copy
 		 * or pull everything in a linear buffer, so we can safely
 		 * use the skb pointers now */
-		*data = ((*pskb)->data + ip_hdrlen(*pskb) +
-			 sizeof(struct udphdr));
+		*data = skb->data + ip_hdrlen(skb) + sizeof(struct udphdr);
 	}
 
 	return 0;
 }
 
 /****************************************************************************/
-static int set_h225_addr(struct sk_buff **pskb,
+static int set_h225_addr(struct sk_buff *skb,
 			 unsigned char **data, int dataoff,
 			 TransportAddress *taddr,
 			 union nf_conntrack_address *addr, __be16 port)
 {
-	return set_addr(pskb, data, dataoff, taddr->ipAddress.ip,
+	return set_addr(skb, data, dataoff, taddr->ipAddress.ip,
 			addr->ip, port);
 }
 
 /****************************************************************************/
-static int set_h245_addr(struct sk_buff **pskb,
+static int set_h245_addr(struct sk_buff *skb,
 			 unsigned char **data, int dataoff,
 			 H245_TransportAddress *taddr,
 			 union nf_conntrack_address *addr, __be16 port)
 {
-	return set_addr(pskb, data, dataoff,
+	return set_addr(skb, data, dataoff,
 			taddr->unicastAddress.iPAddress.network,
 			addr->ip, port);
 }
 
 /****************************************************************************/
-static int set_sig_addr(struct sk_buff **pskb, struct nf_conn *ct,
+static int set_sig_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data,
 			TransportAddress *taddr, int count)
@@ -125,7 +123,7 @@ static int set_sig_addr(struct sk_buff **pskb, struct nf_conn *ct,
 					 NIPQUAD(addr.ip), port,
 					 NIPQUAD(ct->tuplehash[!dir].tuple.dst.u3.ip),
 					 info->sig_port[!dir]);
-				return set_h225_addr(pskb, data, 0, &taddr[i],
+				return set_h225_addr(skb, data, 0, &taddr[i],
 						     &ct->tuplehash[!dir].
 						     tuple.dst.u3,
 						     info->sig_port[!dir]);
@@ -137,7 +135,7 @@ static int set_sig_addr(struct sk_buff **pskb, struct nf_conn *ct,
 					 NIPQUAD(addr.ip), port,
 					 NIPQUAD(ct->tuplehash[!dir].tuple.src.u3.ip),
 					 info->sig_port[!dir]);
-				return set_h225_addr(pskb, data, 0, &taddr[i],
+				return set_h225_addr(skb, data, 0, &taddr[i],
 						     &ct->tuplehash[!dir].
 						     tuple.src.u3,
 						     info->sig_port[!dir]);
@@ -149,7 +147,7 @@ static int set_sig_addr(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int set_ras_addr(struct sk_buff **pskb, struct nf_conn *ct,
+static int set_ras_addr(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data,
 			TransportAddress *taddr, int count)
@@ -168,7 +166,7 @@ static int set_ras_addr(struct sk_buff **pskb, struct nf_conn *ct,
 				 NIPQUAD(addr.ip), ntohs(port),
 				 NIPQUAD(ct->tuplehash[!dir].tuple.dst.u3.ip),
 				 ntohs(ct->tuplehash[!dir].tuple.dst.u.udp.port));
-			return set_h225_addr(pskb, data, 0, &taddr[i],
+			return set_h225_addr(skb, data, 0, &taddr[i],
 					     &ct->tuplehash[!dir].tuple.dst.u3,
 					     ct->tuplehash[!dir].tuple.
 								dst.u.udp.port);
@@ -179,7 +177,7 @@ static int set_ras_addr(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int nat_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
+static int nat_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data, int dataoff,
 			H245_TransportAddress *taddr,
@@ -244,7 +242,7 @@ static int nat_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h245_addr(pskb, data, dataoff, taddr,
+	if (set_h245_addr(skb, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons((port & htons(1)) ? nated_port + 1 :
 						    nated_port)) == 0) {
@@ -273,7 +271,7 @@ static int nat_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int nat_t120(struct sk_buff **pskb, struct nf_conn *ct,
+static int nat_t120(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
 		    unsigned char **data, int dataoff,
 		    H245_TransportAddress *taddr, __be16 port,
@@ -301,7 +299,7 @@ static int nat_t120(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h245_addr(pskb, data, dataoff, taddr,
+	if (set_h245_addr(skb, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) < 0) {
 		nf_ct_unexpect_related(exp);
@@ -318,7 +316,7 @@ static int nat_t120(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int nat_h245(struct sk_buff **pskb, struct nf_conn *ct,
+static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
 		    unsigned char **data, int dataoff,
 		    TransportAddress *taddr, __be16 port,
@@ -351,7 +349,7 @@ static int nat_h245(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h225_addr(pskb, data, dataoff, taddr,
+	if (set_h225_addr(skb, data, dataoff, taddr,
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) == 0) {
 		/* Save ports */
@@ -406,7 +404,7 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 }
 
 /****************************************************************************/
-static int nat_q931(struct sk_buff **pskb, struct nf_conn *ct,
+static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo,
 		    unsigned char **data, TransportAddress *taddr, int idx,
 		    __be16 port, struct nf_conntrack_expect *exp)
@@ -439,7 +437,7 @@ static int nat_q931(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (set_h225_addr(pskb, data, 0, &taddr[idx],
+	if (set_h225_addr(skb, data, 0, &taddr[idx],
 			  &ct->tuplehash[!dir].tuple.dst.u3,
 			  htons(nated_port)) == 0) {
 		/* Save ports */
@@ -450,7 +448,7 @@ static int nat_q931(struct sk_buff **pskb, struct nf_conn *ct,
 		if (idx > 0 &&
 		    get_h225_addr(ct, *data, &taddr[0], &addr, &port) &&
 		    (ntohl(addr.ip) & 0xff000000) == 0x7f000000) {
-			set_h225_addr(pskb, data, 0, &taddr[0],
+			set_h225_addr(skb, data, 0, &taddr[0],
 				      &ct->tuplehash[!dir].tuple.dst.u3,
 				      info->sig_port[!dir]);
 		}
@@ -495,7 +493,7 @@ static void ip_nat_callforwarding_expect(struct nf_conn *new,
 }
 
 /****************************************************************************/
-static int nat_callforwarding(struct sk_buff **pskb, struct nf_conn *ct,
+static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 			      enum ip_conntrack_info ctinfo,
 			      unsigned char **data, int dataoff,
 			      TransportAddress *taddr, __be16 port,
@@ -525,7 +523,7 @@ static int nat_callforwarding(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	/* Modify signal */
-	if (!set_h225_addr(pskb, data, dataoff, taddr,
+	if (!set_h225_addr(skb, data, dataoff, taddr,
 			   &ct->tuplehash[!dir].tuple.dst.u3,
 			   htons(nated_port)) == 0) {
 		nf_ct_unexpect_related(exp);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 434ef30..a4edd66 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -78,7 +78,7 @@ static int xfrm4_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm4_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET, NF_IP_LOCAL_OUT, &skb, NULL,
+		err = nf_hook(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, dst_output);
 		if (unlikely(err != 1))
 			break;
@@ -86,7 +86,7 @@ static int xfrm4_output_finish2(struct sk_buff *skb)
 		if (!skb->dst->xfrm)
 			return dst_output(skb);
 
-		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, &skb, NULL,
+		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
 			      skb->dst->dev, xfrm4_output_finish2);
 		if (unlikely(err != 1))
 			break;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 37a3db9..e9369dc 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -145,7 +145,7 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 }
 
 static unsigned int ipv6_confirm(unsigned int hooknum,
-				 struct sk_buff **pskb,
+				 struct sk_buff *skb,
 				 const struct net_device *in,
 				 const struct net_device *out,
 				 int (*okfn)(struct sk_buff *))
@@ -155,12 +155,12 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	struct nf_conntrack_helper *helper;
 	enum ip_conntrack_info ctinfo;
 	unsigned int ret, protoff;
-	unsigned int extoff = (u8 *)(ipv6_hdr(*pskb) + 1) - (*pskb)->data;
-	unsigned char pnum = ipv6_hdr(*pskb)->nexthdr;
+	unsigned int extoff = (u8 *)(ipv6_hdr(skb) + 1) - skb->data;
+	unsigned char pnum = ipv6_hdr(skb)->nexthdr;
 
 
 	/* This is where we call the helper: as the packet goes out. */
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED + IP_CT_IS_REPLY)
 		goto out;
 
@@ -172,23 +172,23 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	if (!helper)
 		goto out;
 
-	protoff = nf_ct_ipv6_skip_exthdr(*pskb, extoff, &pnum,
-					 (*pskb)->len - extoff);
-	if (protoff > (*pskb)->len || pnum == NEXTHDR_FRAGMENT) {
+	protoff = nf_ct_ipv6_skip_exthdr(skb, extoff, &pnum,
+					 skb->len - extoff);
+	if (protoff > skb->len || pnum == NEXTHDR_FRAGMENT) {
 		pr_debug("proto header not found\n");
 		return NF_ACCEPT;
 	}
 
-	ret = helper->help(pskb, protoff, ct, ctinfo);
+	ret = helper->help(skb, protoff, ct, ctinfo);
 	if (ret != NF_ACCEPT)
 		return ret;
 out:
 	/* We've seen it coming out the other side: confirm it */
-	return nf_conntrack_confirm(pskb);
+	return nf_conntrack_confirm(skb);
 }
 
 static unsigned int ipv6_defrag(unsigned int hooknum,
-				struct sk_buff **pskb,
+				struct sk_buff *skb,
 				const struct net_device *in,
 				const struct net_device *out,
 				int (*okfn)(struct sk_buff *))
@@ -196,17 +196,17 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	struct sk_buff *reasm;
 
 	/* Previously seen (loopback)?  */
-	if ((*pskb)->nfct)
+	if (skb->nfct)
 		return NF_ACCEPT;
 
-	reasm = nf_ct_frag6_gather(*pskb);
+	reasm = nf_ct_frag6_gather(skb);
 
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
 
 	/* error occured or not fragmented */
-	if (reasm == *pskb)
+	if (reasm == skb)
 		return NF_ACCEPT;
 
 	nf_ct_frag6_output(hooknum, reasm, (struct net_device *)in,
@@ -216,12 +216,12 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 }
 
 static unsigned int ipv6_conntrack_in(unsigned int hooknum,
-				      struct sk_buff **pskb,
+				      struct sk_buff *skb,
 				      const struct net_device *in,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	struct sk_buff *reasm = (*pskb)->nfct_reasm;
+	struct sk_buff *reasm = skb->nfct_reasm;
 
 	/* This packet is fragmented and has reassembled packet. */
 	if (reasm) {
@@ -229,32 +229,32 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 		if (!reasm->nfct) {
 			unsigned int ret;
 
-			ret = nf_conntrack_in(PF_INET6, hooknum, &reasm);
+			ret = nf_conntrack_in(PF_INET6, hooknum, reasm);
 			if (ret != NF_ACCEPT)
 				return ret;
 		}
 		nf_conntrack_get(reasm->nfct);
-		(*pskb)->nfct = reasm->nfct;
-		(*pskb)->nfctinfo = reasm->nfctinfo;
+		skb->nfct = reasm->nfct;
+		skb->nfctinfo = reasm->nfctinfo;
 		return NF_ACCEPT;
 	}
 
-	return nf_conntrack_in(PF_INET6, hooknum, pskb);
+	return nf_conntrack_in(PF_INET6, hooknum, skb);
 }
 
 static unsigned int ipv6_conntrack_local(unsigned int hooknum,
-					 struct sk_buff **pskb,
+					 struct sk_buff *skb,
 					 const struct net_device *in,
 					 const struct net_device *out,
 					 int (*okfn)(struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct ipv6hdr)) {
+	if (skb->len < sizeof(struct ipv6hdr)) {
 		if (net_ratelimit())
 			printk("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return ipv6_conntrack_in(hooknum, pskb, in, out, okfn);
+	return ipv6_conntrack_in(hooknum, skb, in, out, okfn);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] = {
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 4618c18..a5a32c1 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -80,7 +80,7 @@ static int xfrm6_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm6_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, &skb, NULL,
+		err = nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
 			      skb->dst->dev, dst_output);
 		if (unlikely(err != 1))
 			break;
@@ -88,7 +88,7 @@ static int xfrm6_output_finish2(struct sk_buff *skb)
 		if (!skb->dst->xfrm)
 			return dst_output(skb);
 
-		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, &skb, NULL,
+		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL,
 			      skb->dst->dev, xfrm6_output_finish2);
 		if (unlikely(err != 1))
 			break;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index a481a34..0cef143 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -256,14 +256,14 @@ void nf_reinject(struct sk_buff *skb, struct nf_info *info,
 
 	if (verdict == NF_ACCEPT) {
 		afinfo = nf_get_afinfo(info->pf);
-		if (!afinfo || afinfo->reroute(&skb, info) < 0)
+		if (!afinfo || afinfo->reroute(skb, info) < 0)
 			verdict = NF_DROP;
 	}
 
 	if (verdict == NF_ACCEPT) {
 	next_hook:
 		verdict = nf_iterate(&nf_hooks[info->pf][info->hook],
-				     &skb, info->hook,
+				     skb, info->hook,
 				     info->indev, info->outdev, &elem,
 				     info->okfn, INT_MIN);
 	}
diff --git a/net/netfilter/xt_SECMARK.c b/net/netfilter/xt_SECMARK.c
index c83779a..235806e 100644
--- a/net/netfilter/xt_SECMARK.c
+++ b/net/netfilter/xt_SECMARK.c
@@ -28,7 +28,7 @@ MODULE_ALIAS("ip6t_SECMARK");
 
 static u8 mode;
 
-static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
+static unsigned int target(struct sk_buff *skb, const struct net_device *in,
 			   const struct net_device *out, unsigned int hooknum,
 			   const struct xt_target *target,
 			   const void *targinfo)
@@ -47,7 +47,7 @@ static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
 		BUG();
 	}
 
-	(*pskb)->secmark = secmark;
+	skb->secmark = secmark;
 	return XT_CONTINUE;
 }
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index f111edf..07435a6 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -39,7 +39,7 @@ optlen(const u_int8_t *opt, unsigned int offset)
 }
 
 static int
-tcpmss_mangle_packet(struct sk_buff **pskb,
+tcpmss_mangle_packet(struct sk_buff *skb,
 		     const struct xt_tcpmss_info *info,
 		     unsigned int tcphoff,
 		     unsigned int minlen)
@@ -50,11 +50,11 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 	u16 newmss;
 	u8 *opt;
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return -1;
 
-	tcplen = (*pskb)->len - tcphoff;
-	tcph = (struct tcphdr *)(skb_network_header(*pskb) + tcphoff);
+	tcplen = skb->len - tcphoff;
+	tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 
 	/* Since it passed flags test in tcp match, we know it is is
 	   not a fragment, and has data >= tcp header length.  SYN
@@ -64,19 +64,19 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 	if (tcplen != tcph->doff*4) {
 		if (net_ratelimit())
 			printk(KERN_ERR "xt_TCPMSS: bad length (%u bytes)\n",
-			       (*pskb)->len);
+			       skb->len);
 		return -1;
 	}
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU) {
-		if (dst_mtu((*pskb)->dst) <= minlen) {
+		if (dst_mtu(skb->dst) <= minlen) {
 			if (net_ratelimit())
 				printk(KERN_ERR "xt_TCPMSS: "
 				       "unknown or invalid path-MTU (%u)\n",
-				       dst_mtu((*pskb)->dst));
+				       dst_mtu(skb->dst));
 			return -1;
 		}
-		newmss = dst_mtu((*pskb)->dst) - minlen;
+		newmss = dst_mtu(skb->dst) - minlen;
 	} else
 		newmss = info->mss;
 
@@ -95,7 +95,7 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 			opt[i+2] = (newmss & 0xff00) >> 8;
 			opt[i+3] = newmss & 0x00ff;
 
-			nf_proto_csum_replace2(&tcph->check, *pskb,
+			nf_proto_csum_replace2(&tcph->check, skb,
 					       htons(oldmss), htons(newmss), 0);
 			return 0;
 		}
@@ -104,53 +104,53 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 	/*
 	 * MSS Option not found ?! add it..
 	 */
-	if (skb_tailroom((*pskb)) < TCPOLEN_MSS) {
-		if (pskb_expand_head(*pskb, 0,
-				     TCPOLEN_MSS - skb_tailroom(*pskb),
+	if (skb_tailroom(skb) < TCPOLEN_MSS) {
+		if (pskb_expand_head(skb, 0,
+				     TCPOLEN_MSS - skb_tailroom(skb),
 				     GFP_ATOMIC))
 			return -1;
-		tcph = (struct tcphdr *)(skb_network_header(*pskb) + tcphoff);
+		tcph = (struct tcphdr *)(skb_network_header(skb) + tcphoff);
 	}
 
-	skb_put((*pskb), TCPOLEN_MSS);
+	skb_put(skb, TCPOLEN_MSS);
 
 	opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
 	memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
 
-	nf_proto_csum_replace2(&tcph->check, *pskb,
+	nf_proto_csum_replace2(&tcph->check, skb,
 			       htons(tcplen), htons(tcplen + TCPOLEN_MSS), 1);
 	opt[0] = TCPOPT_MSS;
 	opt[1] = TCPOLEN_MSS;
 	opt[2] = (newmss & 0xff00) >> 8;
 	opt[3] = newmss & 0x00ff;
 
-	nf_proto_csum_replace4(&tcph->check, *pskb, 0, *((__be32 *)opt), 0);
+	nf_proto_csum_replace4(&tcph->check, skb, 0, *((__be32 *)opt), 0);
 
 	oldval = ((__be16 *)tcph)[6];
 	tcph->doff += TCPOLEN_MSS/4;
-	nf_proto_csum_replace2(&tcph->check, *pskb,
+	nf_proto_csum_replace2(&tcph->check, skb,
 				oldval, ((__be16 *)tcph)[6], 0);
 	return TCPOLEN_MSS;
 }
 
 static unsigned int
-xt_tcpmss_target4(struct sk_buff **pskb,
+xt_tcpmss_target4(struct sk_buff *skb,
 		  const struct net_device *in,
 		  const struct net_device *out,
 		  unsigned int hooknum,
 		  const struct xt_target *target,
 		  const void *targinfo)
 {
-	struct iphdr *iph = ip_hdr(*pskb);
+	struct iphdr *iph = ip_hdr(skb);
 	__be16 newlen;
 	int ret;
 
-	ret = tcpmss_mangle_packet(pskb, targinfo, iph->ihl * 4,
+	ret = tcpmss_mangle_packet(skb, targinfo, iph->ihl * 4,
 				   sizeof(*iph) + sizeof(struct tcphdr));
 	if (ret < 0)
 		return NF_DROP;
 	if (ret > 0) {
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 		newlen = htons(ntohs(iph->tot_len) + ret);
 		nf_csum_replace2(&iph->check, iph->tot_len, newlen);
 		iph->tot_len = newlen;
@@ -160,30 +160,30 @@ xt_tcpmss_target4(struct sk_buff **pskb,
 
 #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES_MODULE)
 static unsigned int
-xt_tcpmss_target6(struct sk_buff **pskb,
+xt_tcpmss_target6(struct sk_buff *skb,
 		  const struct net_device *in,
 		  const struct net_device *out,
 		  unsigned int hooknum,
 		  const struct xt_target *target,
 		  const void *targinfo)
 {
-	struct ipv6hdr *ipv6h = ipv6_hdr(*pskb);
+	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	u8 nexthdr;
 	int tcphoff;
 	int ret;
 
 	nexthdr = ipv6h->nexthdr;
-	tcphoff = ipv6_skip_exthdr(*pskb, sizeof(*ipv6h), &nexthdr);
+	tcphoff = ipv6_skip_exthdr(skb, sizeof(*ipv6h), &nexthdr);
 	if (tcphoff < 0) {
 		WARN_ON(1);
 		return NF_DROP;
 	}
-	ret = tcpmss_mangle_packet(pskb, targinfo, tcphoff,
+	ret = tcpmss_mangle_packet(skb, targinfo, tcphoff,
 				   sizeof(*ipv6h) + sizeof(struct tcphdr));
 	if (ret < 0)
 		return NF_DROP;
 	if (ret > 0) {
-		ipv6h = ipv6_hdr(*pskb);
+		ipv6h = ipv6_hdr(skb);
 		ipv6h->payload_len = htons(ntohs(ipv6h->payload_len) + ret);
 	}
 	return XT_CONTINUE;
diff --git a/net/netfilter/xt_TRACE.c b/net/netfilter/xt_TRACE.c
index 4df2ded..26c5d08 100644
--- a/net/netfilter/xt_TRACE.c
+++ b/net/netfilter/xt_TRACE.c
@@ -10,14 +10,14 @@ MODULE_ALIAS("ipt_TRACE");
 MODULE_ALIAS("ip6t_TRACE");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
        const struct xt_target *target,
        const void *targinfo)
 {
-	(*pskb)->nf_trace = 1;
+	skb->nf_trace = 1;
 	return XT_CONTINUE;
 }
 
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 6b407ec..fa006e0 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -202,11 +202,7 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
 	/* yes, we have to worry about both in and out dev
 	 worry later - danger - this API seems to have changed
 	 from earlier kernels */
-
-	/* iptables targets take a double skb pointer in case the skb
-	 * needs to be replaced. We don't own the skb, so this must not
-	 * happen. The pskb_expand_head above should make sure of this */
-	ret = ipt->tcfi_t->u.kernel.target->target(&skb, skb->dev, NULL,
+	ret = ipt->tcfi_t->u.kernel.target->target(skb, skb->dev, NULL,
 						   ipt->tcfi_hook,
 						   ipt->tcfi_t->u.kernel.target,
 						   ipt->tcfi_t->data);
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 2d32fd2..3f8335e 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -205,20 +205,19 @@ static unsigned int ingress_drop(struct Qdisc *sch)
 #ifndef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NETFILTER
 static unsigned int
-ing_hook(unsigned int hook, struct sk_buff **pskb,
+ing_hook(unsigned int hook, struct sk_buff *skb,
 			     const struct net_device *indev,
 			     const struct net_device *outdev,
 			     int (*okfn)(struct sk_buff *))
 {
 
 	struct Qdisc *q;
-	struct sk_buff *skb = *pskb;
 	struct net_device *dev = skb->dev;
 	int fwres=NF_ACCEPT;
 
 	DPRINTK("ing_hook: skb %s dev=%s len=%u\n",
 		skb->sk ? "(owned)" : "(unowned)",
-		skb->dev ? (*pskb)->dev->name : "(no dev)",
+		skb->dev ? skb->dev->name : "(no dev)",
 		skb->len);
 
 	if (dev->qdisc_ingress) {
