From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 10/10] [NETFILTER]: Replace sk_buff ** with sk_buff *
Date: Sun, 14 Oct 2007 17:55:41 +0800
Message-ID: <20071014095541.GA13222@gondor.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4v-00031H-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3634 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754748AbXJNJ4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 05:56:40 -0400
Content-Disposition: inline
In-Reply-To: <E1Igv4v-00031H-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 14, 2007 at 12:27:49PM +0800, Herbert Xu wrote:
> [NETFILTER]: Replace sk_buff ** with sk_buff *
>
>  74 files changed, 469 insertions(+), 503 deletions(-)

Between me going to bed last night and waking up this morning,
my editor wandered off causing half of the patch to disappear :)

Here is the corrected version.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
[NETFILTER]: Replace sk_buff ** with sk_buff *

With all the users of the double pointers removed, this patch mops up by
finally replacing all occurances of sk_buff ** in the netfilter API by
sk_buff *.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/if_bridge.h                      |    2 
 include/linux/netfilter.h                      |   24 +-
 include/linux/netfilter/nf_conntrack_amanda.h  |    2 
 include/linux/netfilter/nf_conntrack_ftp.h     |    2 
 include/linux/netfilter/nf_conntrack_h323.h    |   18 -
 include/linux/netfilter/nf_conntrack_irc.h     |    2 
 include/linux/netfilter/nf_conntrack_pptp.h    |    4 
 include/linux/netfilter/nf_conntrack_sip.h     |    4 
 include/linux/netfilter/nf_conntrack_tftp.h    |    2 
 include/linux/netfilter/x_tables.h             |    2 
 include/linux/netfilter_arp/arp_tables.h       |    2 
 include/linux/netfilter_bridge/ebtables.h      |    4 
 include/linux/netfilter_ipv4.h                 |    4 
 include/linux/netfilter_ipv4/ip_tables.h       |    2 
 include/linux/netfilter_ipv6/ip6_tables.h      |    2 
 include/net/ip_vs.h                            |   12 -
 include/net/netfilter/nf_conntrack_core.h      |   10 -
 include/net/netfilter/nf_conntrack_helper.h    |    2 
 include/net/netfilter/nf_nat_core.h            |    4 
 include/net/netfilter/nf_nat_helper.h          |    6 
 include/net/netfilter/nf_nat_protocol.h        |    2 
 include/net/netfilter/nf_nat_rule.h            |    2 
 net/bridge/br.c                                |    2 
 net/bridge/br_input.c                          |    2 
 net/bridge/br_netfilter.c                      |   33 +--
 net/bridge/netfilter/ebt_arpreply.c            |    3 
 net/bridge/netfilter/ebt_dnat.c                |    6 
 net/bridge/netfilter/ebt_mark.c                |   10 -
 net/bridge/netfilter/ebt_redirect.c            |   10 -
 net/bridge/netfilter/ebt_snat.c                |   12 -
 net/bridge/netfilter/ebtable_broute.c          |    4 
 net/bridge/netfilter/ebtable_filter.c          |    4 
 net/bridge/netfilter/ebtable_nat.c             |    8 
 net/bridge/netfilter/ebtables.c                |   12 -
 net/decnet/netfilter/dn_rtmsg.c                |    4 
 net/ipv4/ipvs/ip_vs_app.c                      |   32 +--
 net/ipv4/ipvs/ip_vs_core.c                     |   36 +--
 net/ipv4/ipvs/ip_vs_ftp.c                      |   18 -
 net/ipv4/ipvs/ip_vs_proto_tcp.c                |   50 ++---
 net/ipv4/ipvs/ip_vs_proto_udp.c                |   50 ++---
 net/ipv4/ipvs/ip_vs_xmit.c                     |    2 
 net/ipv4/netfilter.c                           |   58 ++----
 net/ipv4/netfilter/arp_tables.c                |   20 +-
 net/ipv4/netfilter/arpt_mangle.c               |   16 -
 net/ipv4/netfilter/arptable_filter.c           |    4 
 net/ipv4/netfilter/ip_tables.c                 |   20 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   14 -
 net/ipv4/netfilter/ipt_ECN.c                   |   27 +-
 net/ipv4/netfilter/ipt_LOG.c                   |    4 
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    6 
 net/ipv4/netfilter/ipt_NETMAP.c                |    8 
 net/ipv4/netfilter/ipt_REDIRECT.c              |    6 
 net/ipv4/netfilter/ipt_REJECT.c                |   22 +-
 net/ipv4/netfilter/ipt_SAME.c                  |    4 
 net/ipv4/netfilter/ipt_TOS.c                   |    8 
 net/ipv4/netfilter/ipt_TTL.c                   |    6 
 net/ipv4/netfilter/ipt_ULOG.c                  |    4 
 net/ipv4/netfilter/iptable_filter.c            |   12 -
 net/ipv4/netfilter/iptable_mangle.c            |   22 +-
 net/ipv4/netfilter/iptable_raw.c               |   12 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   30 +--
 net/ipv4/netfilter/nf_nat_amanda.c             |    4 
 net/ipv4/netfilter/nf_nat_core.c               |   50 ++---
 net/ipv4/netfilter/nf_nat_ftp.c                |   18 -
 net/ipv4/netfilter/nf_nat_h323.c               |   58 ++----
 net/ipv4/netfilter/nf_nat_helper.c             |  110 +++++------
 net/ipv4/netfilter/nf_nat_irc.c                |    4 
 net/ipv4/netfilter/nf_nat_pptp.c               |    8 
 net/ipv4/netfilter/nf_nat_proto_gre.c          |    8 
 net/ipv4/netfilter/nf_nat_proto_icmp.c         |   10 -
 net/ipv4/netfilter/nf_nat_proto_tcp.c          |   16 -
 net/ipv4/netfilter/nf_nat_proto_udp.c          |   16 -
 net/ipv4/netfilter/nf_nat_proto_unknown.c      |    2 
 net/ipv4/netfilter/nf_nat_rule.c               |   14 -
 net/ipv4/netfilter/nf_nat_sip.c                |   56 ++---
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |   14 -
 net/ipv4/netfilter/nf_nat_standalone.c         |   62 +++---
 net/ipv4/netfilter/nf_nat_tftp.c               |    2 
 net/ipv4/xfrm4_output.c                        |    4 
 net/ipv6/netfilter.c                           |    6 
 net/ipv6/netfilter/ip6_tables.c                |   16 -
 net/ipv6/netfilter/ip6t_HL.c                   |    6 
 net/ipv6/netfilter/ip6t_LOG.c                  |    5 
 net/ipv6/netfilter/ip6t_REJECT.c               |   14 -
 net/ipv6/netfilter/ip6table_filter.c           |   12 -
 net/ipv6/netfilter/ip6table_mangle.c           |   32 +--
 net/ipv6/netfilter/ip6table_raw.c              |    4 
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   44 ++--
 net/ipv6/xfrm6_output.c                        |    4 
 net/netfilter/core.c                           |   10 -
 net/netfilter/nf_conntrack_amanda.c            |   20 +-
 net/netfilter/nf_conntrack_core.c              |   30 +--
 net/netfilter/nf_conntrack_ftp.c               |   18 -
 net/netfilter/nf_conntrack_h323_main.c         |  236 ++++++++++++-------------
 net/netfilter/nf_conntrack_irc.c               |   16 -
 net/netfilter/nf_conntrack_netbios_ns.c        |   10 -
 net/netfilter/nf_conntrack_pptp.c              |   28 +-
 net/netfilter/nf_conntrack_sane.c              |   10 -
 net/netfilter/nf_conntrack_sip.c               |   24 +-
 net/netfilter/nf_conntrack_tftp.c              |    8 
 net/netfilter/nf_internals.h                   |    2 
 net/netfilter/nf_queue.c                       |    4 
 net/netfilter/xt_CLASSIFY.c                    |    4 
 net/netfilter/xt_CONNMARK.c                    |   14 -
 net/netfilter/xt_CONNSECMARK.c                 |    3 
 net/netfilter/xt_DSCP.c                        |   16 -
 net/netfilter/xt_MARK.c                        |   12 -
 net/netfilter/xt_NFLOG.c                       |    4 
 net/netfilter/xt_NFQUEUE.c                     |    2 
 net/netfilter/xt_NOTRACK.c                     |   10 -
 net/netfilter/xt_SECMARK.c                     |    4 
 net/netfilter/xt_TCPMSS.c                      |   52 ++---
 net/netfilter/xt_TRACE.c                       |    4 
 net/sched/act_ipt.c                            |    6 
 net/sched/sch_ingress.c                        |    5 
 115 files changed, 915 insertions(+), 951 deletions(-)

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
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 40b429e..8718da0 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -111,12 +111,12 @@ static void mangle_contents(struct sk_buff *skb,
 }
 
 /* Unusual, but possible case. */
-static int enlarge_skb(struct sk_buff **pskb, unsigned int extra)
+static int enlarge_skb(struct sk_buff *skb, unsigned int extra)
 {
-	if ((*pskb)->len + extra > 65535)
+	if (skb->len + extra > 65535)
 		return 0;
 
-	if (pskb_expand_head(*pskb, 0, extra - skb_tailroom(*pskb), GFP_ATOMIC))
+	if (pskb_expand_head(skb, 0, extra - skb_tailroom(skb), GFP_ATOMIC))
 		return 0;
 
 	return 1;
@@ -131,7 +131,7 @@ static int enlarge_skb(struct sk_buff **pskb, unsigned int extra)
  *
  * */
 int
-nf_nat_mangle_tcp_packet(struct sk_buff **pskb,
+nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			 struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned int match_offset,
@@ -139,37 +139,37 @@ nf_nat_mangle_tcp_packet(struct sk_buff **pskb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = (struct rtable *)(*pskb)->dst;
+	struct rtable *rt = (struct rtable *)skb->dst;
 	struct iphdr *iph;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
 	if (rep_len > match_len &&
-	    rep_len - match_len > skb_tailroom(*pskb) &&
-	    !enlarge_skb(pskb, rep_len - match_len))
+	    rep_len - match_len > skb_tailroom(skb) &&
+	    !enlarge_skb(skb, rep_len - match_len))
 		return 0;
 
-	SKB_LINEAR_ASSERT(*pskb);
+	SKB_LINEAR_ASSERT(skb);
 
-	iph = ip_hdr(*pskb);
+	iph = ip_hdr(skb);
 	tcph = (void *)iph + iph->ihl*4;
 
-	oldlen = (*pskb)->len - iph->ihl*4;
-	mangle_contents(*pskb, iph->ihl*4 + tcph->doff*4,
+	oldlen = skb->len - iph->ihl*4;
+	mangle_contents(skb, iph->ihl*4 + tcph->doff*4,
 			match_offset, match_len, rep_buffer, rep_len);
 
-	datalen = (*pskb)->len - iph->ihl*4;
-	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
+	datalen = skb->len - iph->ihl*4;
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (*pskb)->dev->features & NETIF_F_V4_CSUM) {
-			(*pskb)->ip_summed = CHECKSUM_PARTIAL;
-			(*pskb)->csum_start = skb_headroom(*pskb) +
-					      skb_network_offset(*pskb) +
-					      iph->ihl * 4;
-			(*pskb)->csum_offset = offsetof(struct tcphdr, check);
+		    skb->dev->features & NETIF_F_V4_CSUM) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_headroom(skb) +
+					  skb_network_offset(skb) +
+					  iph->ihl * 4;
+			skb->csum_offset = offsetof(struct tcphdr, check);
 			tcph->check = ~tcp_v4_check(datalen,
 						    iph->saddr, iph->daddr, 0);
 		} else {
@@ -180,7 +180,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff **pskb,
 								datalen, 0));
 		}
 	} else
-		nf_proto_csum_replace2(&tcph->check, *pskb,
+		nf_proto_csum_replace2(&tcph->check, skb,
 				       htons(oldlen), htons(datalen), 1);
 
 	if (rep_len != match_len) {
@@ -189,7 +189,7 @@ nf_nat_mangle_tcp_packet(struct sk_buff **pskb,
 				    (int)rep_len - (int)match_len,
 				    ct, ctinfo);
 		/* Tell TCP window tracking about seq change */
-		nf_conntrack_tcp_update(*pskb, ip_hdrlen(*pskb),
+		nf_conntrack_tcp_update(skb, ip_hdrlen(skb),
 					ct, CTINFO2DIR(ctinfo));
 	}
 	return 1;
@@ -207,7 +207,7 @@ EXPORT_SYMBOL(nf_nat_mangle_tcp_packet);
  *       should be fairly easy to do.
  */
 int
-nf_nat_mangle_udp_packet(struct sk_buff **pskb,
+nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned int match_offset,
@@ -215,48 +215,48 @@ nf_nat_mangle_udp_packet(struct sk_buff **pskb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = (struct rtable *)(*pskb)->dst;
+	struct rtable *rt = (struct rtable *)skb->dst;
 	struct iphdr *iph;
 	struct udphdr *udph;
 	int datalen, oldlen;
 
 	/* UDP helpers might accidentally mangle the wrong packet */
-	iph = ip_hdr(*pskb);
-	if ((*pskb)->len < iph->ihl*4 + sizeof(*udph) +
+	iph = ip_hdr(skb);
+	if (skb->len < iph->ihl*4 + sizeof(*udph) +
 			       match_offset + match_len)
 		return 0;
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return 0;
 
 	if (rep_len > match_len &&
-	    rep_len - match_len > skb_tailroom(*pskb) &&
-	    !enlarge_skb(pskb, rep_len - match_len))
+	    rep_len - match_len > skb_tailroom(skb) &&
+	    !enlarge_skb(skb, rep_len - match_len))
 		return 0;
 
-	iph = ip_hdr(*pskb);
+	iph = ip_hdr(skb);
 	udph = (void *)iph + iph->ihl*4;
 
-	oldlen = (*pskb)->len - iph->ihl*4;
-	mangle_contents(*pskb, iph->ihl*4 + sizeof(*udph),
+	oldlen = skb->len - iph->ihl*4;
+	mangle_contents(skb, iph->ihl*4 + sizeof(*udph),
 			match_offset, match_len, rep_buffer, rep_len);
 
 	/* update the length of the UDP packet */
-	datalen = (*pskb)->len - iph->ihl*4;
+	datalen = skb->len - iph->ihl*4;
 	udph->len = htons(datalen);
 
 	/* fix udp checksum if udp checksum was previously calculated */
-	if (!udph->check && (*pskb)->ip_summed != CHECKSUM_PARTIAL)
+	if (!udph->check && skb->ip_summed != CHECKSUM_PARTIAL)
 		return 1;
 
-	if ((*pskb)->ip_summed != CHECKSUM_PARTIAL) {
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (*pskb)->dev->features & NETIF_F_V4_CSUM) {
-			(*pskb)->ip_summed = CHECKSUM_PARTIAL;
-			(*pskb)->csum_start = skb_headroom(*pskb) +
-					      skb_network_offset(*pskb) +
-					      iph->ihl * 4;
-			(*pskb)->csum_offset = offsetof(struct udphdr, check);
+		    skb->dev->features & NETIF_F_V4_CSUM) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_headroom(skb) +
+					  skb_network_offset(skb) +
+					  iph->ihl * 4;
+			skb->csum_offset = offsetof(struct udphdr, check);
 			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
 							 datalen, IPPROTO_UDP,
 							 0);
@@ -270,7 +270,7 @@ nf_nat_mangle_udp_packet(struct sk_buff **pskb,
 				udph->check = CSUM_MANGLED_0;
 		}
 	} else
-		nf_proto_csum_replace2(&udph->check, *pskb,
+		nf_proto_csum_replace2(&udph->check, skb,
 				       htons(oldlen), htons(datalen), 1);
 
 	return 1;
@@ -322,7 +322,7 @@ sack_adjust(struct sk_buff *skb,
 
 /* TCP SACK sequence number adjustment */
 static inline unsigned int
-nf_nat_sack_adjust(struct sk_buff **pskb,
+nf_nat_sack_adjust(struct sk_buff *skb,
 		   struct tcphdr *tcph,
 		   struct nf_conn *ct,
 		   enum ip_conntrack_info ctinfo)
@@ -330,17 +330,17 @@ nf_nat_sack_adjust(struct sk_buff **pskb,
 	unsigned int dir, optoff, optend;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 
-	optoff = ip_hdrlen(*pskb) + sizeof(struct tcphdr);
-	optend = ip_hdrlen(*pskb) + tcph->doff * 4;
+	optoff = ip_hdrlen(skb) + sizeof(struct tcphdr);
+	optend = ip_hdrlen(skb) + tcph->doff * 4;
 
-	if (!skb_make_writable(*pskb, optend))
+	if (!skb_make_writable(skb, optend))
 		return 0;
 
 	dir = CTINFO2DIR(ctinfo);
 
 	while (optoff < optend) {
 		/* Usually: option, length. */
-		unsigned char *op = (*pskb)->data + optoff;
+		unsigned char *op = skb->data + optoff;
 
 		switch (op[0]) {
 		case TCPOPT_EOL:
@@ -357,7 +357,7 @@ nf_nat_sack_adjust(struct sk_buff **pskb,
 			if (op[0] == TCPOPT_SACK &&
 			    op[1] >= 2+TCPOLEN_SACK_PERBLOCK &&
 			    ((op[1] - 2) % TCPOLEN_SACK_PERBLOCK) == 0)
-				sack_adjust(*pskb, tcph, optoff+2,
+				sack_adjust(skb, tcph, optoff+2,
 					    optoff+op[1], &nat->seq[!dir]);
 			optoff += op[1];
 		}
@@ -367,7 +367,7 @@ nf_nat_sack_adjust(struct sk_buff **pskb,
 
 /* TCP sequence number adjustment.  Returns 1 on success, 0 on failure */
 int
-nf_nat_seq_adjust(struct sk_buff **pskb,
+nf_nat_seq_adjust(struct sk_buff *skb,
 		  struct nf_conn *ct,
 		  enum ip_conntrack_info ctinfo)
 {
@@ -382,10 +382,10 @@ nf_nat_seq_adjust(struct sk_buff **pskb,
 	this_way = &nat->seq[dir];
 	other_way = &nat->seq[!dir];
 
-	if (!skb_make_writable(*pskb, ip_hdrlen(*pskb) + sizeof(*tcph)))
+	if (!skb_make_writable(skb, ip_hdrlen(skb) + sizeof(*tcph)))
 		return 0;
 
-	tcph = (void *)(*pskb)->data + ip_hdrlen(*pskb);
+	tcph = (void *)skb->data + ip_hdrlen(skb);
 	if (after(ntohl(tcph->seq), this_way->correction_pos))
 		newseq = htonl(ntohl(tcph->seq) + this_way->offset_after);
 	else
@@ -397,8 +397,8 @@ nf_nat_seq_adjust(struct sk_buff **pskb,
 	else
 		newack = htonl(ntohl(tcph->ack_seq) - other_way->offset_before);
 
-	nf_proto_csum_replace4(&tcph->check, *pskb, tcph->seq, newseq, 0);
-	nf_proto_csum_replace4(&tcph->check, *pskb, tcph->ack_seq, newack, 0);
+	nf_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, 0);
+	nf_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack, 0);
 
 	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
 		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
@@ -407,10 +407,10 @@ nf_nat_seq_adjust(struct sk_buff **pskb,
 	tcph->seq = newseq;
 	tcph->ack_seq = newack;
 
-	if (!nf_nat_sack_adjust(pskb, tcph, ct, ctinfo))
+	if (!nf_nat_sack_adjust(skb, tcph, ct, ctinfo))
 		return 0;
 
-	nf_conntrack_tcp_update(*pskb, ip_hdrlen(*pskb), ct, dir);
+	nf_conntrack_tcp_update(skb, ip_hdrlen(skb), ct, dir);
 
 	return 1;
 }
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
index bcf274b..766e2c1 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/ipv4/netfilter/nf_nat_irc.c
@@ -27,7 +27,7 @@ MODULE_DESCRIPTION("IRC (DCC) NAT helper");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_nat_irc");
 
-static unsigned int help(struct sk_buff **pskb,
+static unsigned int help(struct sk_buff *skb,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned int matchoff,
 			 unsigned int matchlen,
@@ -58,7 +58,7 @@ static unsigned int help(struct sk_buff **pskb,
 	pr_debug("nf_nat_irc: inserting '%s' == %u.%u.%u.%u, port %u\n",
 		 buffer, NIPQUAD(ip), port);
 
-	ret = nf_nat_mangle_tcp_packet(pskb, exp->master, ctinfo,
+	ret = nf_nat_mangle_tcp_packet(skb, exp->master, ctinfo,
 				       matchoff, matchlen, buffer,
 				       strlen(buffer));
 	if (ret != NF_ACCEPT)
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 984ec83..e1385a0 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -110,7 +110,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 /* outbound packets == from PNS to PAC */
 static int
-pptp_outbound_pkt(struct sk_buff **pskb,
+pptp_outbound_pkt(struct sk_buff *skb,
 		  struct nf_conn *ct,
 		  enum ip_conntrack_info ctinfo,
 		  struct PptpControlHeader *ctlh,
@@ -175,7 +175,7 @@ pptp_outbound_pkt(struct sk_buff **pskb,
 		 ntohs(REQ_CID(pptpReq, cid_off)), ntohs(new_callid));
 
 	/* mangle packet */
-	if (nf_nat_mangle_tcp_packet(pskb, ct, ctinfo,
+	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 				     cid_off + sizeof(struct pptp_pkt_hdr) +
 				     sizeof(struct PptpControlHeader),
 				     sizeof(new_callid), (char *)&new_callid,
@@ -213,7 +213,7 @@ pptp_exp_gre(struct nf_conntrack_expect *expect_orig,
 
 /* inbound packets == from PAC to PNS */
 static int
-pptp_inbound_pkt(struct sk_buff **pskb,
+pptp_inbound_pkt(struct sk_buff *skb,
 		 struct nf_conn *ct,
 		 enum ip_conntrack_info ctinfo,
 		 struct PptpControlHeader *ctlh,
@@ -268,7 +268,7 @@ pptp_inbound_pkt(struct sk_buff **pskb,
 	pr_debug("altering peer call id from 0x%04x to 0x%04x\n",
 		 ntohs(REQ_CID(pptpReq, pcid_off)), ntohs(new_pcid));
 
-	if (nf_nat_mangle_tcp_packet(pskb, ct, ctinfo,
+	if (nf_nat_mangle_tcp_packet(skb, ct, ctinfo,
 				     pcid_off + sizeof(struct pptp_pkt_hdr) +
 				     sizeof(struct PptpControlHeader),
 				     sizeof(new_pcid), (char *)&new_pcid,
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index e7a2aaf..b820f99 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -98,21 +98,21 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 /* manipulate a GRE packet according to maniptype */
 static int
-gre_manip_pkt(struct sk_buff **pskb, unsigned int iphdroff,
+gre_manip_pkt(struct sk_buff *skb, unsigned int iphdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
 	struct gre_hdr *greh;
 	struct gre_hdr_pptp *pgreh;
-	struct iphdr *iph = (struct iphdr *)((*pskb)->data + iphdroff);
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	unsigned int hdroff = iphdroff + iph->ihl * 4;
 
 	/* pgreh includes two optional 32bit fields which are not required
 	 * to be there.  That's where the magic '8' comes from */
-	if (!skb_make_writable(*pskb, hdroff + sizeof(*pgreh) - 8))
+	if (!skb_make_writable(skb, hdroff + sizeof(*pgreh) - 8))
 		return 0;
 
-	greh = (void *)(*pskb)->data + hdroff;
+	greh = (void *)skb->data + hdroff;
 	pgreh = (struct gre_hdr_pptp *)greh;
 
 	/* we only have destination manip of a packet, since 'source key'
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index 4087f4f..b9fc724 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -52,20 +52,20 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 static int
-icmp_manip_pkt(struct sk_buff **pskb,
+icmp_manip_pkt(struct sk_buff *skb,
 	       unsigned int iphdroff,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	struct iphdr *iph = (struct iphdr *)((*pskb)->data + iphdroff);
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct icmphdr *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 
-	if (!skb_make_writable(*pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return 0;
 
-	hdr = (struct icmphdr *)((*pskb)->data + hdroff);
-	nf_proto_csum_replace2(&hdr->checksum, *pskb,
+	hdr = (struct icmphdr *)(skb->data + hdroff);
+	nf_proto_csum_replace2(&hdr->checksum, skb,
 			       hdr->un.echo.id, tuple->src.u.icmp.id, 0);
 	hdr->un.echo.id = tuple->src.u.icmp.id;
 	return 1;
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/ipv4/netfilter/nf_nat_proto_tcp.c
index e544125..6bab2e1 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_tcp.c
@@ -88,12 +88,12 @@ tcp_unique_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 static int
-tcp_manip_pkt(struct sk_buff **pskb,
+tcp_manip_pkt(struct sk_buff *skb,
 	      unsigned int iphdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	struct iphdr *iph = (struct iphdr *)((*pskb)->data + iphdroff);
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct tcphdr *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 	__be32 oldip, newip;
@@ -103,14 +103,14 @@ tcp_manip_pkt(struct sk_buff **pskb,
 	/* this could be a inner header returned in icmp packet; in such
 	   cases we cannot update the checksum field since it is outside of
 	   the 8 bytes of transport layer headers we are guaranteed */
-	if ((*pskb)->len >= hdroff + sizeof(struct tcphdr))
+	if (skb->len >= hdroff + sizeof(struct tcphdr))
 		hdrsize = sizeof(struct tcphdr);
 
-	if (!skb_make_writable(*pskb, hdroff + hdrsize))
+	if (!skb_make_writable(skb, hdroff + hdrsize))
 		return 0;
 
-	iph = (struct iphdr *)((*pskb)->data + iphdroff);
-	hdr = (struct tcphdr *)((*pskb)->data + hdroff);
+	iph = (struct iphdr *)(skb->data + iphdroff);
+	hdr = (struct tcphdr *)(skb->data + hdroff);
 
 	if (maniptype == IP_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
@@ -132,8 +132,8 @@ tcp_manip_pkt(struct sk_buff **pskb,
 	if (hdrsize < sizeof(*hdr))
 		return 1;
 
-	nf_proto_csum_replace4(&hdr->check, *pskb, oldip, newip, 1);
-	nf_proto_csum_replace2(&hdr->check, *pskb, oldport, newport, 0);
+	nf_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+	nf_proto_csum_replace2(&hdr->check, skb, oldport, newport, 0);
 	return 1;
 }
 
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/ipv4/netfilter/nf_nat_proto_udp.c
index ebe9b42..cbf1a61 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_udp.c
@@ -86,22 +86,22 @@ udp_unique_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 static int
-udp_manip_pkt(struct sk_buff **pskb,
+udp_manip_pkt(struct sk_buff *skb,
 	      unsigned int iphdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	struct iphdr *iph = (struct iphdr *)((*pskb)->data + iphdroff);
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct udphdr *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 	__be32 oldip, newip;
 	__be16 *portptr, newport;
 
-	if (!skb_make_writable(*pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return 0;
 
-	iph = (struct iphdr *)((*pskb)->data + iphdroff);
-	hdr = (struct udphdr *)((*pskb)->data + hdroff);
+	iph = (struct iphdr *)(skb->data + iphdroff);
+	hdr = (struct udphdr *)(skb->data + hdroff);
 
 	if (maniptype == IP_NAT_MANIP_SRC) {
 		/* Get rid of src ip and src pt */
@@ -116,9 +116,9 @@ udp_manip_pkt(struct sk_buff **pskb,
 		newport = tuple->dst.u.udp.port;
 		portptr = &hdr->dest;
 	}
-	if (hdr->check || (*pskb)->ip_summed == CHECKSUM_PARTIAL) {
-		nf_proto_csum_replace4(&hdr->check, *pskb, oldip, newip, 1);
-		nf_proto_csum_replace2(&hdr->check, *pskb, *portptr, newport,
+	if (hdr->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+		nf_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+		nf_proto_csum_replace2(&hdr->check, skb, *portptr, newport,
 				       0);
 		if (!hdr->check)
 			hdr->check = CSUM_MANGLED_0;
diff --git a/net/ipv4/netfilter/nf_nat_proto_unknown.c b/net/ipv4/netfilter/nf_nat_proto_unknown.c
index f50d020..cfd2742 100644
--- a/net/ipv4/netfilter/nf_nat_proto_unknown.c
+++ b/net/ipv4/netfilter/nf_nat_proto_unknown.c
@@ -37,7 +37,7 @@ static int unknown_unique_tuple(struct nf_conntrack_tuple *tuple,
 }
 
 static int
-unknown_manip_pkt(struct sk_buff **pskb,
+unknown_manip_pkt(struct sk_buff *skb,
 		  unsigned int iphdroff,
 		  const struct nf_conntrack_tuple *tuple,
 		  enum nf_nat_manip_type maniptype)
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 76ec59a..46b25ab 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -65,7 +65,7 @@ static struct xt_table nat_table = {
 };
 
 /* Source NAT */
-static unsigned int ipt_snat_target(struct sk_buff **pskb,
+static unsigned int ipt_snat_target(struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    unsigned int hooknum,
@@ -78,7 +78,7 @@ static unsigned int ipt_snat_target(struct sk_buff **pskb,
 
 	NF_CT_ASSERT(hooknum == NF_IP_POST_ROUTING);
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
@@ -107,7 +107,7 @@ static void warn_if_extra_mangle(__be32 dstip, __be32 srcip)
 	ip_rt_put(rt);
 }
 
-static unsigned int ipt_dnat_target(struct sk_buff **pskb,
+static unsigned int ipt_dnat_target(struct sk_buff *skb,
 				    const struct net_device *in,
 				    const struct net_device *out,
 				    unsigned int hooknum,
@@ -121,14 +121,14 @@ static unsigned int ipt_dnat_target(struct sk_buff **pskb,
 	NF_CT_ASSERT(hooknum == NF_IP_PRE_ROUTING ||
 		     hooknum == NF_IP_LOCAL_OUT);
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
 
 	if (hooknum == NF_IP_LOCAL_OUT &&
 	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(ip_hdr(*pskb)->daddr,
+		warn_if_extra_mangle(ip_hdr(skb)->daddr,
 				     mr->range[0].min_ip);
 
 	return nf_nat_setup_info(ct, &mr->range[0], hooknum);
@@ -204,7 +204,7 @@ alloc_null_binding_confirmed(struct nf_conn *ct, unsigned int hooknum)
 	return nf_nat_setup_info(ct, &range, hooknum);
 }
 
-int nf_nat_rule_find(struct sk_buff **pskb,
+int nf_nat_rule_find(struct sk_buff *skb,
 		     unsigned int hooknum,
 		     const struct net_device *in,
 		     const struct net_device *out,
@@ -212,7 +212,7 @@ int nf_nat_rule_find(struct sk_buff **pskb,
 {
 	int ret;
 
-	ret = ipt_do_table(pskb, hooknum, in, out, &nat_table);
+	ret = ipt_do_table(skb, hooknum, in, out, &nat_table);
 
 	if (ret == NF_ACCEPT) {
 		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index e14d419..ce9edbc 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -60,7 +60,7 @@ static void addr_map_init(struct nf_conn *ct, struct addr_map *map)
 	}
 }
 
-static int map_sip_addr(struct sk_buff **pskb, enum ip_conntrack_info ctinfo,
+static int map_sip_addr(struct sk_buff *skb, enum ip_conntrack_info ctinfo,
 			struct nf_conn *ct, const char **dptr, size_t dlen,
 			enum sip_header_pos pos, struct addr_map *map)
 {
@@ -84,15 +84,15 @@ static int map_sip_addr(struct sk_buff **pskb, enum ip_conntrack_info ctinfo,
 	} else
 		return 1;
 
-	if (!nf_nat_mangle_udp_packet(pskb, ct, ctinfo,
+	if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 				      matchoff, matchlen, addr, addrlen))
 		return 0;
-	*dptr = (*pskb)->data + ip_hdrlen(*pskb) + sizeof(struct udphdr);
+	*dptr = skb->data + ip_hdrlen(skb) + sizeof(struct udphdr);
 	return 1;
 
 }
 
-static unsigned int ip_nat_sip(struct sk_buff **pskb,
+static unsigned int ip_nat_sip(struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
 			       struct nf_conn *ct,
 			       const char **dptr)
@@ -101,8 +101,8 @@ static unsigned int ip_nat_sip(struct sk_buff **pskb,
 	struct addr_map map;
 	int dataoff, datalen;
 
-	dataoff = ip_hdrlen(*pskb) + sizeof(struct udphdr);
-	datalen = (*pskb)->len - dataoff;
+	dataoff = ip_hdrlen(skb) + sizeof(struct udphdr);
+	datalen = skb->len - dataoff;
 	if (datalen < sizeof("SIP/2.0") - 1)
 		return NF_ACCEPT;
 
@@ -121,19 +121,19 @@ static unsigned int ip_nat_sip(struct sk_buff **pskb,
 		else
 			pos = POS_REQ_URI;
 
-		if (!map_sip_addr(pskb, ctinfo, ct, dptr, datalen, pos, &map))
+		if (!map_sip_addr(skb, ctinfo, ct, dptr, datalen, pos, &map))
 			return NF_DROP;
 	}
 
-	if (!map_sip_addr(pskb, ctinfo, ct, dptr, datalen, POS_FROM, &map) ||
-	    !map_sip_addr(pskb, ctinfo, ct, dptr, datalen, POS_TO, &map) ||
-	    !map_sip_addr(pskb, ctinfo, ct, dptr, datalen, POS_VIA, &map) ||
-	    !map_sip_addr(pskb, ctinfo, ct, dptr, datalen, POS_CONTACT, &map))
+	if (!map_sip_addr(skb, ctinfo, ct, dptr, datalen, POS_FROM, &map) ||
+	    !map_sip_addr(skb, ctinfo, ct, dptr, datalen, POS_TO, &map) ||
+	    !map_sip_addr(skb, ctinfo, ct, dptr, datalen, POS_VIA, &map) ||
+	    !map_sip_addr(skb, ctinfo, ct, dptr, datalen, POS_CONTACT, &map))
 		return NF_DROP;
 	return NF_ACCEPT;
 }
 
-static unsigned int mangle_sip_packet(struct sk_buff **pskb,
+static unsigned int mangle_sip_packet(struct sk_buff *skb,
 				      enum ip_conntrack_info ctinfo,
 				      struct nf_conn *ct,
 				      const char **dptr, size_t dlen,
@@ -145,16 +145,16 @@ static unsigned int mangle_sip_packet(struct sk_buff **pskb,
 	if (ct_sip_get_info(ct, *dptr, dlen, &matchoff, &matchlen, pos) <= 0)
 		return 0;
 
-	if (!nf_nat_mangle_udp_packet(pskb, ct, ctinfo,
+	if (!nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 				      matchoff, matchlen, buffer, bufflen))
 		return 0;
 
 	/* We need to reload this. Thanks Patrick. */
-	*dptr = (*pskb)->data + ip_hdrlen(*pskb) + sizeof(struct udphdr);
+	*dptr = skb->data + ip_hdrlen(skb) + sizeof(struct udphdr);
 	return 1;
 }
 
-static int mangle_content_len(struct sk_buff **pskb,
+static int mangle_content_len(struct sk_buff *skb,
 			      enum ip_conntrack_info ctinfo,
 			      struct nf_conn *ct,
 			      const char *dptr)
@@ -163,22 +163,22 @@ static int mangle_content_len(struct sk_buff **pskb,
 	char buffer[sizeof("65536")];
 	int bufflen;
 
-	dataoff = ip_hdrlen(*pskb) + sizeof(struct udphdr);
+	dataoff = ip_hdrlen(skb) + sizeof(struct udphdr);
 
 	/* Get actual SDP lenght */
-	if (ct_sip_get_info(ct, dptr, (*pskb)->len - dataoff, &matchoff,
+	if (ct_sip_get_info(ct, dptr, skb->len - dataoff, &matchoff,
 			    &matchlen, POS_SDP_HEADER) > 0) {
 
 		/* since ct_sip_get_info() give us a pointer passing 'v='
 		   we need to add 2 bytes in this count. */
-		int c_len = (*pskb)->len - dataoff - matchoff + 2;
+		int c_len = skb->len - dataoff - matchoff + 2;
 
 		/* Now, update SDP length */
-		if (ct_sip_get_info(ct, dptr, (*pskb)->len - dataoff, &matchoff,
+		if (ct_sip_get_info(ct, dptr, skb->len - dataoff, &matchoff,
 				    &matchlen, POS_CONTENT) > 0) {
 
 			bufflen = sprintf(buffer, "%u", c_len);
-			return nf_nat_mangle_udp_packet(pskb, ct, ctinfo,
+			return nf_nat_mangle_udp_packet(skb, ct, ctinfo,
 							matchoff, matchlen,
 							buffer, bufflen);
 		}
@@ -186,7 +186,7 @@ static int mangle_content_len(struct sk_buff **pskb,
 	return 0;
 }
 
-static unsigned int mangle_sdp(struct sk_buff **pskb,
+static unsigned int mangle_sdp(struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
 			       struct nf_conn *ct,
 			       __be32 newip, u_int16_t port,
@@ -195,25 +195,25 @@ static unsigned int mangle_sdp(struct sk_buff **pskb,
 	char buffer[sizeof("nnn.nnn.nnn.nnn")];
 	unsigned int dataoff, bufflen;
 
-	dataoff = ip_hdrlen(*pskb) + sizeof(struct udphdr);
+	dataoff = ip_hdrlen(skb) + sizeof(struct udphdr);
 
 	/* Mangle owner and contact info. */
 	bufflen = sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(newip));
-	if (!mangle_sip_packet(pskb, ctinfo, ct, &dptr, (*pskb)->len - dataoff,
+	if (!mangle_sip_packet(skb, ctinfo, ct, &dptr, skb->len - dataoff,
 			       buffer, bufflen, POS_OWNER_IP4))
 		return 0;
 
-	if (!mangle_sip_packet(pskb, ctinfo, ct, &dptr, (*pskb)->len - dataoff,
+	if (!mangle_sip_packet(skb, ctinfo, ct, &dptr, skb->len - dataoff,
 			       buffer, bufflen, POS_CONNECTION_IP4))
 		return 0;
 
 	/* Mangle media port. */
 	bufflen = sprintf(buffer, "%u", port);
-	if (!mangle_sip_packet(pskb, ctinfo, ct, &dptr, (*pskb)->len - dataoff,
+	if (!mangle_sip_packet(skb, ctinfo, ct, &dptr, skb->len - dataoff,
 			       buffer, bufflen, POS_MEDIA))
 		return 0;
 
-	return mangle_content_len(pskb, ctinfo, ct, dptr);
+	return mangle_content_len(skb, ctinfo, ct, dptr);
 }
 
 static void ip_nat_sdp_expect(struct nf_conn *ct,
@@ -241,7 +241,7 @@ static void ip_nat_sdp_expect(struct nf_conn *ct,
 
 /* So, this packet has hit the connection tracking matching code.
    Mangle it, and change the expectation to match the new version. */
-static unsigned int ip_nat_sdp(struct sk_buff **pskb,
+static unsigned int ip_nat_sdp(struct sk_buff *skb,
 			       enum ip_conntrack_info ctinfo,
 			       struct nf_conntrack_expect *exp,
 			       const char *dptr)
@@ -277,7 +277,7 @@ static unsigned int ip_nat_sdp(struct sk_buff **pskb,
 	if (port == 0)
 		return NF_DROP;
 
-	if (!mangle_sdp(pskb, ctinfo, ct, newip, port, dptr)) {
+	if (!mangle_sdp(skb, ctinfo, ct, newip, port, dptr)) {
 		nf_ct_unexpect_related(exp);
 		return NF_DROP;
 	}
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 87011fe..03709d6 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1188,9 +1188,9 @@ static int snmp_parse_mangle(unsigned char *msg,
  */
 static int snmp_translate(struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
-			  struct sk_buff **pskb)
+			  struct sk_buff *skb)
 {
-	struct iphdr *iph = ip_hdr(*pskb);
+	struct iphdr *iph = ip_hdr(skb);
 	struct udphdr *udph = (struct udphdr *)((__be32 *)iph + iph->ihl);
 	u_int16_t udplen = ntohs(udph->len);
 	u_int16_t paylen = udplen - sizeof(struct udphdr);
@@ -1225,13 +1225,13 @@ static int snmp_translate(struct nf_conn *ct,
 
 /* We don't actually set up expectations, just adjust internal IP
  * addresses if this is being NATted */
-static int help(struct sk_buff **pskb, unsigned int protoff,
+static int help(struct sk_buff *skb, unsigned int protoff,
 		struct nf_conn *ct,
 		enum ip_conntrack_info ctinfo)
 {
 	int dir = CTINFO2DIR(ctinfo);
 	unsigned int ret;
-	struct iphdr *iph = ip_hdr(*pskb);
+	struct iphdr *iph = ip_hdr(skb);
 	struct udphdr *udph = (struct udphdr *)((u_int32_t *)iph + iph->ihl);
 
 	/* SNMP replies and originating SNMP traps get mangled */
@@ -1250,7 +1250,7 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 	 * enough room for a UDP header.  Just verify the UDP length field so we
 	 * can mess around with the payload.
 	 */
-	if (ntohs(udph->len) != (*pskb)->len - (iph->ihl << 2)) {
+	if (ntohs(udph->len) != skb->len - (iph->ihl << 2)) {
 		 if (net_ratelimit())
 			 printk(KERN_WARNING "SNMP: dropping malformed packet "
 				"src=%u.%u.%u.%u dst=%u.%u.%u.%u\n",
@@ -1258,11 +1258,11 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 		 return NF_DROP;
 	}
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
 	spin_lock_bh(&snmp_lock);
-	ret = snmp_translate(ct, ctinfo, pskb);
+	ret = snmp_translate(ct, ctinfo, skb);
 	spin_unlock_bh(&snmp_lock);
 	return ret;
 }
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/nf_nat_standalone.c
index 46cc99d..7db76ea 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -67,7 +67,7 @@ static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
 
 static unsigned int
 nf_nat_fn(unsigned int hooknum,
-	  struct sk_buff **pskb,
+	  struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  int (*okfn)(struct sk_buff *))
@@ -80,9 +80,9 @@ nf_nat_fn(unsigned int hooknum,
 
 	/* We never see fragments: conntrack defrags on pre-routing
 	   and local-out, and nf_nat_out protects post-routing. */
-	NF_CT_ASSERT(!(ip_hdr(*pskb)->frag_off & htons(IP_MF | IP_OFFSET)));
+	NF_CT_ASSERT(!(ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)));
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	/* Can't track?  It's not due to stress, or conntrack would
 	   have dropped it.  Hence it's the user's responsibilty to
 	   packet filter it out, or implement conntrack/NAT for that
@@ -91,10 +91,10 @@ nf_nat_fn(unsigned int hooknum,
 		/* Exception: ICMP redirect to new connection (not in
 		   hash table yet).  We must not let this through, in
 		   case we're doing NAT to the same network. */
-		if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP) {
+		if (ip_hdr(skb)->protocol == IPPROTO_ICMP) {
 			struct icmphdr _hdr, *hp;
 
-			hp = skb_header_pointer(*pskb, ip_hdrlen(*pskb),
+			hp = skb_header_pointer(skb, ip_hdrlen(skb),
 						sizeof(_hdr), &_hdr);
 			if (hp != NULL &&
 			    hp->type == ICMP_REDIRECT)
@@ -119,9 +119,9 @@ nf_nat_fn(unsigned int hooknum,
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED+IP_CT_IS_REPLY:
-		if (ip_hdr(*pskb)->protocol == IPPROTO_ICMP) {
+		if (ip_hdr(skb)->protocol == IPPROTO_ICMP) {
 			if (!nf_nat_icmp_reply_translation(ct, ctinfo,
-							   hooknum, pskb))
+							   hooknum, skb))
 				return NF_DROP;
 			else
 				return NF_ACCEPT;
@@ -141,7 +141,7 @@ nf_nat_fn(unsigned int hooknum,
 				/* LOCAL_IN hook doesn't have a chain!  */
 				ret = alloc_null_binding(ct, hooknum);
 			else
-				ret = nf_nat_rule_find(pskb, hooknum, in, out,
+				ret = nf_nat_rule_find(skb, hooknum, in, out,
 						       ct);
 
 			if (ret != NF_ACCEPT) {
@@ -159,31 +159,31 @@ nf_nat_fn(unsigned int hooknum,
 			     ctinfo == (IP_CT_ESTABLISHED+IP_CT_IS_REPLY));
 	}
 
-	return nf_nat_packet(ct, ctinfo, hooknum, pskb);
+	return nf_nat_packet(ct, ctinfo, hooknum, skb);
 }
 
 static unsigned int
 nf_nat_in(unsigned int hooknum,
-	  struct sk_buff **pskb,
+	  struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  int (*okfn)(struct sk_buff *))
 {
 	unsigned int ret;
-	__be32 daddr = ip_hdr(*pskb)->daddr;
+	__be32 daddr = ip_hdr(skb)->daddr;
 
-	ret = nf_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
-	    daddr != ip_hdr(*pskb)->daddr) {
-		dst_release((*pskb)->dst);
-		(*pskb)->dst = NULL;
+	    daddr != ip_hdr(skb)->daddr) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
 	}
 	return ret;
 }
 
 static unsigned int
 nf_nat_out(unsigned int hooknum,
-	   struct sk_buff **pskb,
+	   struct sk_buff *skb,
 	   const struct net_device *in,
 	   const struct net_device *out,
 	   int (*okfn)(struct sk_buff *))
@@ -195,14 +195,14 @@ nf_nat_out(unsigned int hooknum,
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(*pskb) < sizeof(struct iphdr))
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
-	    (ct = nf_ct_get(*pskb, &ctinfo)) != NULL) {
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.src.u3.ip !=
@@ -210,7 +210,7 @@ nf_nat_out(unsigned int hooknum,
 		    || ct->tuplehash[dir].tuple.src.u.all !=
 		       ct->tuplehash[!dir].tuple.dst.u.all
 		    )
-			return ip_xfrm_me_harder(pskb) == 0 ? ret : NF_DROP;
+			return ip_xfrm_me_harder(skb) == 0 ? ret : NF_DROP;
 	}
 #endif
 	return ret;
@@ -218,7 +218,7 @@ nf_nat_out(unsigned int hooknum,
 
 static unsigned int
 nf_nat_local_fn(unsigned int hooknum,
-		struct sk_buff **pskb,
+		struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
 		int (*okfn)(struct sk_buff *))
@@ -228,24 +228,24 @@ nf_nat_local_fn(unsigned int hooknum,
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(*pskb) < sizeof(struct iphdr))
+	if (skb->len < sizeof(struct iphdr) ||
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
-	    (ct = nf_ct_get(*pskb, &ctinfo)) != NULL) {
+	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.dst.u3.ip !=
 		    ct->tuplehash[!dir].tuple.src.u3.ip) {
-			if (ip_route_me_harder(pskb, RTN_UNSPEC))
+			if (ip_route_me_harder(skb, RTN_UNSPEC))
 				ret = NF_DROP;
 		}
 #ifdef CONFIG_XFRM
 		else if (ct->tuplehash[dir].tuple.dst.u.all !=
 			 ct->tuplehash[!dir].tuple.src.u.all)
-			if (ip_xfrm_me_harder(pskb))
+			if (ip_xfrm_me_harder(skb))
 				ret = NF_DROP;
 #endif
 	}
@@ -254,7 +254,7 @@ nf_nat_local_fn(unsigned int hooknum,
 
 static unsigned int
 nf_nat_adjust(unsigned int hooknum,
-	      struct sk_buff **pskb,
+	      struct sk_buff *skb,
 	      const struct net_device *in,
 	      const struct net_device *out,
 	      int (*okfn)(struct sk_buff *))
@@ -262,10 +262,10 @@ nf_nat_adjust(unsigned int hooknum,
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	if (ct && test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)) {
 		pr_debug("nf_nat_standalone: adjusting sequence number\n");
-		if (!nf_nat_seq_adjust(pskb, ct, ctinfo))
+		if (!nf_nat_seq_adjust(skb, ct, ctinfo))
 			return NF_DROP;
 	}
 	return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/ipv4/netfilter/nf_nat_tftp.c
index 04dfeae..0ecec70 100644
--- a/net/ipv4/netfilter/nf_nat_tftp.c
+++ b/net/ipv4/netfilter/nf_nat_tftp.c
@@ -20,7 +20,7 @@ MODULE_DESCRIPTION("TFTP NAT helper");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_nat_tftp");
 
-static unsigned int help(struct sk_buff **pskb,
+static unsigned int help(struct sk_buff *skb,
 			 enum ip_conntrack_info ctinfo,
 			 struct nf_conntrack_expect *exp)
 {
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
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 38b1496..b1326c2 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -68,15 +68,15 @@ static void nf_ip6_saveroute(const struct sk_buff *skb, struct nf_info *info)
 	}
 }
 
-static int nf_ip6_reroute(struct sk_buff **pskb, const struct nf_info *info)
+static int nf_ip6_reroute(struct sk_buff *skb, const struct nf_info *info)
 {
 	struct ip6_rt_info *rt_info = nf_info_reroute(info);
 
 	if (info->hook == NF_IP6_LOCAL_OUT) {
-		struct ipv6hdr *iph = ipv6_hdr(*pskb);
+		struct ipv6hdr *iph = ipv6_hdr(skb);
 		if (!ipv6_addr_equal(&iph->daddr, &rt_info->daddr) ||
 		    !ipv6_addr_equal(&iph->saddr, &rt_info->saddr))
-			return ip6_route_me_harder(*pskb);
+			return ip6_route_me_harder(skb);
 	}
 	return 0;
 }
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index cd9df02..acaba15 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -205,7 +205,7 @@ ip6_checkentry(const struct ip6t_ip6 *ipv6)
 }
 
 static unsigned int
-ip6t_error(struct sk_buff **pskb,
+ip6t_error(struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  unsigned int hooknum,
@@ -350,7 +350,7 @@ static void trace_packet(struct sk_buff *skb,
 
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
-ip6t_do_table(struct sk_buff **pskb,
+ip6t_do_table(struct sk_buff *skb,
 	      unsigned int hook,
 	      const struct net_device *in,
 	      const struct net_device *out,
@@ -389,17 +389,17 @@ ip6t_do_table(struct sk_buff **pskb,
 	do {
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
-		if (ip6_packet_match(*pskb, indev, outdev, &e->ipv6,
+		if (ip6_packet_match(skb, indev, outdev, &e->ipv6,
 			&protoff, &offset, &hotdrop)) {
 			struct ip6t_entry_target *t;
 
 			if (IP6T_MATCH_ITERATE(e, do_match,
-					       *pskb, in, out,
+					       skb, in, out,
 					       offset, protoff, &hotdrop) != 0)
 				goto no_match;
 
 			ADD_COUNTER(e->counters,
-				    ntohs(ipv6_hdr(*pskb)->payload_len)
+				    ntohs(ipv6_hdr(skb)->payload_len)
 				    + IPV6_HDR_LEN,
 				    1);
 
@@ -409,8 +409,8 @@ ip6t_do_table(struct sk_buff **pskb,
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
@@ -448,7 +448,7 @@ ip6t_do_table(struct sk_buff **pskb,
 				((struct ip6t_entry *)table_base)->comefrom
 					= 0xeeeeeeec;
 #endif
-				verdict = t->u.kernel.target->target(pskb,
+				verdict = t->u.kernel.target->target(skb,
 								     in, out,
 								     hook,
 								     t->u.kernel.target,
diff --git a/net/ipv6/netfilter/ip6t_HL.c b/net/ipv6/netfilter/ip6t_HL.c
index f76197f..9afc836 100644
--- a/net/ipv6/netfilter/ip6t_HL.c
+++ b/net/ipv6/netfilter/ip6t_HL.c
@@ -18,7 +18,7 @@ MODULE_AUTHOR("Maciej Soltysiak <solt@dns.toxicfilms.tv>");
 MODULE_DESCRIPTION("IP6 tables Hop Limit modification module");
 MODULE_LICENSE("GPL");
 
-static unsigned int ip6t_hl_target(struct sk_buff **pskb,
+static unsigned int ip6t_hl_target(struct sk_buff *skb,
 				   const struct net_device *in,
 				   const struct net_device *out,
 				   unsigned int hooknum,
@@ -29,10 +29,10 @@ static unsigned int ip6t_hl_target(struct sk_buff **pskb,
 	const struct ip6t_HL_info *info = targinfo;
 	int new_hl;
 
-	if (!skb_make_writable(*pskb, (*pskb)->len))
+	if (!skb_make_writable(skb, skb->len))
 		return NF_DROP;
 
-	ip6h = ipv6_hdr(*pskb);
+	ip6h = ipv6_hdr(skb);
 
 	switch (info->mode) {
 		case IP6T_HL_SET:
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 6ab9900..7a48c34 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -431,7 +431,7 @@ ip6t_log_packet(unsigned int pf,
 }
 
 static unsigned int
-ip6t_log_target(struct sk_buff **pskb,
+ip6t_log_target(struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
 		unsigned int hooknum,
@@ -445,8 +445,7 @@ ip6t_log_target(struct sk_buff **pskb,
 	li.u.log.level = loginfo->level;
 	li.u.log.logflags = loginfo->logflags;
 
-	ip6t_log_packet(PF_INET6, hooknum, *pskb, in, out, &li,
-			loginfo->prefix);
+	ip6t_log_packet(PF_INET6, hooknum, skb, in, out, &li, loginfo->prefix);
 	return XT_CONTINUE;
 }
 
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 3fd08d5..1a7d291 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -172,7 +172,7 @@ send_unreach(struct sk_buff *skb_in, unsigned char code, unsigned int hooknum)
 	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0, NULL);
 }
 
-static unsigned int reject6_target(struct sk_buff **pskb,
+static unsigned int reject6_target(struct sk_buff *skb,
 			   const struct net_device *in,
 			   const struct net_device *out,
 			   unsigned int hooknum,
@@ -187,25 +187,25 @@ static unsigned int reject6_target(struct sk_buff **pskb,
 	   must return an absolute verdict. --RR */
 	switch (reject->with) {
 	case IP6T_ICMP6_NO_ROUTE:
-		send_unreach(*pskb, ICMPV6_NOROUTE, hooknum);
+		send_unreach(skb, ICMPV6_NOROUTE, hooknum);
 		break;
 	case IP6T_ICMP6_ADM_PROHIBITED:
-		send_unreach(*pskb, ICMPV6_ADM_PROHIBITED, hooknum);
+		send_unreach(skb, ICMPV6_ADM_PROHIBITED, hooknum);
 		break;
 	case IP6T_ICMP6_NOT_NEIGHBOUR:
-		send_unreach(*pskb, ICMPV6_NOT_NEIGHBOUR, hooknum);
+		send_unreach(skb, ICMPV6_NOT_NEIGHBOUR, hooknum);
 		break;
 	case IP6T_ICMP6_ADDR_UNREACH:
-		send_unreach(*pskb, ICMPV6_ADDR_UNREACH, hooknum);
+		send_unreach(skb, ICMPV6_ADDR_UNREACH, hooknum);
 		break;
 	case IP6T_ICMP6_PORT_UNREACH:
-		send_unreach(*pskb, ICMPV6_PORT_UNREACH, hooknum);
+		send_unreach(skb, ICMPV6_PORT_UNREACH, hooknum);
 		break;
 	case IP6T_ICMP6_ECHOREPLY:
 		/* Do nothing */
 		break;
 	case IP6T_TCP_RESET:
-		send_reset(*pskb);
+		send_reset(skb);
 		break;
 	default:
 		if (net_ratelimit())
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 7e32e2a..1d26b20 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -60,32 +60,32 @@ static struct xt_table packet_filter = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6t_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(pskb, hook, in, out, &packet_filter);
+	return ip6t_do_table(skb, hook, in, out, &packet_filter);
 }
 
 static unsigned int
 ip6t_local_out_hook(unsigned int hook,
-		   struct sk_buff **pskb,
+		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
 #if 0
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr)
-	    || ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr)
+	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
 #endif
 
-	return ip6t_do_table(pskb, hook, in, out, &packet_filter);
+	return ip6t_do_table(skb, hook, in, out, &packet_filter);
 }
 
 static struct nf_hook_ops ip6t_ops[] = {
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index f0a9efa..a0b6381 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -68,17 +68,17 @@ static struct xt_table packet_mangler = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6t_route_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(pskb, hook, in, out, &packet_mangler);
+	return ip6t_do_table(skb, hook, in, out, &packet_mangler);
 }
 
 static unsigned int
 ip6t_local_hook(unsigned int hook,
-		   struct sk_buff **pskb,
+		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
@@ -91,8 +91,8 @@ ip6t_local_hook(unsigned int hook,
 
 #if 0
 	/* root is playing with raw sockets. */
-	if ((*pskb)->len < sizeof(struct iphdr)
-	    || ip_hdrlen(*pskb) < sizeof(struct iphdr)) {
+	if (skb->len < sizeof(struct iphdr)
+	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
 		if (net_ratelimit())
 			printk("ip6t_hook: happy cracking.\n");
 		return NF_ACCEPT;
@@ -100,22 +100,22 @@ ip6t_local_hook(unsigned int hook,
 #endif
 
 	/* save source/dest address, mark, hoplimit, flowlabel, priority,  */
-	memcpy(&saddr, &ipv6_hdr(*pskb)->saddr, sizeof(saddr));
-	memcpy(&daddr, &ipv6_hdr(*pskb)->daddr, sizeof(daddr));
-	mark = (*pskb)->mark;
-	hop_limit = ipv6_hdr(*pskb)->hop_limit;
+	memcpy(&saddr, &ipv6_hdr(skb)->saddr, sizeof(saddr));
+	memcpy(&daddr, &ipv6_hdr(skb)->daddr, sizeof(daddr));
+	mark = skb->mark;
+	hop_limit = ipv6_hdr(skb)->hop_limit;
 
 	/* flowlabel and prio (includes version, which shouldn't change either */
-	flowlabel = *((u_int32_t *)ipv6_hdr(*pskb));
+	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(pskb, hook, in, out, &packet_mangler);
+	ret = ip6t_do_table(skb, hook, in, out, &packet_mangler);
 
 	if (ret != NF_DROP && ret != NF_STOLEN
-		&& (memcmp(&ipv6_hdr(*pskb)->saddr, &saddr, sizeof(saddr))
-		    || memcmp(&ipv6_hdr(*pskb)->daddr, &daddr, sizeof(daddr))
-		    || (*pskb)->mark != mark
-		    || ipv6_hdr(*pskb)->hop_limit != hop_limit))
-		return ip6_route_me_harder(*pskb) == 0 ? ret : NF_DROP;
+		&& (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr))
+		    || memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr))
+		    || skb->mark != mark
+		    || ipv6_hdr(skb)->hop_limit != hop_limit))
+		return ip6_route_me_harder(skb) == 0 ? ret : NF_DROP;
 
 	return ret;
 }
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index ec290e4..8f7109f 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -46,12 +46,12 @@ static struct xt_table packet_raw = {
 /* The work comes in here from netfilter.c. */
 static unsigned int
 ip6t_hook(unsigned int hook,
-	 struct sk_buff **pskb,
+	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(pskb, hook, in, out, &packet_raw);
+	return ip6t_do_table(skb, hook, in, out, &packet_raw);
 }
 
 static struct nf_hook_ops ip6t_ops[] = {
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
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 2c9e8e3..bed9ba0 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -117,7 +117,7 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 EXPORT_SYMBOL(nf_unregister_hooks);
 
 unsigned int nf_iterate(struct list_head *head,
-			struct sk_buff **skb,
+			struct sk_buff *skb,
 			int hook,
 			const struct net_device *indev,
 			const struct net_device *outdev,
@@ -160,7 +160,7 @@ unsigned int nf_iterate(struct list_head *head,
 
 /* Returns 1 if okfn() needs to be executed by the caller,
  * -EPERM for NF_DROP, 0 otherwise. */
-int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
+int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 		 struct net_device *indev,
 		 struct net_device *outdev,
 		 int (*okfn)(struct sk_buff *),
@@ -175,17 +175,17 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff **pskb,
 
 	elem = &nf_hooks[pf][hook];
 next_hook:
-	verdict = nf_iterate(&nf_hooks[pf][hook], pskb, hook, indev,
+	verdict = nf_iterate(&nf_hooks[pf][hook], skb, hook, indev,
 			     outdev, &elem, okfn, hook_thresh);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
 		goto unlock;
 	} else if (verdict == NF_DROP) {
-		kfree_skb(*pskb);
+		kfree_skb(skb);
 		ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK)  == NF_QUEUE) {
 		NFDEBUG("nf_hook: Verdict = QUEUE.\n");
-		if (!nf_queue(*pskb, elem, pf, hook, indev, outdev, okfn,
+		if (!nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
 			      verdict >> NF_VERDICT_BITS))
 			goto next_hook;
 	}
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index e42ab23..7b8239c 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -36,7 +36,7 @@ MODULE_PARM_DESC(master_timeout, "timeout for the master connection");
 module_param(ts_algo, charp, 0400);
 MODULE_PARM_DESC(ts_algo, "textsearch algorithm to use (default kmp)");
 
-unsigned int (*nf_nat_amanda_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
 				   enum ip_conntrack_info ctinfo,
 				   unsigned int matchoff,
 				   unsigned int matchlen,
@@ -79,7 +79,7 @@ static struct {
 	},
 };
 
-static int amanda_help(struct sk_buff **pskb,
+static int amanda_help(struct sk_buff *skb,
 		       unsigned int protoff,
 		       struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo)
@@ -101,25 +101,25 @@ static int amanda_help(struct sk_buff **pskb,
 
 	/* increase the UDP timeout of the master connection as replies from
 	 * Amanda clients to the server can be quite delayed */
-	nf_ct_refresh(ct, *pskb, master_timeout * HZ);
+	nf_ct_refresh(ct, skb, master_timeout * HZ);
 
 	/* No data? */
 	dataoff = protoff + sizeof(struct udphdr);
-	if (dataoff >= (*pskb)->len) {
+	if (dataoff >= skb->len) {
 		if (net_ratelimit())
-			printk("amanda_help: skblen = %u\n", (*pskb)->len);
+			printk("amanda_help: skblen = %u\n", skb->len);
 		return NF_ACCEPT;
 	}
 
 	memset(&ts, 0, sizeof(ts));
-	start = skb_find_text(*pskb, dataoff, (*pskb)->len,
+	start = skb_find_text(skb, dataoff, skb->len,
 			      search[SEARCH_CONNECT].ts, &ts);
 	if (start == UINT_MAX)
 		goto out;
 	start += dataoff + search[SEARCH_CONNECT].len;
 
 	memset(&ts, 0, sizeof(ts));
-	stop = skb_find_text(*pskb, start, (*pskb)->len,
+	stop = skb_find_text(skb, start, skb->len,
 			     search[SEARCH_NEWLINE].ts, &ts);
 	if (stop == UINT_MAX)
 		goto out;
@@ -127,13 +127,13 @@ static int amanda_help(struct sk_buff **pskb,
 
 	for (i = SEARCH_DATA; i <= SEARCH_INDEX; i++) {
 		memset(&ts, 0, sizeof(ts));
-		off = skb_find_text(*pskb, start, stop, search[i].ts, &ts);
+		off = skb_find_text(skb, start, stop, search[i].ts, &ts);
 		if (off == UINT_MAX)
 			continue;
 		off += start + search[i].len;
 
 		len = min_t(unsigned int, sizeof(pbuf) - 1, stop - off);
-		if (skb_copy_bits(*pskb, off, pbuf, len))
+		if (skb_copy_bits(skb, off, pbuf, len))
 			break;
 		pbuf[len] = '\0';
 
@@ -153,7 +153,7 @@ static int amanda_help(struct sk_buff **pskb,
 
 		nf_nat_amanda = rcu_dereference(nf_nat_amanda_hook);
 		if (nf_nat_amanda && ct->status & IPS_NAT_MASK)
-			ret = nf_nat_amanda(pskb, ctinfo, off - dataoff,
+			ret = nf_nat_amanda(skb, ctinfo, off - dataoff,
 					    len, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 83c30b4..4d6171b 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -307,7 +307,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_hash_insert);
 
 /* Confirm a connection given skb; places it in hash table */
 int
-__nf_conntrack_confirm(struct sk_buff **pskb)
+__nf_conntrack_confirm(struct sk_buff *skb)
 {
 	unsigned int hash, repl_hash;
 	struct nf_conntrack_tuple_hash *h;
@@ -316,7 +316,7 @@ __nf_conntrack_confirm(struct sk_buff **pskb)
 	struct hlist_node *n;
 	enum ip_conntrack_info ctinfo;
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 
 	/* ipt_REJECT uses nf_conntrack_attach to attach related
 	   ICMP/TCP RST packets in other direction.  Actual packet
@@ -367,14 +367,14 @@ __nf_conntrack_confirm(struct sk_buff **pskb)
 	write_unlock_bh(&nf_conntrack_lock);
 	help = nfct_help(ct);
 	if (help && help->helper)
-		nf_conntrack_event_cache(IPCT_HELPER, *pskb);
+		nf_conntrack_event_cache(IPCT_HELPER, skb);
 #ifdef CONFIG_NF_NAT_NEEDED
 	if (test_bit(IPS_SRC_NAT_DONE_BIT, &ct->status) ||
 	    test_bit(IPS_DST_NAT_DONE_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_NATINFO, *pskb);
+		nf_conntrack_event_cache(IPCT_NATINFO, skb);
 #endif
 	nf_conntrack_event_cache(master_ct(ct) ?
-				 IPCT_RELATED : IPCT_NEW, *pskb);
+				 IPCT_RELATED : IPCT_NEW, skb);
 	return NF_ACCEPT;
 
 out:
@@ -632,7 +632,7 @@ resolve_normal_ct(struct sk_buff *skb,
 }
 
 unsigned int
-nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff **pskb)
+nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff *skb)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -644,14 +644,14 @@ nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff **pskb)
 	int ret;
 
 	/* Previously seen (loopback or untracked)?  Ignore. */
-	if ((*pskb)->nfct) {
+	if (skb->nfct) {
 		NF_CT_STAT_INC_ATOMIC(ignore);
 		return NF_ACCEPT;
 	}
 
 	/* rcu_read_lock()ed by nf_hook_slow */
 	l3proto = __nf_ct_l3proto_find((u_int16_t)pf);
-	ret = l3proto->get_l4proto(*pskb, skb_network_offset(*pskb),
+	ret = l3proto->get_l4proto(skb, skb_network_offset(skb),
 				   &dataoff, &protonum);
 	if (ret <= 0) {
 		pr_debug("not prepared to track yet or error occured\n");
@@ -666,13 +666,13 @@ nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff **pskb)
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL &&
-	    (ret = l4proto->error(*pskb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
+	    (ret = l4proto->error(skb, dataoff, &ctinfo, pf, hooknum)) <= 0) {
 		NF_CT_STAT_INC_ATOMIC(error);
 		NF_CT_STAT_INC_ATOMIC(invalid);
 		return -ret;
 	}
 
-	ct = resolve_normal_ct(*pskb, dataoff, pf, protonum, l3proto, l4proto,
+	ct = resolve_normal_ct(skb, dataoff, pf, protonum, l3proto, l4proto,
 			       &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
@@ -686,21 +686,21 @@ nf_conntrack_in(int pf, unsigned int hooknum, struct sk_buff **pskb)
 		return NF_DROP;
 	}
 
-	NF_CT_ASSERT((*pskb)->nfct);
+	NF_CT_ASSERT(skb->nfct);
 
-	ret = l4proto->packet(ct, *pskb, dataoff, ctinfo, pf, hooknum);
+	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum);
 	if (ret < 0) {
 		/* Invalid: inverse of the return code tells
 		 * the netfilter core what to do */
 		pr_debug("nf_conntrack_in: Can't track with proto module\n");
-		nf_conntrack_put((*pskb)->nfct);
-		(*pskb)->nfct = NULL;
+		nf_conntrack_put(skb->nfct);
+		skb->nfct = NULL;
 		NF_CT_STAT_INC_ATOMIC(invalid);
 		return -ret;
 	}
 
 	if (set_reply && !test_and_set_bit(IPS_SEEN_REPLY_BIT, &ct->status))
-		nf_conntrack_event_cache(IPCT_STATUS, *pskb);
+		nf_conntrack_event_cache(IPCT_STATUS, skb);
 
 	return ret;
 }
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index c763ee7..6df2590 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -43,7 +43,7 @@ module_param_array(ports, ushort, &ports_c, 0400);
 static int loose;
 module_param(loose, bool, 0600);
 
-unsigned int (*nf_nat_ftp_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				enum nf_ct_ftp_type type,
 				unsigned int matchoff,
@@ -344,7 +344,7 @@ static void update_nl_seq(u32 nl_seq, struct nf_ct_ftp_master *info, int dir,
 	}
 }
 
-static int help(struct sk_buff **pskb,
+static int help(struct sk_buff *skb,
 		unsigned int protoff,
 		struct nf_conn *ct,
 		enum ip_conntrack_info ctinfo)
@@ -371,21 +371,21 @@ static int help(struct sk_buff **pskb,
 		return NF_ACCEPT;
 	}
 
-	th = skb_header_pointer(*pskb, protoff, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return NF_ACCEPT;
 
 	dataoff = protoff + th->doff * 4;
 	/* No data? */
-	if (dataoff >= (*pskb)->len) {
+	if (dataoff >= skb->len) {
 		pr_debug("ftp: dataoff(%u) >= skblen(%u)\n", dataoff,
-			 (*pskb)->len);
+			 skb->len);
 		return NF_ACCEPT;
 	}
-	datalen = (*pskb)->len - dataoff;
+	datalen = skb->len - dataoff;
 
 	spin_lock_bh(&nf_ftp_lock);
-	fb_ptr = skb_header_pointer(*pskb, dataoff, datalen, ftp_buffer);
+	fb_ptr = skb_header_pointer(skb, dataoff, datalen, ftp_buffer);
 	BUG_ON(fb_ptr == NULL);
 
 	ends_in_nl = (fb_ptr[datalen - 1] == '\n');
@@ -491,7 +491,7 @@ static int help(struct sk_buff **pskb,
 	 * (possibly changed) expectation itself. */
 	nf_nat_ftp = rcu_dereference(nf_nat_ftp_hook);
 	if (nf_nat_ftp && ct->status & IPS_NAT_MASK)
-		ret = nf_nat_ftp(pskb, ctinfo, search[dir][i].ftptype,
+		ret = nf_nat_ftp(skb, ctinfo, search[dir][i].ftptype,
 				 matchoff, matchlen, exp);
 	else {
 		/* Can't expect this?  Best to drop packet now. */
@@ -508,7 +508,7 @@ out_update_nl:
 	/* Now if this ends in \n, update ftp info.  Seq may have been
 	 * adjusted by NAT code. */
 	if (ends_in_nl)
-		update_nl_seq(seq, ct_ftp_info, dir, *pskb);
+		update_nl_seq(seq, ct_ftp_info, dir, skb);
  out:
 	spin_unlock_bh(&nf_ftp_lock);
 	return ret;
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index a8a9dfb..f23fd95 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -47,27 +47,27 @@ MODULE_PARM_DESC(callforward_filter, "only create call forwarding expectations "
 				     "(determined by routing information)");
 
 /* Hooks for NAT */
-int (*set_h245_addr_hook) (struct sk_buff **pskb,
+int (*set_h245_addr_hook) (struct sk_buff *skb,
 			   unsigned char **data, int dataoff,
 			   H245_TransportAddress *taddr,
 			   union nf_conntrack_address *addr, __be16 port)
 			   __read_mostly;
-int (*set_h225_addr_hook) (struct sk_buff **pskb,
+int (*set_h225_addr_hook) (struct sk_buff *skb,
 			   unsigned char **data, int dataoff,
 			   TransportAddress *taddr,
 			   union nf_conntrack_address *addr, __be16 port)
 			   __read_mostly;
-int (*set_sig_addr_hook) (struct sk_buff **pskb,
+int (*set_sig_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
 			  unsigned char **data,
 			  TransportAddress *taddr, int count) __read_mostly;
-int (*set_ras_addr_hook) (struct sk_buff **pskb,
+int (*set_ras_addr_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
 			  unsigned char **data,
 			  TransportAddress *taddr, int count) __read_mostly;
-int (*nat_rtp_rtcp_hook) (struct sk_buff **pskb,
+int (*nat_rtp_rtcp_hook) (struct sk_buff *skb,
 			  struct nf_conn *ct,
 			  enum ip_conntrack_info ctinfo,
 			  unsigned char **data, int dataoff,
@@ -75,25 +75,25 @@ int (*nat_rtp_rtcp_hook) (struct sk_buff **pskb,
 			  __be16 port, __be16 rtp_port,
 			  struct nf_conntrack_expect *rtp_exp,
 			  struct nf_conntrack_expect *rtcp_exp) __read_mostly;
-int (*nat_t120_hook) (struct sk_buff **pskb,
+int (*nat_t120_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
 		      unsigned char **data, int dataoff,
 		      H245_TransportAddress *taddr, __be16 port,
 		      struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_h245_hook) (struct sk_buff **pskb,
+int (*nat_h245_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
 		      unsigned char **data, int dataoff,
 		      TransportAddress *taddr, __be16 port,
 		      struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_callforwarding_hook) (struct sk_buff **pskb,
+int (*nat_callforwarding_hook) (struct sk_buff *skb,
 				struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo,
 				unsigned char **data, int dataoff,
 				TransportAddress *taddr, __be16 port,
 				struct nf_conntrack_expect *exp) __read_mostly;
-int (*nat_q931_hook) (struct sk_buff **pskb,
+int (*nat_q931_hook) (struct sk_buff *skb,
 		      struct nf_conn *ct,
 		      enum ip_conntrack_info ctinfo,
 		      unsigned char **data, TransportAddress *taddr, int idx,
@@ -108,7 +108,7 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[];
 static struct nf_conntrack_helper nf_conntrack_helper_ras[];
 
 /****************************************************************************/
-static int get_tpkt_data(struct sk_buff **pskb, unsigned int protoff,
+static int get_tpkt_data(struct sk_buff *skb, unsigned int protoff,
 			 struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			 unsigned char **data, int *datalen, int *dataoff)
 {
@@ -122,7 +122,7 @@ static int get_tpkt_data(struct sk_buff **pskb, unsigned int protoff,
 	int tpktoff;
 
 	/* Get TCP header */
-	th = skb_header_pointer(*pskb, protoff, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return 0;
 
@@ -130,13 +130,13 @@ static int get_tpkt_data(struct sk_buff **pskb, unsigned int protoff,
 	tcpdataoff = protoff + th->doff * 4;
 
 	/* Get TCP data length */
-	tcpdatalen = (*pskb)->len - tcpdataoff;
+	tcpdatalen = skb->len - tcpdataoff;
 	if (tcpdatalen <= 0)	/* No TCP data */
 		goto clear_out;
 
 	if (*data == NULL) {	/* first TPKT */
 		/* Get first TPKT pointer */
-		tpkt = skb_header_pointer(*pskb, tcpdataoff, tcpdatalen,
+		tpkt = skb_header_pointer(skb, tcpdataoff, tcpdatalen,
 					  h323_buffer);
 		BUG_ON(tpkt == NULL);
 
@@ -248,7 +248,7 @@ static int get_h245_addr(struct nf_conn *ct, unsigned char *data,
 }
 
 /****************************************************************************/
-static int expect_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
+static int expect_rtp_rtcp(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned char **data, int dataoff,
 			   H245_TransportAddress *taddr)
@@ -297,7 +297,7 @@ static int expect_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
 		   (nat_rtp_rtcp = rcu_dereference(nat_rtp_rtcp_hook)) &&
 		   ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_rtp_rtcp(pskb, ct, ctinfo, data, dataoff,
+		ret = nat_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
 				   taddr, port, rtp_port, rtp_exp, rtcp_exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(rtp_exp) == 0) {
@@ -321,7 +321,7 @@ static int expect_rtp_rtcp(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int expect_t120(struct sk_buff **pskb,
+static int expect_t120(struct sk_buff *skb,
 		       struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, int dataoff,
@@ -355,7 +355,7 @@ static int expect_t120(struct sk_buff **pskb,
 	    (nat_t120 = rcu_dereference(nat_t120_hook)) &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_t120(pskb, ct, ctinfo, data, dataoff, taddr,
+		ret = nat_t120(skb, ct, ctinfo, data, dataoff, taddr,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -371,7 +371,7 @@ static int expect_t120(struct sk_buff **pskb,
 }
 
 /****************************************************************************/
-static int process_h245_channel(struct sk_buff **pskb,
+static int process_h245_channel(struct sk_buff *skb,
 				struct nf_conn *ct,
 				enum ip_conntrack_info ctinfo,
 				unsigned char **data, int dataoff,
@@ -381,7 +381,7 @@ static int process_h245_channel(struct sk_buff **pskb,
 
 	if (channel->options & eH2250LogicalChannelParameters_mediaChannel) {
 		/* RTP */
-		ret = expect_rtp_rtcp(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
 				      &channel->mediaChannel);
 		if (ret < 0)
 			return -1;
@@ -390,7 +390,7 @@ static int process_h245_channel(struct sk_buff **pskb,
 	if (channel->
 	    options & eH2250LogicalChannelParameters_mediaControlChannel) {
 		/* RTCP */
-		ret = expect_rtp_rtcp(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
 				      &channel->mediaControlChannel);
 		if (ret < 0)
 			return -1;
@@ -400,7 +400,7 @@ static int process_h245_channel(struct sk_buff **pskb,
 }
 
 /****************************************************************************/
-static int process_olc(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_olc(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, int dataoff,
 		       OpenLogicalChannel *olc)
@@ -412,7 +412,7 @@ static int process_olc(struct sk_buff **pskb, struct nf_conn *ct,
 	if (olc->forwardLogicalChannelParameters.multiplexParameters.choice ==
 	    eOpenLogicalChannel_forwardLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters)
 	{
-		ret = process_h245_channel(pskb, ct, ctinfo, data, dataoff,
+		ret = process_h245_channel(skb, ct, ctinfo, data, dataoff,
 					   &olc->
 					   forwardLogicalChannelParameters.
 					   multiplexParameters.
@@ -430,7 +430,7 @@ static int process_olc(struct sk_buff **pskb, struct nf_conn *ct,
 		eOpenLogicalChannel_reverseLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters))
 	{
 		ret =
-		    process_h245_channel(pskb, ct, ctinfo, data, dataoff,
+		    process_h245_channel(skb, ct, ctinfo, data, dataoff,
 					 &olc->
 					 reverseLogicalChannelParameters.
 					 multiplexParameters.
@@ -448,7 +448,7 @@ static int process_olc(struct sk_buff **pskb, struct nf_conn *ct,
 	    t120.choice == eDataProtocolCapability_separateLANStack &&
 	    olc->separateStack.networkAddress.choice ==
 	    eNetworkAccessParameters_networkAddress_localAreaAddress) {
-		ret = expect_t120(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_t120(skb, ct, ctinfo, data, dataoff,
 				  &olc->separateStack.networkAddress.
 				  localAreaAddress);
 		if (ret < 0)
@@ -459,7 +459,7 @@ static int process_olc(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_olca(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data, int dataoff,
 			OpenLogicalChannelAck *olca)
@@ -477,7 +477,7 @@ static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
 		choice ==
 		eOpenLogicalChannelAck_reverseLogicalChannelParameters_multiplexParameters_h2250LogicalChannelParameters))
 	{
-		ret = process_h245_channel(pskb, ct, ctinfo, data, dataoff,
+		ret = process_h245_channel(skb, ct, ctinfo, data, dataoff,
 					   &olca->
 					   reverseLogicalChannelParameters.
 					   multiplexParameters.
@@ -496,7 +496,7 @@ static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
 		if (ack->options &
 		    eH2250LogicalChannelAckParameters_mediaChannel) {
 			/* RTP */
-			ret = expect_rtp_rtcp(pskb, ct, ctinfo, data, dataoff,
+			ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
 					      &ack->mediaChannel);
 			if (ret < 0)
 				return -1;
@@ -505,7 +505,7 @@ static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
 		if (ack->options &
 		    eH2250LogicalChannelAckParameters_mediaControlChannel) {
 			/* RTCP */
-			ret = expect_rtp_rtcp(pskb, ct, ctinfo, data, dataoff,
+			ret = expect_rtp_rtcp(skb, ct, ctinfo, data, dataoff,
 					      &ack->mediaControlChannel);
 			if (ret < 0)
 				return -1;
@@ -515,7 +515,7 @@ static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
 	if ((olca->options & eOpenLogicalChannelAck_separateStack) &&
 		olca->separateStack.networkAddress.choice ==
 		eNetworkAccessParameters_networkAddress_localAreaAddress) {
-		ret = expect_t120(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_t120(skb, ct, ctinfo, data, dataoff,
 				  &olca->separateStack.networkAddress.
 				  localAreaAddress);
 		if (ret < 0)
@@ -526,7 +526,7 @@ static int process_olca(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_h245(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_h245(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data, int dataoff,
 			MultimediaSystemControlMessage *mscm)
@@ -535,7 +535,7 @@ static int process_h245(struct sk_buff **pskb, struct nf_conn *ct,
 	case eMultimediaSystemControlMessage_request:
 		if (mscm->request.choice ==
 		    eRequestMessage_openLogicalChannel) {
-			return process_olc(pskb, ct, ctinfo, data, dataoff,
+			return process_olc(skb, ct, ctinfo, data, dataoff,
 					   &mscm->request.openLogicalChannel);
 		}
 		pr_debug("nf_ct_h323: H.245 Request %d\n",
@@ -544,7 +544,7 @@ static int process_h245(struct sk_buff **pskb, struct nf_conn *ct,
 	case eMultimediaSystemControlMessage_response:
 		if (mscm->response.choice ==
 		    eResponseMessage_openLogicalChannelAck) {
-			return process_olca(pskb, ct, ctinfo, data, dataoff,
+			return process_olca(skb, ct, ctinfo, data, dataoff,
 					    &mscm->response.
 					    openLogicalChannelAck);
 		}
@@ -560,7 +560,7 @@ static int process_h245(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int h245_help(struct sk_buff **pskb, unsigned int protoff,
+static int h245_help(struct sk_buff *skb, unsigned int protoff,
 		     struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	static MultimediaSystemControlMessage mscm;
@@ -574,12 +574,12 @@ static int h245_help(struct sk_buff **pskb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_h245: skblen = %u\n", (*pskb)->len);
+	pr_debug("nf_ct_h245: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
-	while (get_tpkt_data(pskb, protoff, ct, ctinfo,
+	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
 		pr_debug("nf_ct_h245: TPKT len=%d ", datalen);
 		NF_CT_DUMP_TUPLE(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
@@ -596,7 +596,7 @@ static int h245_help(struct sk_buff **pskb, unsigned int protoff,
 		}
 
 		/* Process H.245 signal */
-		if (process_h245(pskb, ct, ctinfo, &data, dataoff, &mscm) < 0)
+		if (process_h245(skb, ct, ctinfo, &data, dataoff, &mscm) < 0)
 			goto drop;
 	}
 
@@ -654,7 +654,7 @@ int get_h225_addr(struct nf_conn *ct, unsigned char *data,
 }
 
 /****************************************************************************/
-static int expect_h245(struct sk_buff **pskb, struct nf_conn *ct,
+static int expect_h245(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, int dataoff,
 		       TransportAddress *taddr)
@@ -687,7 +687,7 @@ static int expect_h245(struct sk_buff **pskb, struct nf_conn *ct,
 	    (nat_h245 = rcu_dereference(nat_h245_hook)) &&
 	    ct->status & IPS_NAT_MASK) {
 		/* NAT needed */
-		ret = nat_h245(pskb, ct, ctinfo, data, dataoff, taddr,
+		ret = nat_h245(skb, ct, ctinfo, data, dataoff, taddr,
 			       port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -758,7 +758,7 @@ static int callforward_do_filter(union nf_conntrack_address *src,
 }
 
 /****************************************************************************/
-static int expect_callforwarding(struct sk_buff **pskb,
+static int expect_callforwarding(struct sk_buff *skb,
 				 struct nf_conn *ct,
 				 enum ip_conntrack_info ctinfo,
 				 unsigned char **data, int dataoff,
@@ -798,7 +798,7 @@ static int expect_callforwarding(struct sk_buff **pskb,
 	    (nat_callforwarding = rcu_dereference(nat_callforwarding_hook)) &&
 	    ct->status & IPS_NAT_MASK) {
 		/* Need NAT */
-		ret = nat_callforwarding(pskb, ct, ctinfo, data, dataoff,
+		ret = nat_callforwarding(skb, ct, ctinfo, data, dataoff,
 					 taddr, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
@@ -814,7 +814,7 @@ static int expect_callforwarding(struct sk_buff **pskb,
 }
 
 /****************************************************************************/
-static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_setup(struct sk_buff *skb, struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo,
 			 unsigned char **data, int dataoff,
 			 Setup_UUIE *setup)
@@ -829,7 +829,7 @@ static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Setup\n");
 
 	if (setup->options & eSetup_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &setup->h245Address);
 		if (ret < 0)
 			return -1;
@@ -846,7 +846,7 @@ static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
 			 NIP6(*(struct in6_addr *)&addr), ntohs(port),
 			 NIP6(*(struct in6_addr *)&ct->tuplehash[!dir].tuple.src.u3),
 			 ntohs(ct->tuplehash[!dir].tuple.src.u.tcp.port));
-		ret = set_h225_addr(pskb, data, dataoff,
+		ret = set_h225_addr(skb, data, dataoff,
 				    &setup->destCallSignalAddress,
 				    &ct->tuplehash[!dir].tuple.src.u3,
 				    ct->tuplehash[!dir].tuple.src.u.tcp.port);
@@ -864,7 +864,7 @@ static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
 			 NIP6(*(struct in6_addr *)&addr), ntohs(port),
 			 NIP6(*(struct in6_addr *)&ct->tuplehash[!dir].tuple.dst.u3),
 			 ntohs(ct->tuplehash[!dir].tuple.dst.u.tcp.port));
-		ret = set_h225_addr(pskb, data, dataoff,
+		ret = set_h225_addr(skb, data, dataoff,
 				    &setup->sourceCallSignalAddress,
 				    &ct->tuplehash[!dir].tuple.dst.u3,
 				    ct->tuplehash[!dir].tuple.dst.u.tcp.port);
@@ -874,7 +874,7 @@ static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (setup->options & eSetup_UUIE_fastStart) {
 		for (i = 0; i < setup->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &setup->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -885,7 +885,7 @@ static int process_setup(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_callproceeding(struct sk_buff **pskb,
+static int process_callproceeding(struct sk_buff *skb,
 				  struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
 				  unsigned char **data, int dataoff,
@@ -897,7 +897,7 @@ static int process_callproceeding(struct sk_buff **pskb,
 	pr_debug("nf_ct_q931: CallProceeding\n");
 
 	if (callproc->options & eCallProceeding_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &callproc->h245Address);
 		if (ret < 0)
 			return -1;
@@ -905,7 +905,7 @@ static int process_callproceeding(struct sk_buff **pskb,
 
 	if (callproc->options & eCallProceeding_UUIE_fastStart) {
 		for (i = 0; i < callproc->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &callproc->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -916,7 +916,7 @@ static int process_callproceeding(struct sk_buff **pskb,
 }
 
 /****************************************************************************/
-static int process_connect(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_connect(struct sk_buff *skb, struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned char **data, int dataoff,
 			   Connect_UUIE *connect)
@@ -927,7 +927,7 @@ static int process_connect(struct sk_buff **pskb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Connect\n");
 
 	if (connect->options & eConnect_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &connect->h245Address);
 		if (ret < 0)
 			return -1;
@@ -935,7 +935,7 @@ static int process_connect(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (connect->options & eConnect_UUIE_fastStart) {
 		for (i = 0; i < connect->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &connect->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -946,7 +946,7 @@ static int process_connect(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_alerting(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_alerting(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned char **data, int dataoff,
 			    Alerting_UUIE *alert)
@@ -957,7 +957,7 @@ static int process_alerting(struct sk_buff **pskb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Alerting\n");
 
 	if (alert->options & eAlerting_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &alert->h245Address);
 		if (ret < 0)
 			return -1;
@@ -965,7 +965,7 @@ static int process_alerting(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (alert->options & eAlerting_UUIE_fastStart) {
 		for (i = 0; i < alert->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &alert->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -976,7 +976,7 @@ static int process_alerting(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_facility(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_facility(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned char **data, int dataoff,
 			    Facility_UUIE *facility)
@@ -988,7 +988,7 @@ static int process_facility(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (facility->reason.choice == eFacilityReason_callForwarded) {
 		if (facility->options & eFacility_UUIE_alternativeAddress)
-			return expect_callforwarding(pskb, ct, ctinfo, data,
+			return expect_callforwarding(skb, ct, ctinfo, data,
 						     dataoff,
 						     &facility->
 						     alternativeAddress);
@@ -996,7 +996,7 @@ static int process_facility(struct sk_buff **pskb, struct nf_conn *ct,
 	}
 
 	if (facility->options & eFacility_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &facility->h245Address);
 		if (ret < 0)
 			return -1;
@@ -1004,7 +1004,7 @@ static int process_facility(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (facility->options & eFacility_UUIE_fastStart) {
 		for (i = 0; i < facility->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &facility->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1015,7 +1015,7 @@ static int process_facility(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_progress(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_progress(struct sk_buff *skb, struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    unsigned char **data, int dataoff,
 			    Progress_UUIE *progress)
@@ -1026,7 +1026,7 @@ static int process_progress(struct sk_buff **pskb, struct nf_conn *ct,
 	pr_debug("nf_ct_q931: Progress\n");
 
 	if (progress->options & eProgress_UUIE_h245Address) {
-		ret = expect_h245(pskb, ct, ctinfo, data, dataoff,
+		ret = expect_h245(skb, ct, ctinfo, data, dataoff,
 				  &progress->h245Address);
 		if (ret < 0)
 			return -1;
@@ -1034,7 +1034,7 @@ static int process_progress(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (progress->options & eProgress_UUIE_fastStart) {
 		for (i = 0; i < progress->fastStart.count; i++) {
-			ret = process_olc(pskb, ct, ctinfo, data, dataoff,
+			ret = process_olc(skb, ct, ctinfo, data, dataoff,
 					  &progress->fastStart.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1045,7 +1045,7 @@ static int process_progress(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_q931(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_q931(struct sk_buff *skb, struct nf_conn *ct,
 			enum ip_conntrack_info ctinfo,
 			unsigned char **data, int dataoff, Q931 *q931)
 {
@@ -1055,28 +1055,28 @@ static int process_q931(struct sk_buff **pskb, struct nf_conn *ct,
 
 	switch (pdu->h323_message_body.choice) {
 	case eH323_UU_PDU_h323_message_body_setup:
-		ret = process_setup(pskb, ct, ctinfo, data, dataoff,
+		ret = process_setup(skb, ct, ctinfo, data, dataoff,
 				    &pdu->h323_message_body.setup);
 		break;
 	case eH323_UU_PDU_h323_message_body_callProceeding:
-		ret = process_callproceeding(pskb, ct, ctinfo, data, dataoff,
+		ret = process_callproceeding(skb, ct, ctinfo, data, dataoff,
 					     &pdu->h323_message_body.
 					     callProceeding);
 		break;
 	case eH323_UU_PDU_h323_message_body_connect:
-		ret = process_connect(pskb, ct, ctinfo, data, dataoff,
+		ret = process_connect(skb, ct, ctinfo, data, dataoff,
 				      &pdu->h323_message_body.connect);
 		break;
 	case eH323_UU_PDU_h323_message_body_alerting:
-		ret = process_alerting(pskb, ct, ctinfo, data, dataoff,
+		ret = process_alerting(skb, ct, ctinfo, data, dataoff,
 				       &pdu->h323_message_body.alerting);
 		break;
 	case eH323_UU_PDU_h323_message_body_facility:
-		ret = process_facility(pskb, ct, ctinfo, data, dataoff,
+		ret = process_facility(skb, ct, ctinfo, data, dataoff,
 				       &pdu->h323_message_body.facility);
 		break;
 	case eH323_UU_PDU_h323_message_body_progress:
-		ret = process_progress(pskb, ct, ctinfo, data, dataoff,
+		ret = process_progress(skb, ct, ctinfo, data, dataoff,
 				       &pdu->h323_message_body.progress);
 		break;
 	default:
@@ -1090,7 +1090,7 @@ static int process_q931(struct sk_buff **pskb, struct nf_conn *ct,
 
 	if (pdu->options & eH323_UU_PDU_h245Control) {
 		for (i = 0; i < pdu->h245Control.count; i++) {
-			ret = process_h245(pskb, ct, ctinfo, data, dataoff,
+			ret = process_h245(skb, ct, ctinfo, data, dataoff,
 					   &pdu->h245Control.item[i]);
 			if (ret < 0)
 				return -1;
@@ -1101,7 +1101,7 @@ static int process_q931(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int q931_help(struct sk_buff **pskb, unsigned int protoff,
+static int q931_help(struct sk_buff *skb, unsigned int protoff,
 		     struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	static Q931 q931;
@@ -1115,12 +1115,12 @@ static int q931_help(struct sk_buff **pskb, unsigned int protoff,
 	    ctinfo != IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
 		return NF_ACCEPT;
 	}
-	pr_debug("nf_ct_q931: skblen = %u\n", (*pskb)->len);
+	pr_debug("nf_ct_q931: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Process each TPKT */
-	while (get_tpkt_data(pskb, protoff, ct, ctinfo,
+	while (get_tpkt_data(skb, protoff, ct, ctinfo,
 			     &data, &datalen, &dataoff)) {
 		pr_debug("nf_ct_q931: TPKT len=%d ", datalen);
 		NF_CT_DUMP_TUPLE(&ct->tuplehash[CTINFO2DIR(ctinfo)].tuple);
@@ -1136,7 +1136,7 @@ static int q931_help(struct sk_buff **pskb, unsigned int protoff,
 		}
 
 		/* Process Q.931 signal */
-		if (process_q931(pskb, ct, ctinfo, &data, dataoff, &q931) < 0)
+		if (process_q931(skb, ct, ctinfo, &data, dataoff, &q931) < 0)
 			goto drop;
 	}
 
@@ -1177,20 +1177,20 @@ static struct nf_conntrack_helper nf_conntrack_helper_q931[] __read_mostly = {
 };
 
 /****************************************************************************/
-static unsigned char *get_udp_data(struct sk_buff **pskb, unsigned int protoff,
+static unsigned char *get_udp_data(struct sk_buff *skb, unsigned int protoff,
 				   int *datalen)
 {
 	struct udphdr _uh, *uh;
 	int dataoff;
 
-	uh = skb_header_pointer(*pskb, protoff, sizeof(_uh), &_uh);
+	uh = skb_header_pointer(skb, protoff, sizeof(_uh), &_uh);
 	if (uh == NULL)
 		return NULL;
 	dataoff = protoff + sizeof(_uh);
-	if (dataoff >= (*pskb)->len)
+	if (dataoff >= skb->len)
 		return NULL;
-	*datalen = (*pskb)->len - dataoff;
-	return skb_header_pointer(*pskb, dataoff, *datalen, h323_buffer);
+	*datalen = skb->len - dataoff;
+	return skb_header_pointer(skb, dataoff, *datalen, h323_buffer);
 }
 
 /****************************************************************************/
@@ -1227,7 +1227,7 @@ static int set_expect_timeout(struct nf_conntrack_expect *exp,
 }
 
 /****************************************************************************/
-static int expect_q931(struct sk_buff **pskb, struct nf_conn *ct,
+static int expect_q931(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data,
 		       TransportAddress *taddr, int count)
@@ -1265,7 +1265,7 @@ static int expect_q931(struct sk_buff **pskb, struct nf_conn *ct,
 
 	nat_q931 = rcu_dereference(nat_q931_hook);
 	if (nat_q931 && ct->status & IPS_NAT_MASK) {	/* Need NAT */
-		ret = nat_q931(pskb, ct, ctinfo, data, taddr, i, port, exp);
+		ret = nat_q931(skb, ct, ctinfo, data, taddr, i, port, exp);
 	} else {		/* Conntrack only */
 		if (nf_ct_expect_related(exp) == 0) {
 			pr_debug("nf_ct_ras: expect Q.931 ");
@@ -1283,7 +1283,7 @@ static int expect_q931(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_grq(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_grq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, GatekeeperRequest *grq)
 {
@@ -1293,13 +1293,13 @@ static int process_grq(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)	/* NATed */
-		return set_ras_addr(pskb, ct, ctinfo, data,
+		return set_ras_addr(skb, ct, ctinfo, data,
 				    &grq->rasAddress, 1);
 	return 0;
 }
 
 /****************************************************************************/
-static int process_gcf(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_gcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, GatekeeperConfirm *gcf)
 {
@@ -1343,7 +1343,7 @@ static int process_gcf(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_rrq(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_rrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, RegistrationRequest *rrq)
 {
@@ -1353,7 +1353,7 @@ static int process_rrq(struct sk_buff **pskb, struct nf_conn *ct,
 
 	pr_debug("nf_ct_ras: RRQ\n");
 
-	ret = expect_q931(pskb, ct, ctinfo, data,
+	ret = expect_q931(skb, ct, ctinfo, data,
 			  rrq->callSignalAddress.item,
 			  rrq->callSignalAddress.count);
 	if (ret < 0)
@@ -1361,7 +1361,7 @@ static int process_rrq(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
-		ret = set_ras_addr(pskb, ct, ctinfo, data,
+		ret = set_ras_addr(skb, ct, ctinfo, data,
 				   rrq->rasAddress.item,
 				   rrq->rasAddress.count);
 		if (ret < 0)
@@ -1378,7 +1378,7 @@ static int process_rrq(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_rcf(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, RegistrationConfirm *rcf)
 {
@@ -1392,7 +1392,7 @@ static int process_rcf(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(pskb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, data,
 					rcf->callSignalAddress.item,
 					rcf->callSignalAddress.count);
 		if (ret < 0)
@@ -1407,7 +1407,7 @@ static int process_rcf(struct sk_buff **pskb, struct nf_conn *ct,
 	if (info->timeout > 0) {
 		pr_debug("nf_ct_ras: set RAS connection timeout to "
 			 "%u seconds\n", info->timeout);
-		nf_ct_refresh(ct, *pskb, info->timeout * HZ);
+		nf_ct_refresh(ct, skb, info->timeout * HZ);
 
 		/* Set expect timeout */
 		read_lock_bh(&nf_conntrack_lock);
@@ -1427,7 +1427,7 @@ static int process_rcf(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_urq(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_urq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, UnregistrationRequest *urq)
 {
@@ -1440,7 +1440,7 @@ static int process_urq(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(pskb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, data,
 				   urq->callSignalAddress.item,
 				   urq->callSignalAddress.count);
 		if (ret < 0)
@@ -1453,13 +1453,13 @@ static int process_urq(struct sk_buff **pskb, struct nf_conn *ct,
 	info->sig_port[!dir] = 0;
 
 	/* Give it 30 seconds for UCF or URJ */
-	nf_ct_refresh(ct, *pskb, 30 * HZ);
+	nf_ct_refresh(ct, skb, 30 * HZ);
 
 	return 0;
 }
 
 /****************************************************************************/
-static int process_arq(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_arq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, AdmissionRequest *arq)
 {
@@ -1479,7 +1479,7 @@ static int process_arq(struct sk_buff **pskb, struct nf_conn *ct,
 	    port == info->sig_port[dir] &&
 	    set_h225_addr && ct->status & IPS_NAT_MASK) {
 		/* Answering ARQ */
-		return set_h225_addr(pskb, data, 0,
+		return set_h225_addr(skb, data, 0,
 				     &arq->destCallSignalAddress,
 				     &ct->tuplehash[!dir].tuple.dst.u3,
 				     info->sig_port[!dir]);
@@ -1491,7 +1491,7 @@ static int process_arq(struct sk_buff **pskb, struct nf_conn *ct,
 	    !memcmp(&addr, &ct->tuplehash[dir].tuple.src.u3, sizeof(addr)) &&
 	    set_h225_addr && ct->status & IPS_NAT_MASK) {
 		/* Calling ARQ */
-		return set_h225_addr(pskb, data, 0,
+		return set_h225_addr(skb, data, 0,
 				     &arq->srcCallSignalAddress,
 				     &ct->tuplehash[!dir].tuple.dst.u3,
 				     port);
@@ -1501,7 +1501,7 @@ static int process_arq(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_acf(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_acf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, AdmissionConfirm *acf)
 {
@@ -1522,7 +1522,7 @@ static int process_acf(struct sk_buff **pskb, struct nf_conn *ct,
 		/* Answering ACF */
 		set_sig_addr = rcu_dereference(set_sig_addr_hook);
 		if (set_sig_addr && ct->status & IPS_NAT_MASK)
-			return set_sig_addr(pskb, ct, ctinfo, data,
+			return set_sig_addr(skb, ct, ctinfo, data,
 					    &acf->destCallSignalAddress, 1);
 		return 0;
 	}
@@ -1548,7 +1548,7 @@ static int process_acf(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_lrq(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_lrq(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, LocationRequest *lrq)
 {
@@ -1558,13 +1558,13 @@ static int process_lrq(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK)
-		return set_ras_addr(pskb, ct, ctinfo, data,
+		return set_ras_addr(skb, ct, ctinfo, data,
 				    &lrq->replyAddress, 1);
 	return 0;
 }
 
 /****************************************************************************/
-static int process_lcf(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_lcf(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, LocationConfirm *lcf)
 {
@@ -1603,7 +1603,7 @@ static int process_lcf(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_irr(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_irr(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, InfoRequestResponse *irr)
 {
@@ -1615,7 +1615,7 @@ static int process_irr(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_ras_addr = rcu_dereference(set_ras_addr_hook);
 	if (set_ras_addr && ct->status & IPS_NAT_MASK) {
-		ret = set_ras_addr(pskb, ct, ctinfo, data,
+		ret = set_ras_addr(skb, ct, ctinfo, data,
 				   &irr->rasAddress, 1);
 		if (ret < 0)
 			return -1;
@@ -1623,7 +1623,7 @@ static int process_irr(struct sk_buff **pskb, struct nf_conn *ct,
 
 	set_sig_addr = rcu_dereference(set_sig_addr_hook);
 	if (set_sig_addr && ct->status & IPS_NAT_MASK) {
-		ret = set_sig_addr(pskb, ct, ctinfo, data,
+		ret = set_sig_addr(skb, ct, ctinfo, data,
 					irr->callSignalAddress.item,
 					irr->callSignalAddress.count);
 		if (ret < 0)
@@ -1634,40 +1634,40 @@ static int process_irr(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int process_ras(struct sk_buff **pskb, struct nf_conn *ct,
+static int process_ras(struct sk_buff *skb, struct nf_conn *ct,
 		       enum ip_conntrack_info ctinfo,
 		       unsigned char **data, RasMessage *ras)
 {
 	switch (ras->choice) {
 	case eRasMessage_gatekeeperRequest:
-		return process_grq(pskb, ct, ctinfo, data,
+		return process_grq(skb, ct, ctinfo, data,
 				   &ras->gatekeeperRequest);
 	case eRasMessage_gatekeeperConfirm:
-		return process_gcf(pskb, ct, ctinfo, data,
+		return process_gcf(skb, ct, ctinfo, data,
 				   &ras->gatekeeperConfirm);
 	case eRasMessage_registrationRequest:
-		return process_rrq(pskb, ct, ctinfo, data,
+		return process_rrq(skb, ct, ctinfo, data,
 				   &ras->registrationRequest);
 	case eRasMessage_registrationConfirm:
-		return process_rcf(pskb, ct, ctinfo, data,
+		return process_rcf(skb, ct, ctinfo, data,
 				   &ras->registrationConfirm);
 	case eRasMessage_unregistrationRequest:
-		return process_urq(pskb, ct, ctinfo, data,
+		return process_urq(skb, ct, ctinfo, data,
 				   &ras->unregistrationRequest);
 	case eRasMessage_admissionRequest:
-		return process_arq(pskb, ct, ctinfo, data,
+		return process_arq(skb, ct, ctinfo, data,
 				   &ras->admissionRequest);
 	case eRasMessage_admissionConfirm:
-		return process_acf(pskb, ct, ctinfo, data,
+		return process_acf(skb, ct, ctinfo, data,
 				   &ras->admissionConfirm);
 	case eRasMessage_locationRequest:
-		return process_lrq(pskb, ct, ctinfo, data,
+		return process_lrq(skb, ct, ctinfo, data,
 				   &ras->locationRequest);
 	case eRasMessage_locationConfirm:
-		return process_lcf(pskb, ct, ctinfo, data,
+		return process_lcf(skb, ct, ctinfo, data,
 				   &ras->locationConfirm);
 	case eRasMessage_infoRequestResponse:
-		return process_irr(pskb, ct, ctinfo, data,
+		return process_irr(skb, ct, ctinfo, data,
 				   &ras->infoRequestResponse);
 	default:
 		pr_debug("nf_ct_ras: RAS message %d\n", ras->choice);
@@ -1678,7 +1678,7 @@ static int process_ras(struct sk_buff **pskb, struct nf_conn *ct,
 }
 
 /****************************************************************************/
-static int ras_help(struct sk_buff **pskb, unsigned int protoff,
+static int ras_help(struct sk_buff *skb, unsigned int protoff,
 		    struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	static RasMessage ras;
@@ -1686,12 +1686,12 @@ static int ras_help(struct sk_buff **pskb, unsigned int protoff,
 	int datalen = 0;
 	int ret;
 
-	pr_debug("nf_ct_ras: skblen = %u\n", (*pskb)->len);
+	pr_debug("nf_ct_ras: skblen = %u\n", skb->len);
 
 	spin_lock_bh(&nf_h323_lock);
 
 	/* Get UDP data */
-	data = get_udp_data(pskb, protoff, &datalen);
+	data = get_udp_data(skb, protoff, &datalen);
 	if (data == NULL)
 		goto accept;
 	pr_debug("nf_ct_ras: RAS message len=%d ", datalen);
@@ -1707,7 +1707,7 @@ static int ras_help(struct sk_buff **pskb, unsigned int protoff,
 	}
 
 	/* Process RAS message */
-	if (process_ras(pskb, ct, ctinfo, &data, &ras) < 0)
+	if (process_ras(skb, ct, ctinfo, &data, &ras) < 0)
 		goto drop;
 
       accept:
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index 1562ca9..dfaed4b 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -30,7 +30,7 @@ static unsigned int dcc_timeout __read_mostly = 300;
 static char *irc_buffer;
 static DEFINE_SPINLOCK(irc_buffer_lock);
 
-unsigned int (*nf_nat_irc_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_irc_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				unsigned int matchoff,
 				unsigned int matchlen,
@@ -89,7 +89,7 @@ static int parse_dcc(char *data, char *data_end, u_int32_t *ip,
 	return 0;
 }
 
-static int help(struct sk_buff **pskb, unsigned int protoff,
+static int help(struct sk_buff *skb, unsigned int protoff,
 		struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	unsigned int dataoff;
@@ -116,22 +116,22 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 		return NF_ACCEPT;
 
 	/* Not a full tcp header? */
-	th = skb_header_pointer(*pskb, protoff, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return NF_ACCEPT;
 
 	/* No data? */
 	dataoff = protoff + th->doff*4;
-	if (dataoff >= (*pskb)->len)
+	if (dataoff >= skb->len)
 		return NF_ACCEPT;
 
 	spin_lock_bh(&irc_buffer_lock);
-	ib_ptr = skb_header_pointer(*pskb, dataoff, (*pskb)->len - dataoff,
+	ib_ptr = skb_header_pointer(skb, dataoff, skb->len - dataoff,
 				    irc_buffer);
 	BUG_ON(ib_ptr == NULL);
 
 	data = ib_ptr;
-	data_limit = ib_ptr + (*pskb)->len - dataoff;
+	data_limit = ib_ptr + skb->len - dataoff;
 
 	/* strlen("\1DCC SENT t AAAAAAAA P\1\n")=24
 	 * 5+MINMATCHLEN+strlen("t AAAAAAAA P\1\n")=14 */
@@ -143,7 +143,7 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 		data += 5;
 		/* we have at least (19+MINMATCHLEN)-5 bytes valid data left */
 
-		iph = ip_hdr(*pskb);
+		iph = ip_hdr(skb);
 		pr_debug("DCC found in master %u.%u.%u.%u:%u %u.%u.%u.%u:%u\n",
 			 NIPQUAD(iph->saddr), ntohs(th->source),
 			 NIPQUAD(iph->daddr), ntohs(th->dest));
@@ -193,7 +193,7 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 
 			nf_nat_irc = rcu_dereference(nf_nat_irc_hook);
 			if (nf_nat_irc && ct->status & IPS_NAT_MASK)
-				ret = nf_nat_irc(pskb, ctinfo,
+				ret = nf_nat_irc(skb, ctinfo,
 						 addr_beg_p - ib_ptr,
 						 addr_end_p - addr_beg_p,
 						 exp);
diff --git a/net/netfilter/nf_conntrack_netbios_ns.c b/net/netfilter/nf_conntrack_netbios_ns.c
index 1d59fab..9810d81 100644
--- a/net/netfilter/nf_conntrack_netbios_ns.c
+++ b/net/netfilter/nf_conntrack_netbios_ns.c
@@ -42,17 +42,17 @@ static unsigned int timeout __read_mostly = 3;
 module_param(timeout, uint, 0400);
 MODULE_PARM_DESC(timeout, "timeout for master connection/replies in seconds");
 
-static int help(struct sk_buff **pskb, unsigned int protoff,
+static int help(struct sk_buff *skb, unsigned int protoff,
 		struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	struct nf_conntrack_expect *exp;
-	struct iphdr *iph = ip_hdr(*pskb);
-	struct rtable *rt = (struct rtable *)(*pskb)->dst;
+	struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt = (struct rtable *)skb->dst;
 	struct in_device *in_dev;
 	__be32 mask = 0;
 
 	/* we're only interested in locally generated packets */
-	if ((*pskb)->sk == NULL)
+	if (skb->sk == NULL)
 		goto out;
 	if (rt == NULL || !(rt->rt_flags & RTCF_BROADCAST))
 		goto out;
@@ -91,7 +91,7 @@ static int help(struct sk_buff **pskb, unsigned int protoff,
 	nf_ct_expect_related(exp);
 	nf_ct_expect_put(exp);
 
-	nf_ct_refresh(ct, *pskb, timeout * HZ);
+	nf_ct_refresh(ct, skb, timeout * HZ);
 out:
 	return NF_ACCEPT;
 }
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index b080419..099b6df 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -41,14 +41,14 @@ MODULE_ALIAS("ip_conntrack_pptp");
 static DEFINE_SPINLOCK(nf_pptp_lock);
 
 int
-(*nf_nat_pptp_hook_outbound)(struct sk_buff **pskb,
+(*nf_nat_pptp_hook_outbound)(struct sk_buff *skb,
 			     struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			     struct PptpControlHeader *ctlh,
 			     union pptp_ctrl_union *pptpReq) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_pptp_hook_outbound);
 
 int
-(*nf_nat_pptp_hook_inbound)(struct sk_buff **pskb,
+(*nf_nat_pptp_hook_inbound)(struct sk_buff *skb,
 			    struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 			    struct PptpControlHeader *ctlh,
 			    union pptp_ctrl_union *pptpReq) __read_mostly;
@@ -254,7 +254,7 @@ out_unexpect_orig:
 }
 
 static inline int
-pptp_inbound_pkt(struct sk_buff **pskb,
+pptp_inbound_pkt(struct sk_buff *skb,
 		 struct PptpControlHeader *ctlh,
 		 union pptp_ctrl_union *pptpReq,
 		 unsigned int reqlen,
@@ -367,7 +367,7 @@ pptp_inbound_pkt(struct sk_buff **pskb,
 
 	nf_nat_pptp_inbound = rcu_dereference(nf_nat_pptp_hook_inbound);
 	if (nf_nat_pptp_inbound && ct->status & IPS_NAT_MASK)
-		return nf_nat_pptp_inbound(pskb, ct, ctinfo, ctlh, pptpReq);
+		return nf_nat_pptp_inbound(skb, ct, ctinfo, ctlh, pptpReq);
 	return NF_ACCEPT;
 
 invalid:
@@ -380,7 +380,7 @@ invalid:
 }
 
 static inline int
-pptp_outbound_pkt(struct sk_buff **pskb,
+pptp_outbound_pkt(struct sk_buff *skb,
 		  struct PptpControlHeader *ctlh,
 		  union pptp_ctrl_union *pptpReq,
 		  unsigned int reqlen,
@@ -462,7 +462,7 @@ pptp_outbound_pkt(struct sk_buff **pskb,
 
 	nf_nat_pptp_outbound = rcu_dereference(nf_nat_pptp_hook_outbound);
 	if (nf_nat_pptp_outbound && ct->status & IPS_NAT_MASK)
-		return nf_nat_pptp_outbound(pskb, ct, ctinfo, ctlh, pptpReq);
+		return nf_nat_pptp_outbound(skb, ct, ctinfo, ctlh, pptpReq);
 	return NF_ACCEPT;
 
 invalid:
@@ -492,7 +492,7 @@ static const unsigned int pptp_msg_size[] = {
 
 /* track caller id inside control connection, call expect_related */
 static int
-conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
+conntrack_pptp_help(struct sk_buff *skb, unsigned int protoff,
 		    struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 
 {
@@ -502,7 +502,7 @@ conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
 	struct pptp_pkt_hdr _pptph, *pptph;
 	struct PptpControlHeader _ctlh, *ctlh;
 	union pptp_ctrl_union _pptpReq, *pptpReq;
-	unsigned int tcplen = (*pskb)->len - protoff;
+	unsigned int tcplen = skb->len - protoff;
 	unsigned int datalen, reqlen, nexthdr_off;
 	int oldsstate, oldcstate;
 	int ret;
@@ -514,12 +514,12 @@ conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
 		return NF_ACCEPT;
 
 	nexthdr_off = protoff;
-	tcph = skb_header_pointer(*pskb, nexthdr_off, sizeof(_tcph), &_tcph);
+	tcph = skb_header_pointer(skb, nexthdr_off, sizeof(_tcph), &_tcph);
 	BUG_ON(!tcph);
 	nexthdr_off += tcph->doff * 4;
 	datalen = tcplen - tcph->doff * 4;
 
-	pptph = skb_header_pointer(*pskb, nexthdr_off, sizeof(_pptph), &_pptph);
+	pptph = skb_header_pointer(skb, nexthdr_off, sizeof(_pptph), &_pptph);
 	if (!pptph) {
 		pr_debug("no full PPTP header, can't track\n");
 		return NF_ACCEPT;
@@ -534,7 +534,7 @@ conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
 		return NF_ACCEPT;
 	}
 
-	ctlh = skb_header_pointer(*pskb, nexthdr_off, sizeof(_ctlh), &_ctlh);
+	ctlh = skb_header_pointer(skb, nexthdr_off, sizeof(_ctlh), &_ctlh);
 	if (!ctlh)
 		return NF_ACCEPT;
 	nexthdr_off += sizeof(_ctlh);
@@ -547,7 +547,7 @@ conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
 	if (reqlen > sizeof(*pptpReq))
 		reqlen = sizeof(*pptpReq);
 
-	pptpReq = skb_header_pointer(*pskb, nexthdr_off, reqlen, &_pptpReq);
+	pptpReq = skb_header_pointer(skb, nexthdr_off, reqlen, &_pptpReq);
 	if (!pptpReq)
 		return NF_ACCEPT;
 
@@ -560,11 +560,11 @@ conntrack_pptp_help(struct sk_buff **pskb, unsigned int protoff,
 	 * established from PNS->PAC.  However, RFC makes no guarantee */
 	if (dir == IP_CT_DIR_ORIGINAL)
 		/* client -> server (PNS -> PAC) */
-		ret = pptp_outbound_pkt(pskb, ctlh, pptpReq, reqlen, ct,
+		ret = pptp_outbound_pkt(skb, ctlh, pptpReq, reqlen, ct,
 					ctinfo);
 	else
 		/* server -> client (PAC -> PNS) */
-		ret = pptp_inbound_pkt(pskb, ctlh, pptpReq, reqlen, ct,
+		ret = pptp_inbound_pkt(skb, ctlh, pptpReq, reqlen, ct,
 				       ctinfo);
 	pr_debug("sstate: %d->%d, cstate: %d->%d\n",
 		 oldsstate, info->sstate, oldcstate, info->cstate);
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 355d371..b5a16c6 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -56,7 +56,7 @@ struct sane_reply_net_start {
 	/* other fields aren't interesting for conntrack */
 };
 
-static int help(struct sk_buff **pskb,
+static int help(struct sk_buff *skb,
 		unsigned int protoff,
 		struct nf_conn *ct,
 		enum ip_conntrack_info ctinfo)
@@ -80,19 +80,19 @@ static int help(struct sk_buff **pskb,
 		return NF_ACCEPT;
 
 	/* Not a full tcp header? */
-	th = skb_header_pointer(*pskb, protoff, sizeof(_tcph), &_tcph);
+	th = skb_header_pointer(skb, protoff, sizeof(_tcph), &_tcph);
 	if (th == NULL)
 		return NF_ACCEPT;
 
 	/* No data? */
 	dataoff = protoff + th->doff * 4;
-	if (dataoff >= (*pskb)->len)
+	if (dataoff >= skb->len)
 		return NF_ACCEPT;
 
-	datalen = (*pskb)->len - dataoff;
+	datalen = skb->len - dataoff;
 
 	spin_lock_bh(&nf_sane_lock);
-	sb_ptr = skb_header_pointer(*pskb, dataoff, datalen, sane_buffer);
+	sb_ptr = skb_header_pointer(skb, dataoff, datalen, sane_buffer);
 	BUG_ON(sb_ptr == NULL);
 
 	if (dir == IP_CT_DIR_ORIGINAL) {
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index d449fa4..8f8b5a4 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -36,13 +36,13 @@ static unsigned int sip_timeout __read_mostly = SIP_TIMEOUT;
 module_param(sip_timeout, uint, 0600);
 MODULE_PARM_DESC(sip_timeout, "timeout for the master SIP session");
 
-unsigned int (*nf_nat_sip_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_sip_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				struct nf_conn *ct,
 				const char **dptr) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_sip_hook);
 
-unsigned int (*nf_nat_sdp_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_sdp_hook)(struct sk_buff *skb,
 				enum ip_conntrack_info ctinfo,
 				struct nf_conntrack_expect *exp,
 				const char *dptr) __read_mostly;
@@ -363,7 +363,7 @@ int ct_sip_get_info(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(ct_sip_get_info);
 
-static int set_expected_rtp(struct sk_buff **pskb,
+static int set_expected_rtp(struct sk_buff *skb,
 			    struct nf_conn *ct,
 			    enum ip_conntrack_info ctinfo,
 			    union nf_conntrack_address *addr,
@@ -385,7 +385,7 @@ static int set_expected_rtp(struct sk_buff **pskb,
 
 	nf_nat_sdp = rcu_dereference(nf_nat_sdp_hook);
 	if (nf_nat_sdp && ct->status & IPS_NAT_MASK)
-		ret = nf_nat_sdp(pskb, ctinfo, exp, dptr);
+		ret = nf_nat_sdp(skb, ctinfo, exp, dptr);
 	else {
 		if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
@@ -397,7 +397,7 @@ static int set_expected_rtp(struct sk_buff **pskb,
 	return ret;
 }
 
-static int sip_help(struct sk_buff **pskb,
+static int sip_help(struct sk_buff *skb,
 		    unsigned int protoff,
 		    struct nf_conn *ct,
 		    enum ip_conntrack_info ctinfo)
@@ -414,13 +414,13 @@ static int sip_help(struct sk_buff **pskb,
 
 	/* No Data ? */
 	dataoff = protoff + sizeof(struct udphdr);
-	if (dataoff >= (*pskb)->len)
+	if (dataoff >= skb->len)
 		return NF_ACCEPT;
 
-	nf_ct_refresh(ct, *pskb, sip_timeout * HZ);
+	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (!skb_is_nonlinear(*pskb))
-		dptr = (*pskb)->data + dataoff;
+	if (!skb_is_nonlinear(skb))
+		dptr = skb->data + dataoff;
 	else {
 		pr_debug("Copy of skbuff not supported yet.\n");
 		goto out;
@@ -428,13 +428,13 @@ static int sip_help(struct sk_buff **pskb,
 
 	nf_nat_sip = rcu_dereference(nf_nat_sip_hook);
 	if (nf_nat_sip && ct->status & IPS_NAT_MASK) {
-		if (!nf_nat_sip(pskb, ctinfo, ct, &dptr)) {
+		if (!nf_nat_sip(skb, ctinfo, ct, &dptr)) {
 			ret = NF_DROP;
 			goto out;
 		}
 	}
 
-	datalen = (*pskb)->len - dataoff;
+	datalen = skb->len - dataoff;
 	if (datalen < sizeof("SIP/2.0 200") - 1)
 		goto out;
 
@@ -464,7 +464,7 @@ static int sip_help(struct sk_buff **pskb,
 				ret = NF_DROP;
 				goto out;
 			}
-			ret = set_expected_rtp(pskb, ct, ctinfo, &addr,
+			ret = set_expected_rtp(skb, ct, ctinfo, &addr,
 					       htons(port), dptr);
 		}
 	}
diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index cc19506..e894aa1 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -29,12 +29,12 @@ static int ports_c;
 module_param_array(ports, ushort, &ports_c, 0400);
 MODULE_PARM_DESC(ports, "Port numbers of TFTP servers");
 
-unsigned int (*nf_nat_tftp_hook)(struct sk_buff **pskb,
+unsigned int (*nf_nat_tftp_hook)(struct sk_buff *skb,
 				 enum ip_conntrack_info ctinfo,
 				 struct nf_conntrack_expect *exp) __read_mostly;
 EXPORT_SYMBOL_GPL(nf_nat_tftp_hook);
 
-static int tftp_help(struct sk_buff **pskb,
+static int tftp_help(struct sk_buff *skb,
 		     unsigned int protoff,
 		     struct nf_conn *ct,
 		     enum ip_conntrack_info ctinfo)
@@ -46,7 +46,7 @@ static int tftp_help(struct sk_buff **pskb,
 	int family = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
 	typeof(nf_nat_tftp_hook) nf_nat_tftp;
 
-	tfh = skb_header_pointer(*pskb, protoff + sizeof(struct udphdr),
+	tfh = skb_header_pointer(skb, protoff + sizeof(struct udphdr),
 				 sizeof(_tftph), &_tftph);
 	if (tfh == NULL)
 		return NF_ACCEPT;
@@ -70,7 +70,7 @@ static int tftp_help(struct sk_buff **pskb,
 
 		nf_nat_tftp = rcu_dereference(nf_nat_tftp_hook);
 		if (nf_nat_tftp && ct->status & IPS_NAT_MASK)
-			ret = nf_nat_tftp(pskb, ctinfo, exp);
+			ret = nf_nat_tftp(skb, ctinfo, exp);
 		else if (nf_ct_expect_related(exp) != 0)
 			ret = NF_DROP;
 		nf_ct_expect_put(exp);
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 0df7fff..196269c 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -14,7 +14,7 @@
 
 /* core.c */
 extern unsigned int nf_iterate(struct list_head *head,
-				struct sk_buff **skb,
+				struct sk_buff *skb,
 				int hook,
 				const struct net_device *indev,
 				const struct net_device *outdev,
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
diff --git a/net/netfilter/xt_CLASSIFY.c b/net/netfilter/xt_CLASSIFY.c
index 07a1b96..77eeae6 100644
--- a/net/netfilter/xt_CLASSIFY.c
+++ b/net/netfilter/xt_CLASSIFY.c
@@ -27,7 +27,7 @@ MODULE_ALIAS("ipt_CLASSIFY");
 MODULE_ALIAS("ip6t_CLASSIFY");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -36,7 +36,7 @@ target(struct sk_buff **pskb,
 {
 	const struct xt_classify_target_info *clinfo = targinfo;
 
-	(*pskb)->priority = clinfo->priority;
+	skb->priority = clinfo->priority;
 	return XT_CONTINUE;
 }
 
diff --git a/net/netfilter/xt_CONNMARK.c b/net/netfilter/xt_CONNMARK.c
index 7043c27..8cc324b 100644
--- a/net/netfilter/xt_CONNMARK.c
+++ b/net/netfilter/xt_CONNMARK.c
@@ -34,7 +34,7 @@ MODULE_ALIAS("ip6t_CONNMARK");
 #include <net/netfilter/nf_conntrack_ecache.h>
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -48,28 +48,28 @@ target(struct sk_buff **pskb,
 	u_int32_t mark;
 	u_int32_t newmark;
 
-	ct = nf_ct_get(*pskb, &ctinfo);
+	ct = nf_ct_get(skb, &ctinfo);
 	if (ct) {
 		switch(markinfo->mode) {
 		case XT_CONNMARK_SET:
 			newmark = (ct->mark & ~markinfo->mask) | markinfo->mark;
 			if (newmark != ct->mark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, *pskb);
+				nf_conntrack_event_cache(IPCT_MARK, skb);
 			}
 			break;
 		case XT_CONNMARK_SAVE:
 			newmark = (ct->mark & ~markinfo->mask) |
-				  ((*pskb)->mark & markinfo->mask);
+				  (skb->mark & markinfo->mask);
 			if (ct->mark != newmark) {
 				ct->mark = newmark;
-				nf_conntrack_event_cache(IPCT_MARK, *pskb);
+				nf_conntrack_event_cache(IPCT_MARK, skb);
 			}
 			break;
 		case XT_CONNMARK_RESTORE:
-			mark = (*pskb)->mark;
+			mark = skb->mark;
 			diff = (ct->mark ^ mark) & markinfo->mask;
-			(*pskb)->mark = mark ^ diff;
+			skb->mark = mark ^ diff;
 			break;
 		}
 	}
diff --git a/net/netfilter/xt_CONNSECMARK.c b/net/netfilter/xt_CONNSECMARK.c
index 63d7313..021b5c8 100644
--- a/net/netfilter/xt_CONNSECMARK.c
+++ b/net/netfilter/xt_CONNSECMARK.c
@@ -61,12 +61,11 @@ static void secmark_restore(struct sk_buff *skb)
 	}
 }
 
-static unsigned int target(struct sk_buff **pskb, const struct net_device *in,
+static unsigned int target(struct sk_buff *skb, const struct net_device *in,
 			   const struct net_device *out, unsigned int hooknum,
 			   const struct xt_target *target,
 			   const void *targinfo)
 {
-	struct sk_buff *skb = *pskb;
 	const struct xt_connsecmark_target_info *info = targinfo;
 
 	switch (info->mode) {
diff --git a/net/netfilter/xt_DSCP.c b/net/netfilter/xt_DSCP.c
index 1706616..6322a93 100644
--- a/net/netfilter/xt_DSCP.c
+++ b/net/netfilter/xt_DSCP.c
@@ -25,7 +25,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_DSCP");
 MODULE_ALIAS("ip6t_DSCP");
 
-static unsigned int target(struct sk_buff **pskb,
+static unsigned int target(struct sk_buff *skb,
 			   const struct net_device *in,
 			   const struct net_device *out,
 			   unsigned int hooknum,
@@ -33,20 +33,20 @@ static unsigned int target(struct sk_buff **pskb,
 			   const void *targinfo)
 {
 	const struct xt_DSCP_info *dinfo = targinfo;
-	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(*pskb)) >> XT_DSCP_SHIFT;
+	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(skb)) >> XT_DSCP_SHIFT;
 
 	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(*pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(skb, sizeof(struct iphdr)))
 			return NF_DROP;
 
-		ipv4_change_dsfield(ip_hdr(*pskb), (__u8)(~XT_DSCP_MASK),
+		ipv4_change_dsfield(ip_hdr(skb), (__u8)(~XT_DSCP_MASK),
 				    dinfo->dscp << XT_DSCP_SHIFT);
 
 	}
 	return XT_CONTINUE;
 }
 
-static unsigned int target6(struct sk_buff **pskb,
+static unsigned int target6(struct sk_buff *skb,
 			    const struct net_device *in,
 			    const struct net_device *out,
 			    unsigned int hooknum,
@@ -54,13 +54,13 @@ static unsigned int target6(struct sk_buff **pskb,
 			    const void *targinfo)
 {
 	const struct xt_DSCP_info *dinfo = targinfo;
-	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(*pskb)) >> XT_DSCP_SHIFT;
+	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(skb)) >> XT_DSCP_SHIFT;
 
 	if (dscp != dinfo->dscp) {
-		if (!skb_make_writable(*pskb, sizeof(struct ipv6hdr)))
+		if (!skb_make_writable(skb, sizeof(struct ipv6hdr)))
 			return NF_DROP;
 
-		ipv6_change_dsfield(ipv6_hdr(*pskb), (__u8)(~XT_DSCP_MASK),
+		ipv6_change_dsfield(ipv6_hdr(skb), (__u8)(~XT_DSCP_MASK),
 				    dinfo->dscp << XT_DSCP_SHIFT);
 	}
 	return XT_CONTINUE;
diff --git a/net/netfilter/xt_MARK.c b/net/netfilter/xt_MARK.c
index f30fe0b..bc6503d 100644
--- a/net/netfilter/xt_MARK.c
+++ b/net/netfilter/xt_MARK.c
@@ -22,7 +22,7 @@ MODULE_ALIAS("ipt_MARK");
 MODULE_ALIAS("ip6t_MARK");
 
 static unsigned int
-target_v0(struct sk_buff **pskb,
+target_v0(struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  unsigned int hooknum,
@@ -31,12 +31,12 @@ target_v0(struct sk_buff **pskb,
 {
 	const struct xt_mark_target_info *markinfo = targinfo;
 
-	(*pskb)->mark = markinfo->mark;
+	skb->mark = markinfo->mark;
 	return XT_CONTINUE;
 }
 
 static unsigned int
-target_v1(struct sk_buff **pskb,
+target_v1(struct sk_buff *skb,
 	  const struct net_device *in,
 	  const struct net_device *out,
 	  unsigned int hooknum,
@@ -52,15 +52,15 @@ target_v1(struct sk_buff **pskb,
 		break;
 
 	case XT_MARK_AND:
-		mark = (*pskb)->mark & markinfo->mark;
+		mark = skb->mark & markinfo->mark;
 		break;
 
 	case XT_MARK_OR:
-		mark = (*pskb)->mark | markinfo->mark;
+		mark = skb->mark | markinfo->mark;
 		break;
 	}
 
-	(*pskb)->mark = mark;
+	skb->mark = mark;
 	return XT_CONTINUE;
 }
 
diff --git a/net/netfilter/xt_NFLOG.c b/net/netfilter/xt_NFLOG.c
index d3594c7..9fb449f 100644
--- a/net/netfilter/xt_NFLOG.c
+++ b/net/netfilter/xt_NFLOG.c
@@ -20,7 +20,7 @@ MODULE_ALIAS("ipt_NFLOG");
 MODULE_ALIAS("ip6t_NFLOG");
 
 static unsigned int
-nflog_target(struct sk_buff **pskb,
+nflog_target(struct sk_buff *skb,
 	     const struct net_device *in, const struct net_device *out,
 	     unsigned int hooknum, const struct xt_target *target,
 	     const void *targinfo)
@@ -33,7 +33,7 @@ nflog_target(struct sk_buff **pskb,
 	li.u.ulog.group	     = info->group;
 	li.u.ulog.qthreshold = info->threshold;
 
-	nf_log_packet(target->family, hooknum, *pskb, in, out, &li,
+	nf_log_packet(target->family, hooknum, skb, in, out, &li,
 		      "%s", info->prefix);
 	return XT_CONTINUE;
 }
diff --git a/net/netfilter/xt_NFQUEUE.c b/net/netfilter/xt_NFQUEUE.c
index 13f59f3..c3984e9 100644
--- a/net/netfilter/xt_NFQUEUE.c
+++ b/net/netfilter/xt_NFQUEUE.c
@@ -24,7 +24,7 @@ MODULE_ALIAS("ip6t_NFQUEUE");
 MODULE_ALIAS("arpt_NFQUEUE");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
index fec1aef..4976ce1 100644
--- a/net/netfilter/xt_NOTRACK.c
+++ b/net/netfilter/xt_NOTRACK.c
@@ -12,7 +12,7 @@ MODULE_ALIAS("ipt_NOTRACK");
 MODULE_ALIAS("ip6t_NOTRACK");
 
 static unsigned int
-target(struct sk_buff **pskb,
+target(struct sk_buff *skb,
        const struct net_device *in,
        const struct net_device *out,
        unsigned int hooknum,
@@ -20,16 +20,16 @@ target(struct sk_buff **pskb,
        const void *targinfo)
 {
 	/* Previously seen (loopback)? Ignore. */
-	if ((*pskb)->nfct != NULL)
+	if (skb->nfct != NULL)
 		return XT_CONTINUE;
 
 	/* Attach fake conntrack entry.
 	   If there is a real ct entry correspondig to this packet,
 	   it'll hang aroun till timing out. We don't deal with it
 	   for performance reasons. JK */
-	(*pskb)->nfct = &nf_conntrack_untracked.ct_general;
-	(*pskb)->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get((*pskb)->nfct);
+	skb->nfct = &nf_conntrack_untracked.ct_general;
+	skb->nfctinfo = IP_CT_NEW;
+	nf_conntrack_get(skb->nfct);
 
 	return XT_CONTINUE;
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
