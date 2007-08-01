From: Mika Kukkonen <mikukkon@iki.fi>
Subject: [NET][JANITOR] Add const string const-goodness to net/* and
	include/net/*
Date: Wed, 1 Aug 2007 15:34:56 +0300
Message-ID: <20070801123456.GA17706@srv1-m700-lanp.koti>
Reply-To: mikukkon@iki.fi
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-66.nebula.fi ([83.145.220.66]:47345 "EHLO
	smtp-66.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761576AbXHANHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 09:07:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compiling with "EXTRA_CFLAGS=-Wwrite-strings" reveals several places where
plain "char *" can be changed to "const char *". This patch does these
trivial and no-funtionality-changed changes to net/* and include/net/*.

Sadly this did not result in any savings in .text (tested by
building with allyesconfig and doing 'size -A net/builtin.o'):

$ diff before after
3c3
< .text                      2109288      0
---
> .text                      2109292      0
37c37
< .debug_info               47540379      0
---
> .debug_info               47540404      0
39c39
< .debug_line                2054813      0
---
> .debug_line                2054818      0
42c42
< .debug_loc                 2204455      0
---
> .debug_loc                 2204469      0
45c45
< Total                     78311758
---
> Total                     78311806

I'll let the others to decide, whether the additional
checking provided by the "const" makes sense...

Signed-off-by: Mika Kukkonen <mikukkon@iki.fi>

---

 include/linux/netfilter.h                      |    4 ++--
 include/linux/netfilter/x_tables.h             |    4 ++--
 include/linux/sunrpc/auth.h                    |    2 +-
 include/linux/sunrpc/cache.h                   |    2 +-
 include/linux/sunrpc/clnt.h                    |   10 ++++-----
 include/linux/sunrpc/gss_api.h                 |    4 ++--
 include/linux/sunrpc/gss_krb5.h                |    2 +-
 include/linux/sunrpc/svcauth.h                 |    4 ++--
 include/linux/sunrpc/xprt.h                    |    2 +-
 include/net/9p/9p.h                            |    2 +-
 include/net/act_api.h                          |    2 +-
 include/net/ax25.h                             |    2 +-
 include/net/bluetooth/hci_core.h               |    4 ++--
 include/net/dn_dev.h                           |    2 +-
 include/net/ip_vs.h                            |    9 ++++----
 include/net/irda/ircomm_event.h                |    2 +-
 include/net/irda/ircomm_tty_attach.h           |    3 +--
 include/net/irda/iriap.h                       |    2 +-
 include/net/irda/irias_object.h                |   27 ++++++++++++------------
 include/net/irda/irlan_common.h                |   13 +++++++-----
 include/net/irda/irlan_event.h                 |    2 +-
 include/net/irda/parameters.h                  |    2 +-
 include/net/iw_handler.h                       |    4 ++--
 include/net/neighbour.h                        |    4 ++--
 include/net/sctp/structs.h                     |    2 +-
 include/net/snmp.h                             |    2 +-
 include/net/tcp.h                              |    2 +-
 include/net/tipc/tipc_bearer.h                 |    2 +-
 include/net/udp.h                              |    2 +-
 include/net/xfrm.h                             |    8 ++++---
 net/9p/conv.c                                  |    4 ++--
 net/9p/error.c                                 |    2 +-
 net/atm/lec.c                                  |    4 ++--
 net/atm/proc.c                                 |    2 +-
 net/ax25/ax25_addr.c                           |    2 +-
 net/bluetooth/cmtp/capi.c                      |    2 +-
 net/bluetooth/hci_sysfs.c                      |    2 +-
 net/bridge/br_stp_if.c                         |    4 ++--
 net/core/dev.c                                 |    4 ++--
 net/core/neighbour.c                           |    2 +-
 net/dccp/ccids/ccid3.c                         |    4 ++--
 net/dccp/proto.c                               |    2 +-
 net/decnet/af_decnet.c                         |    2 +-
 net/decnet/dn_dev.c                            |    2 +-
 net/decnet/dn_nsp_in.c                         |    2 +-
 net/decnet/dn_route.c                          |    2 +-
 net/ieee80211/softmac/ieee80211softmac_event.c |    4 ++--
 net/ipv4/arp.c                                 |    2 +-
 net/ipv4/devinet.c                             |    2 +-
 net/ipv4/igmp.c                                |    2 +-
 net/ipv4/ipvs/ip_vs_proto.c                    |    2 +-
 net/ipv4/ipvs/ip_vs_proto_tcp.c                |    2 +-
 net/ipv4/ipvs/ip_vs_proto_udp.c                |    2 +-
 net/ipv4/netfilter/nf_nat_snmp_basic.c         |    2 +-
 net/ipv6/addrconf.c                            |    2 +-
 net/ipx/af_ipx.c                               |    2 +-
 net/irda/af_irda.c                             |    2 +-
 net/irda/ircomm/ircomm_event.c                 |    4 ++--
 net/irda/ircomm/ircomm_tty_attach.c            |    4 ++--
 net/irda/iriap.c                               |    2 +-
 net/irda/irias_object.c                        |   23 +++++++++++---------
 net/irda/irlan/irlan_common.c                  |   23 +++++++++++---------
 net/irda/irlan/irlan_event.c                   |    2 +-
 net/irda/irlap.c                               |    2 +-
 net/irda/irnet/irnet_irda.c                    |    2 +-
 net/irda/parameters.c                          |   10 ++++-----
 net/llc/llc_proc.c                             |    2 +-
 net/mac80211/debugfs_key.c                     |    2 +-
 net/netfilter/nf_conntrack_amanda.c            |    2 +-
 net/rose/rose_subr.c                           |    2 +-
 net/sched/act_api.c                            |    3 ++-
 net/sctp/socket.c                              |    2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c          |    4 ++--
 net/sunrpc/auth_gss/gss_krb5_mech.c            |    2 +-
 net/sunrpc/auth_gss/gss_mech_switch.c          |    4 ++--
 net/sunrpc/auth_gss/gss_spkm3_seal.c           |    2 +-
 net/sunrpc/clnt.c                              |    4 ++--
 net/sunrpc/rpc_pipe.c                          |    2 +-
 net/sunrpc/rpcb_clnt.c                         |    9 ++++----
 net/sunrpc/svcauth_unix.c                      |    6 +++--
 net/sunrpc/xprtsock.c                          |    4 ++--
 net/tipc/bearer.c                              |    2 +-
 net/tipc/config.c                              |    4 ++--
 net/tipc/config.h                              |    8 ++++---
 net/tipc/dbg.c                                 |    2 +-
 net/tipc/link.c                                |    2 +-
 net/tipc/name_table.c                          |    2 +-
 net/wireless/wext.c                            |    2 +-
 88 files changed, 175 insertions(+), 167 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 0eed0b7..fcd455d 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -167,7 +167,7 @@ typedef void nf_logfn(unsigned int pf,
 struct nf_logger {
 	struct module	*me;
 	nf_logfn 	*logfn;
-	char		*name;
+	const char	*name;
 };
 
 /* Function to register/unregister log function. */
@@ -271,7 +271,7 @@ struct nf_queue_handler {
 	int (*outfn)(struct sk_buff *skb, struct nf_info *info,
 		     unsigned int queuenum, void *data);
 	void *data;
-	char *name;
+	const char *name;
 };
 extern int nf_register_queue_handler(int pf, 
                                      struct nf_queue_handler *qh);
diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 64f425a..da72667 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -186,7 +186,7 @@ struct xt_target
 {
 	struct list_head list;
 
-	const char name[XT_FUNCTION_MAXNAMELEN-1];
+	const char const name[XT_FUNCTION_MAXNAMELEN-1];
 
 	/* Returns verdict. Argument order changed since 2.6.9, as this
 	   must now handle non-linear skbs, using skb_copy_bits and
@@ -218,7 +218,7 @@ struct xt_target
 	/* Set this to THIS_MODULE if you are a module, otherwise NULL */
 	struct module *me;
 
-	char *table;
+	const char *table;
 	unsigned int targetsize;
 	unsigned int compatsize;
 	unsigned int hooks;
diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 7a69ca3..793cc2f 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -98,7 +98,7 @@ struct rpc_authops {
 	struct module		*owner;
 	rpc_authflavor_t	au_flavor;	/* flavor (RPC_AUTH_*) */
 #ifdef RPC_DEBUG
-	char *			au_name;
+	const char *		au_name;
 #endif
 	struct rpc_auth *	(*create)(struct rpc_clnt *, rpc_authflavor_t);
 	void			(*destroy)(struct rpc_auth *);
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 3699dff..6dd9867 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -67,7 +67,7 @@ struct cache_detail {
 
 	atomic_t		inuse; /* active user-space update or lookup */
 
-	char			*name;
+	const char		*name;
 	void			(*cache_put)(struct kref *);
 
 	void			(*cache_request)(struct cache_detail *cd,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c0d9d14..653e6e9 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -35,7 +35,7 @@ struct rpc_clnt {
 				cl_maxproc;	/* max procedure number */
 
 	char *			cl_server;	/* server machine name */
-	char *			cl_protname;	/* protocol name */
+	const char *		cl_protname;	/* protocol name */
 	struct rpc_auth *	cl_auth;	/* authenticator */
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
@@ -63,7 +63,7 @@ struct rpc_clnt {
  */
 #define RPC_MAXVERSION		4
 struct rpc_program {
-	char *			name;		/* protocol name */
+	const char *		name;		/* protocol name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
 	struct rpc_version **	version;	/* version array */
@@ -89,7 +89,7 @@ struct rpc_procinfo {
 	unsigned int		p_count;	/* call count */
 	unsigned int		p_timer;	/* Which RTT timer to use */
 	u32			p_statidx;	/* Which procedure to account */
-	char *			p_name;		/* name of procedure */
+	const char *		p_name;		/* name of procedure */
 };
 
 #ifdef __KERNEL__
@@ -100,7 +100,7 @@ struct rpc_create_args {
 	size_t			addrsize;
 	struct sockaddr		*saddress;
 	struct rpc_timeout	*timeout;
-	char			*servername;
+	const char		*servername;
 	struct rpc_program	*program;
 	u32			version;
 	rpc_authflavor_t	authflavor;
@@ -142,7 +142,7 @@ void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
-char *		rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
+const char *	rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
 
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_CLNT_H */
diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
index 459c5fc..638b571 100644
--- a/include/linux/sunrpc/gss_api.h
+++ b/include/linux/sunrpc/gss_api.h
@@ -65,7 +65,7 @@ char *gss_service_to_auth_domain_name(struct gss_api_mech *, u32 service);
 struct pf_desc {
 	u32	pseudoflavor;
 	u32	service;
-	char	*name;
+	const char *name;
 	char	*auth_domain_name;
 };
 
@@ -77,7 +77,7 @@ struct gss_api_mech {
 	struct list_head	gm_list;
 	struct module		*gm_owner;
 	struct xdr_netobj	gm_oid;
-	char			*gm_name;
+	const char		*gm_name;
 	const struct gss_api_ops *gm_ops;
 	/* pseudoflavors supported by this mechanism: */
 	int			gm_pf_num;
diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 5a4b1e0..b45aa0c 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -113,7 +113,7 @@ enum seal_alg {
 #define ENCTYPE_UNKNOWN         0x01ff
 
 s32
-make_checksum(char *, char *header, int hdrlen, struct xdr_buf *body,
+make_checksum(const char *, char *header, int hdrlen, struct xdr_buf *body,
 		   int body_offset, struct xdr_netobj *cksum);
 
 u32 gss_get_mic_kerberos(struct gss_ctx *, struct xdr_buf *,
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index 22e1ef8..bffd339 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -92,7 +92,7 @@ struct auth_domain {
  *   an appropriate 'auth_domain' as the client.
  */
 struct auth_ops {
-	char *	name;
+	const char *name;
 	struct module *owner;
 	int	flavour;
 	int	(*accept)(struct svc_rqst *rq, __be32 *authp);
@@ -129,7 +129,7 @@ extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(void *);
 extern int svcauth_unix_set_client(struct svc_rqst *rqstp);
 
-static inline unsigned long hash_str(char *name, int bits)
+static inline unsigned long hash_str(const char *name, int bits)
 {
 	unsigned long hash = 0;
 	unsigned long l = 0;
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index d11cedd..c43d613 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -193,7 +193,7 @@ struct rpc_xprt {
 					bklog_u;	/* backlog queue utilization */
 	} stat;
 
-	char *			address_strings[RPC_DISPLAY_MAX];
+	const char *		address_strings[RPC_DISPLAY_MAX];
 };
 
 struct rpc_xprtsock_create {
diff --git a/include/net/9p/9p.h b/include/net/9p/9p.h
index 88884d3..24e6a48 100644
--- a/include/net/9p/9p.h
+++ b/include/net/9p/9p.h
@@ -380,7 +380,7 @@ int p9_deserialize_stat(void *buf, u32 buflen, struct p9_stat *stat,
 	int dotu);
 int p9_deserialize_fcall(void *buf, u32 buflen, struct p9_fcall *fc, int dotu);
 void p9_set_tag(struct p9_fcall *fc, u16 tag);
-struct p9_fcall *p9_create_tversion(u32 msize, char *version);
+struct p9_fcall *p9_create_tversion(u32 msize, const char *version);
 struct p9_fcall *p9_create_tattach(u32 fid, u32 afid, char *uname,
 	char *aname);
 struct p9_fcall *p9_create_tauth(u32 afid, char *uname, char *aname);
diff --git a/include/net/act_api.h b/include/net/act_api.h
index 68b4eaf..72a76b1 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -115,7 +115,7 @@ extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
 extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
 extern struct tc_action *tcf_action_init(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
-extern struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
+extern struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est, const char *n, int ovr, int bind, int *err);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff --git a/include/net/ax25.h b/include/net/ax25.h
index 99a4e36..a5c5f47 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -285,7 +285,7 @@ extern struct sock *ax25_make_new(struct sock *, struct ax25_dev *);
 extern const ax25_address ax25_bcast;
 extern const ax25_address ax25_defaddr;
 extern const ax25_address null_ax25_address;
-extern char *ax2asc(char *buf, const ax25_address *);
+extern const char *ax2asc(char *buf, const ax25_address *);
 extern void asc2ax(ax25_address *addr, const char *callsign);
 extern int ax25cmp(const ax25_address *, const ax25_address *);
 extern int ax25digicmp(const ax25_digi *, const ax25_digi *);
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index 8f67c8a..de36523 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -457,7 +457,7 @@ void hci_conn_del_sysfs(struct hci_conn *conn);
 
 /* ----- HCI protocols ----- */
 struct hci_proto {
-	char 		*name;
+	const char	*name;
 	unsigned int	id;
 	unsigned long	flags;
 
@@ -547,7 +547,7 @@ int hci_unregister_proto(struct hci_proto *hproto);
 struct hci_cb {
 	struct list_head list;
 
-	char *name;
+	const char *name;
 
 	void (*auth_cfm)	(struct hci_conn *conn, __u8 status);
 	void (*encrypt_cfm)	(struct hci_conn *conn, __u8 status, __u8 encrypt);
diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index cee4682..9c12b8a 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -74,7 +74,7 @@ struct dn_dev_parms {
 	unsigned long t2;         /* Default value of t2                */
 	unsigned long t3;         /* Default value of t3                */
 	int priority;             /* Priority to be a router            */
-	char *name;               /* Name for sysctl                    */
+	const char *name;         /* Name for sysctl                    */
 	int ctl_name;             /* Index for sysctl                   */
 	int  (*up)(struct net_device *);
 	void (*down)(struct net_device *);
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 672564e..93c7547 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -436,7 +436,7 @@ struct sk_buff;
 
 struct ip_vs_protocol {
 	struct ip_vs_protocol	*next;
-	char			*name;
+	const char		*name;
 	__u16			protocol;
 	int			dont_defrag;
 	atomic_t		appcnt;		/* counter of proto app incs */
@@ -617,7 +617,7 @@ struct ip_vs_dest {
  */
 struct ip_vs_scheduler {
 	struct list_head	n_list;		/* d-linked list head */
-	char			*name;		/* scheduler name */
+	const char		*name;		/* scheduler name */
 	atomic_t		refcnt;		/* reference counter */
 	struct module		*module;	/* THIS_MODULE/NULL */
 
@@ -641,7 +641,7 @@ struct ip_vs_app
 {
 	struct list_head	a_list;		/* member in app list */
 	int			type;		/* IP_VS_APP_TYPE_xxx */
-	char			*name;		/* application module name */
+	const char		*name;		/* application module name */
 	__u16			protocol;
 	struct module		*module;	/* THIS_MODULE/NULL */
 	struct list_head	incs_list;	/* list of incarnations */
@@ -848,7 +848,8 @@ extern void ip_vs_protocol_cleanup(void);
 extern void ip_vs_protocol_timeout_change(int flags);
 extern int *ip_vs_create_timeout_table(int *table, int size);
 extern int
-ip_vs_set_state_timeout(int *table, int num, char **names, char *name, int to);
+ip_vs_set_state_timeout(int *table, int num, const char **names,
+			char *name, int to);
 extern void
 ip_vs_tcpudp_debug_packet(struct ip_vs_protocol *pp, const struct sk_buff *skb,
 			  int offset, const char *msg);
diff --git a/include/net/irda/ircomm_event.h b/include/net/irda/ircomm_event.h
index c290447..df27171 100644
--- a/include/net/irda/ircomm_event.h
+++ b/include/net/irda/ircomm_event.h
@@ -74,7 +74,7 @@ struct ircomm_info {
 	struct qos_info *qos;
 };
 
-extern char *ircomm_state[];
+extern const char *ircomm_state[];
 
 struct ircomm_cb;   /* Forward decl. */
 
diff --git a/include/net/irda/ircomm_tty_attach.h b/include/net/irda/ircomm_tty_attach.h
index f91a569..1d58f7a 100644
--- a/include/net/irda/ircomm_tty_attach.h
+++ b/include/net/irda/ircomm_tty_attach.h
@@ -66,8 +66,7 @@ struct ircomm_tty_info {
         __u8      dlsap_sel;
 };
 
-extern char *ircomm_state[];
-extern char *ircomm_tty_state[];
+extern const char *ircomm_tty_state[];
 
 int ircomm_tty_do_event(struct ircomm_tty_cb *self, IRCOMM_TTY_EVENT event,
 			struct sk_buff *skb, struct ircomm_tty_info *info);
diff --git a/include/net/irda/iriap.h b/include/net/irda/iriap.h
index fcc8964..86cab5c 100644
--- a/include/net/irda/iriap.h
+++ b/include/net/irda/iriap.h
@@ -96,7 +96,7 @@ void iriap_close(struct iriap_cb *self);
 
 int iriap_getvaluebyclass_request(struct iriap_cb *self, 
 				  __u32 saddr, __u32 daddr,
-				  char *name, char *attr);
+				  const char *name, const char *attr);
 void iriap_connect_request(struct iriap_cb *self);
 void iriap_send_ack( struct iriap_cb *self);
 void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb);
diff --git a/include/net/irda/irias_object.h b/include/net/irda/irias_object.h
index 83f7808..b407239 100644
--- a/include/net/irda/irias_object.h
+++ b/include/net/irda/irias_object.h
@@ -62,7 +62,7 @@ struct ias_value {
 	/* Value */
 	union {
 		int integer;
-		char *string;
+		const char *string;
 		__u8 *oct_seq;
 	} t;
 };
@@ -74,29 +74,30 @@ struct ias_attrib {
 	irda_queue_t q; /* Must be first! */
 	int magic;
 
-        char *name;   	         /* Attribute name */
+	const char *name;	 /* Attribute name */
 	struct ias_value *value; /* Attribute value */
 };
 
-struct ias_object *irias_new_object(char *name, int id);
+struct ias_object *irias_new_object(const char *name, int id);
 void irias_insert_object(struct ias_object *obj);
 int  irias_delete_object(struct ias_object *obj);
 int  irias_delete_attrib(struct ias_object *obj, struct ias_attrib *attrib,
 			 int cleanobject);
 void __irias_delete_object(struct ias_object *obj);
 
-void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
-			      int user);
-void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
-			     int user);
-void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
-			     int len, int user);
-int irias_object_change_attribute(char *obj_name, char *attrib_name, 
+void irias_add_integer_attrib(struct ias_object *obj, const char *name,
+			      int value, int user);
+void irias_add_string_attrib(struct ias_object *obj, const char *name,
+			     const char *value, int user);
+void irias_add_octseq_attrib(struct ias_object *obj, const char *name,
+			     __u8 *octets, int len, int user);
+int irias_object_change_attribute(const char *obj_name,
+				  const char *attrib_name, 
 				  struct ias_value *new_value);
-struct ias_object *irias_find_object(char *name);
-struct ias_attrib *irias_find_attrib(struct ias_object *obj, char *name);
+struct ias_object *irias_find_object(const char *name);
+struct ias_attrib *irias_find_attrib(struct ias_object *obj, const char *name);
 
-struct ias_value *irias_new_string_value(char *string);
+struct ias_value *irias_new_string_value(const char *string);
 struct ias_value *irias_new_integer_value(int integer);
 struct ias_value *irias_new_octseq_value(__u8 *octseq , int len);
 struct ias_value *irias_new_missing_value(void);
diff --git a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
index 73cacb3..e06da60 100644
--- a/include/net/irda/irlan_common.h
+++ b/include/net/irda/irlan_common.h
@@ -217,11 +217,14 @@ void irlan_close_data_channel(struct irlan_cb *self);
 void irlan_set_multicast_filter(struct irlan_cb *self, int status);
 void irlan_set_broadcast_filter(struct irlan_cb *self, int status);
 
-int irlan_insert_byte_param(struct sk_buff *skb, char *param, __u8 value);
-int irlan_insert_short_param(struct sk_buff *skb, char *param, __u16 value);
-int irlan_insert_string_param(struct sk_buff *skb, char *param, char *value);
-int irlan_insert_array_param(struct sk_buff *skb, char *name, __u8 *value, 
-			     __u16 value_len);
+int irlan_insert_byte_param(struct sk_buff *skb,
+			    const char *param, __u8 value);
+int irlan_insert_short_param(struct sk_buff *skb,
+			     const char *param, __u16 value);
+int irlan_insert_string_param(struct sk_buff *skb,
+			      const char *param, const char *value);
+int irlan_insert_array_param(struct sk_buff *skb, const char *name,
+			     __u8 *value, __u16 value_len);
 
 int irlan_extract_param(__u8 *buf, char *name, char *value, __u16 *len);
 
diff --git a/include/net/irda/irlan_event.h b/include/net/irda/irlan_event.h
index 6d9539f..75fe8fc 100644
--- a/include/net/irda/irlan_event.h
+++ b/include/net/irda/irlan_event.h
@@ -67,7 +67,7 @@ typedef enum {
 	IRLAN_WATCHDOG_TIMEOUT,
 } IRLAN_EVENT;
 
-extern char *irlan_state[];
+extern const char *irlan_state[];
 
 void irlan_do_client_event(struct irlan_cb *self, IRLAN_EVENT event, 
 			   struct sk_buff *skb);
diff --git a/include/net/irda/parameters.h b/include/net/irda/parameters.h
index c0d9388..bd538b2 100644
--- a/include/net/irda/parameters.h
+++ b/include/net/irda/parameters.h
@@ -89,7 +89,7 @@ typedef struct {
 	int              pi_major_offset;
 } pi_param_info_t;
 
-int irda_param_pack(__u8 *buf, char *fmt, ...);
+int irda_param_pack(__u8 *buf, const char *fmt, ...);
 
 int irda_param_insert(void *self, __u8 pi, __u8 *buf, int len, 
 		      pi_param_info_t *info);
diff --git a/include/net/iw_handler.h b/include/net/iw_handler.h
index f23d07c..a5865fa 100644
--- a/include/net/iw_handler.h
+++ b/include/net/iw_handler.h
@@ -437,7 +437,7 @@ struct iw_public_data {
 extern void wireless_send_event(struct net_device *	dev,
 				unsigned int		cmd,
 				union iwreq_data *	wrqu,
-				char *			extra);
+				const char *		extra);
 
 /* We may need a function to send a stream of events to user space.
  * More on that later... */
@@ -504,7 +504,7 @@ static inline char *
 iwe_stream_add_point(char *	stream,		/* Stream of events */
 		     char *	ends,		/* End of stream */
 		     struct iw_event *iwe,	/* Payload length + flags */
-		     char *	extra)		/* More payload */
+		     const char *extra)		/* More payload */
 {
 	int	event_len = IW_EV_POINT_LEN + iwe->u.data.length;
 	/* Check if it's possible */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index a4f2618..0c31675 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -147,7 +147,7 @@ struct neigh_table
 	int			(*pconstructor)(struct pneigh_entry *);
 	void			(*pdestructor)(struct pneigh_entry *);
 	void			(*proxy_redo)(struct sk_buff *skb);
-	char			*id;
+	const char		*id;
 	struct neigh_parms	parms;
 	/* HACK. gc_* shoul follow parms without a gap! */
 	int			gc_interval;
@@ -236,7 +236,7 @@ extern void neigh_seq_stop(struct seq_file *, void *);
 extern int			neigh_sysctl_register(struct net_device *dev, 
 						      struct neigh_parms *p,
 						      int p_id, int pdev_id,
-						      char *p_name,
+						      const char *p_name,
 						      proc_handler *proc_handler,
 						      ctl_handler *strategy);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ee4559b..a9cd773 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1878,7 +1878,7 @@ typedef struct sctp_cmsgs {
 
 /* Structure for tracking memory objects */
 typedef struct {
-	char *label;
+	const char *label;
 	atomic_t *counter;
 } sctp_dbg_objcnt_entry_t;
 
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 464970e..ff3f4b8 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -33,7 +33,7 @@
  *  - name of entries.
  */
 struct snmp_mib {
-	char *name;
+	const char *name;
 	int entry;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c209361..b8d5c94 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1286,7 +1286,7 @@ enum tcp_seq_states {
 
 struct tcp_seq_afinfo {
 	struct module		*owner;
-	char			*name;
+	const char		*name;
 	sa_family_t		family;
 	int			(*seq_show) (struct seq_file *m, void *v);
 	struct file_operations	*seq_fops;
diff --git a/include/net/tipc/tipc_bearer.h b/include/net/tipc/tipc_bearer.h
index 2151a80..6242557 100644
--- a/include/net/tipc/tipc_bearer.h
+++ b/include/net/tipc/tipc_bearer.h
@@ -101,7 +101,7 @@ struct tipc_bearer {
 
 
 int  tipc_register_media(u32 media_type,
-			 char *media_name, 
+			 const char *media_name, 
 			 int (*enable)(struct tipc_bearer *), 
 			 void (*disable)(struct tipc_bearer *), 
 			 int (*send_msg)(struct sk_buff *, 
diff --git a/include/net/udp.h b/include/net/udp.h
index 98755eb..10e6e53 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -152,7 +152,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 /* /proc */
 struct udp_seq_afinfo {
 	struct module		*owner;
-	char			*name;
+	const char		*name;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
 	int 			(*seq_show) (struct seq_file *m, void *v);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index a5f80bf..61c928b 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -273,7 +273,7 @@ extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
 struct xfrm_type
 {
-	char			*description;
+	const char		*description;
 	struct module		*owner;
 	__u8			proto;
 	__u8			flags;
@@ -403,7 +403,7 @@ struct xfrm_migrate {
 struct xfrm_mgr
 {
 	struct list_head	list;
-	char			*id;
+	const char		*id;
 	int			(*notify)(struct xfrm_state *x, struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
@@ -884,8 +884,8 @@ struct xfrm_algo_comp_info {
 };
 
 struct xfrm_algo_desc {
-	char *name;
-	char *compat;
+	const char *name;
+	const char *compat;
 	u8 available:1;
 	union {
 		struct xfrm_algo_auth_info auth;
diff --git a/net/9p/conv.c b/net/9p/conv.c
index f2a041c..cfec713 100644
--- a/net/9p/conv.c
+++ b/net/9p/conv.c
@@ -434,7 +434,7 @@ static inline void p9_put_int64(struct cbuf *bufp, u64 val, u64 * p)
 }
 
 static void
-p9_put_str(struct cbuf *bufp, char *data, struct p9_str *str)
+p9_put_str(struct cbuf *bufp, const char *data, struct p9_str *str)
 {
 	int len;
 	char *s;
@@ -523,7 +523,7 @@ void p9_set_tag(struct p9_fcall *fc, u16 tag)
 }
 EXPORT_SYMBOL(p9_set_tag);
 
-struct p9_fcall *p9_create_tversion(u32 msize, char *version)
+struct p9_fcall *p9_create_tversion(u32 msize, const char *version)
 {
 	int size;
 	struct p9_fcall *fc;
diff --git a/net/9p/error.c b/net/9p/error.c
index ab2458b..5483a99 100644
--- a/net/9p/error.c
+++ b/net/9p/error.c
@@ -34,7 +34,7 @@
 #include <net/9p/9p.h>
 
 struct errormap {
-	char *name;
+	const char *name;
 	int val;
 
 	int namelen;
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 2770fb4..a67bdb3 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -972,9 +972,9 @@ static int lecd_attach(struct atm_vcc *vcc, int arg)
 }
 
 #ifdef CONFIG_PROC_FS
-static char *lec_arp_get_status_string(unsigned char status)
+static const char *lec_arp_get_status_string(unsigned char status)
 {
-	static char *lec_arp_status_string[] = {
+	static const char *lec_arp_status_string[] = {
 		"ESI_UNKNOWN       ",
 		"ESI_ARP_PENDING   ",
 		"ESI_VC_PENDING    ",
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 99fc1fe..d8b429d 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -456,7 +456,7 @@ void atm_proc_dev_deregister(struct atm_dev *dev)
 }
 
 static struct atm_proc_entry {
-	char *name;
+	const char *name;
 	const struct file_operations *proc_fops;
 	struct proc_dir_entry *dirent;
 } atm_proc_ents[] = {
diff --git a/net/ax25/ax25_addr.c b/net/ax25/ax25_addr.c
index 7e7964d..b9a0f8c 100644
--- a/net/ax25/ax25_addr.c
+++ b/net/ax25/ax25_addr.c
@@ -47,7 +47,7 @@ EXPORT_SYMBOL(null_ax25_address);
 /*
  *	ax25 -> ascii conversion
  */
-char *ax2asc(char *buf, const ax25_address *a)
+const char *ax2asc(char *buf, const ax25_address *a)
 {
 	char c, *s;
 	int n;
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 3e9d5bb..f76c791 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -516,7 +516,7 @@ static u16 cmtp_send_message(struct capi_ctr *ctrl, struct sk_buff *skb)
 	return CAPI_NOERROR;
 }
 
-static char *cmtp_procinfo(struct capi_ctr *ctrl)
+static const char *cmtp_procinfo(struct capi_ctr *ctrl)
 {
 	return "CAPI Message Transport Protocol";
 }
diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 2583540..eb93bfc 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -13,7 +13,7 @@
 #define BT_DBG(D...)
 #endif
 
-static inline char *typetostr(int type)
+static inline const char *typetostr(int type)
 {
 	switch (type) {
 	case HCI_VIRTUAL:
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 1ea2f86..4d578e7 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -122,7 +122,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
 static void br_stp_start(struct net_bridge *br)
 {
 	int r;
-	char *argv[] = { BR_STP_PROG, br->dev->name, "start", NULL };
+	const char *argv[] = { BR_STP_PROG, br->dev->name, "start", NULL };
 	char *envp[] = { NULL };
 
 	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
@@ -144,7 +144,7 @@ static void br_stp_start(struct net_bridge *br)
 static void br_stp_stop(struct net_bridge *br)
 {
 	int r;
-	char *argv[] = { BR_STP_PROG, br->dev->name, "stop", NULL };
+	const char *argv[] = { BR_STP_PROG, br->dev->name, "stop", NULL };
 	char *envp[] = { NULL };
 
 	if (br->stp_enabled == BR_USER_STP) {
diff --git a/net/core/dev.c b/net/core/dev.c
index 6cc8a70..cf167ab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2458,14 +2458,14 @@ static void ptype_seq_decode(struct seq_file *seq, void *sym)
 #ifdef CONFIG_KALLSYMS
 	unsigned long offset = 0, symsize;
 	const char *symname;
-	char *modname;
+	const char *modname;
 	char namebuf[128];
 
 	symname = kallsyms_lookup((unsigned long)sym, &symsize, &offset,
 				  &modname, namebuf);
 
 	if (symname) {
-		char *delim = ":";
+		const char *delim = ":";
 
 		if (!modname)
 			modname = delim = "";
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca2a153..6977937 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2637,7 +2637,7 @@ static struct neigh_sysctl_table {
 };
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
-			  int p_id, int pdev_id, char *p_name,
+			  int p_id, int pdev_id, const char *p_name,
 			  proc_handler *handler, ctl_handler *strategy)
 {
 	struct neigh_sysctl_table *t = kmemdup(&neigh_sysctl_template,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index e91c2b9..60c25ec 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -56,7 +56,7 @@ static struct dccp_rx_hist *ccid3_rx_hist;
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
-	static char *ccid3_state_names[] = {
+	static const char *ccid3_state_names[] = {
 	[TFRC_SSTATE_NO_SENT]  = "NO_SENT",
 	[TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
 	[TFRC_SSTATE_FBACK]    = "FBACK",
@@ -692,7 +692,7 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 {
-	static char *ccid3_rx_state_names[] = {
+	static const char *ccid3_rx_state_names[] = {
 	[TFRC_RSTATE_NO_DATA] = "NO_DATA",
 	[TFRC_RSTATE_DATA]    = "DATA",
 	[TFRC_RSTATE_TERM]    = "TERM",
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 04b59ec..644922f 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -132,7 +132,7 @@ EXPORT_SYMBOL_GPL(dccp_packet_name);
 
 const char *dccp_state_name(const int state)
 {
-	static char *dccp_state_names[] = {
+	static const char *dccp_state_names[] = {
 	[DCCP_OPEN]	  = "OPEN",
 	[DCCP_REQUESTING] = "REQUESTING",
 	[DCCP_PARTOPEN]	  = "PARTOPEN",
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index ed76d4a..da1d4e6 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2220,7 +2220,7 @@ static void dn_printable_object(struct sockaddr_dn *dn, unsigned char *buf)
 	}
 }
 
-static char *dn_state2asc(unsigned char state)
+static const char *dn_state2asc(unsigned char state)
 {
 	switch(state) {
 		case DN_O:
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index fa6604f..cbe8976 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1377,7 +1377,7 @@ static void dn_dev_seq_stop(struct seq_file *seq, void *v)
 	read_unlock(&dev_base_lock);
 }
 
-static char *dn_type2asc(char type)
+static const char *dn_type2asc(char type)
 {
 	switch(type) {
 		case DN_DEV_BCAST:
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 4074a6e..2dc4cf9 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -81,7 +81,7 @@ extern int decnet_log_martians;
 static void dn_log_martian(struct sk_buff *skb, const char *msg)
 {
 	if (decnet_log_martians && net_ratelimit()) {
-		char *devname = skb->dev ? skb->dev->name : "???";
+		const char *devname = skb->dev ? skb->dev->name : "???";
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
 		printk(KERN_INFO "DECnet: Martian packet (%s) dev=%s src=0x%04hx dst=0x%04hx srcport=0x%04hx dstport=0x%04hx\n", msg, devname, dn_ntohs(cb->src), dn_ntohs(cb->dst), dn_ntohs(cb->src_port), dn_ntohs(cb->dst_port));
 	}
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index a4a6209..b4774af 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -474,7 +474,7 @@ static int dn_route_rx_packet(struct sk_buff *skb)
 		return dst_input(skb);
 
 	if (decnet_debug_level & 4) {
-		char *devname = skb->dev ? skb->dev->name : "???";
+		const char *devname = skb->dev ? skb->dev->name : "???";
 		struct dn_skb_cb *cb = DN_SKB_CB(skb);
 		printk(KERN_DEBUG
 			"DECnet: dn_route_rx_packet: rt_flags=0x%02x dev=%s len=%d src=0x%04hx dst=0x%04hx err=%d type=%d\n",
diff --git a/net/ieee80211/softmac/ieee80211softmac_event.c b/net/ieee80211/softmac/ieee80211softmac_event.c
index b3e33a4..4026ec1 100644
--- a/net/ieee80211/softmac/ieee80211softmac_event.c
+++ b/net/ieee80211/softmac/ieee80211softmac_event.c
@@ -59,7 +59,7 @@
  * whenever the event context matches.
  */
 
-static char *event_descriptions[IEEE80211SOFTMAC_EVENT_LAST+1] = {
+static const char *event_descriptions[IEEE80211SOFTMAC_EVENT_LAST+1] = {
 	NULL, /* scan finished */
 	NULL, /* associated */
 	"associating failed",
@@ -137,7 +137,7 @@ ieee80211softmac_call_events_locked(struct ieee80211softmac_device *mac, int eve
 	if (event >= 0) {
 		union iwreq_data wrqu;
 		int we_event;
-		char *msg = NULL;
+		const char *msg = NULL;
 
 		memset(&wrqu, '\0', sizeof (union iwreq_data));
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 9ab9d53..c8a18c3 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1258,7 +1258,7 @@ void __init arp_init(void)
 /*
  *	ax25 -> ASCII conversion
  */
-static char *ax2asc2(ax25_address *a, char *buf)
+static const char *ax2asc2(ax25_address *a, char *buf)
 {
 	char c, *s;
 	int n;
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5b77bda..238da8a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1496,7 +1496,7 @@ static void devinet_sysctl_register(struct in_device *in_dev,
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
 	struct devinet_sysctl_table *t = kmemdup(&devinet_sysctl, sizeof(*t),
 						 GFP_KERNEL);
-	char *dev_name = NULL;
+	const char *dev_name = NULL;
 
 	if (!t)
 		return;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a646409..a496db3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2377,7 +2377,7 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
 	else {
 		struct ip_mc_list *im = (struct ip_mc_list *)v;
 		struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
-		char   *querier;
+		const char *querier;
 #ifdef CONFIG_IP_MULTICAST
 		querier = IGMP_V1_SEEN(state->in_dev) ? "V1" :
 			  IGMP_V2_SEEN(state->in_dev) ? "V2" :
diff --git a/net/ipv4/ipvs/ip_vs_proto.c b/net/ipv4/ipvs/ip_vs_proto.c
index e844ddb..fc40def 100644
--- a/net/ipv4/ipvs/ip_vs_proto.c
+++ b/net/ipv4/ipvs/ip_vs_proto.c
@@ -126,7 +126,7 @@ ip_vs_create_timeout_table(int *table, int size)
  *	Set timeout value for state specified by name
  */
 int
-ip_vs_set_state_timeout(int *table, int num, char **names, char *name, int to)
+ip_vs_set_state_timeout(int *table, int num, const char **names, char *name, int to)
 {
 	int i;
 
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index e65577a..6ddb0f2 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -274,7 +274,7 @@ static int tcp_timeouts[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_LAST]		=	2*HZ,
 };
 
-static char * tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
+static const char * tcp_state_name_table[IP_VS_TCP_S_LAST+1] = {
 	[IP_VS_TCP_S_NONE]		=	"NONE",
 	[IP_VS_TCP_S_ESTABLISHED]	=	"ESTABLISHED",
 	[IP_VS_TCP_S_SYN_SENT]		=	"SYN_SENT",
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 8ee5fe6..ecf8c40 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -369,7 +369,7 @@ static int udp_timeouts[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_LAST]		=	2*HZ,
 };
 
-static char * udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
+static const char * udp_state_name_table[IP_VS_UDP_S_LAST+1] = {
 	[IP_VS_UDP_S_NORMAL]		=	"UDP",
 	[IP_VS_UDP_S_LAST]		=	"BUG!",
 };
diff --git a/net/ipv4/netfilter/nf_nat_snmp_basic.c b/net/ipv4/netfilter/nf_nat_snmp_basic.c
index 6bfcd3a..af211ea 100644
--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c
@@ -1079,7 +1079,7 @@ static int snmp_parse_mangle(unsigned char *msg,
 	if (cls != ASN1_CTX || con != ASN1_CON)
 		return 0;
 	if (debug > 1) {
-		unsigned char *pdus[] = {
+		const unsigned char *pdus[] = {
 			[SNMP_PDU_GET] = "get",
 			[SNMP_PDU_NEXT] = "get-next",
 			[SNMP_PDU_RESPONSE] = "response",
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 91ef3be..230a39d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4095,7 +4095,7 @@ static void addrconf_sysctl_register(struct inet6_dev *idev, struct ipv6_devconf
 	int i;
 	struct net_device *dev = idev ? idev->dev : NULL;
 	struct addrconf_sysctl_table *t;
-	char *dev_name = NULL;
+	const char *dev_name = NULL;
 
 	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 8400525..ca525c1 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1277,7 +1277,7 @@ __be16 ipx_cksum(struct ipxhdr *packet, int length)
 
 const char *ipx_frame_name(__be16 frame)
 {
-	char* rc = "None";
+	const char* rc = "None";
 
 	switch (ntohs(frame)) {
 	case ETH_P_IPX:		rc = "EtherII";	break;
diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 4c670cf..50df118 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -538,7 +538,7 @@ static int irda_open_lsap(struct irda_sock *self, int pid)
  * Note that in some case, the query fail even before we go to sleep,
  * creating some races...
  */
-static int irda_find_lsap_sel(struct irda_sock *self, char *name)
+static int irda_find_lsap_sel(struct irda_sock *self, const char *name)
 {
 	IRDA_DEBUG(2, "%s(%p, %s)\n", __FUNCTION__, self, name);
 
diff --git a/net/irda/ircomm/ircomm_event.c b/net/irda/ircomm/ircomm_event.c
index 8ba4e59..5de6f56 100644
--- a/net/irda/ircomm/ircomm_event.c
+++ b/net/irda/ircomm/ircomm_event.c
@@ -49,7 +49,7 @@ static int ircomm_state_waitr(struct ircomm_cb *self, IRCOMM_EVENT event,
 static int ircomm_state_conn(struct ircomm_cb *self, IRCOMM_EVENT event,
 			     struct sk_buff *skb, struct ircomm_info *info);
 
-char *ircomm_state[] = {
+const char *ircomm_state[] = {
 	"IRCOMM_IDLE",
 	"IRCOMM_WAITI",
 	"IRCOMM_WAITR",
@@ -57,7 +57,7 @@ char *ircomm_state[] = {
 };
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *ircomm_event[] = {
+static const char *ircomm_event[] = {
 	"IRCOMM_CONNECT_REQUEST",
 	"IRCOMM_CONNECT_RESPONSE",
 	"IRCOMM_TTP_CONNECT_INDICATION",
diff --git a/net/irda/ircomm/ircomm_tty_attach.c b/net/irda/ircomm/ircomm_tty_attach.c
index 824309d..d55b299 100644
--- a/net/irda/ircomm/ircomm_tty_attach.c
+++ b/net/irda/ircomm/ircomm_tty_attach.c
@@ -80,7 +80,7 @@ static int ircomm_tty_state_ready(struct ircomm_tty_cb *self,
 				  struct sk_buff *skb,
 				  struct ircomm_tty_info *info);
 
-char *ircomm_tty_state[] = {
+const char *ircomm_tty_state[] = {
 	"IRCOMM_TTY_IDLE",
 	"IRCOMM_TTY_SEARCH",
 	"IRCOMM_TTY_QUERY_PARAMETERS",
@@ -91,7 +91,7 @@ char *ircomm_tty_state[] = {
 };
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *ircomm_tty_event[] = {
+static const char *ircomm_tty_event[] = {
 	"IRCOMM_TTY_ATTACH_CABLE",
 	"IRCOMM_TTY_DETACH_CABLE",
 	"IRCOMM_TTY_DATA_REQUEST",
diff --git a/net/irda/iriap.c b/net/irda/iriap.c
index ee3889f..f104da2 100644
--- a/net/irda/iriap.c
+++ b/net/irda/iriap.c
@@ -369,7 +369,7 @@ static void iriap_disconnect_request(struct iriap_cb *self)
  */
 int iriap_getvaluebyclass_request(struct iriap_cb *self,
 				  __u32 saddr, __u32 daddr,
-				  char *name, char *attr)
+				  const char *name, const char *attr)
 {
 	struct sk_buff *tx_skb;
 	int name_len, attr_len, skb_len;
diff --git a/net/irda/irias_object.c b/net/irda/irias_object.c
index cf30245..38b8709 100644
--- a/net/irda/irias_object.c
+++ b/net/irda/irias_object.c
@@ -43,7 +43,7 @@ struct ias_value irias_missing = { IAS_MISSING, 0, 0, 0, {0}};
  *    Create a new IAS object
  *
  */
-struct ias_object *irias_new_object( char *name, int id)
+struct ias_object *irias_new_object(const char *name, int id)
 {
 	struct ias_object *obj;
 
@@ -200,7 +200,7 @@ EXPORT_SYMBOL(irias_insert_object);
  *    Find object with given name
  *
  */
-struct ias_object *irias_find_object(char *name)
+struct ias_object *irias_find_object(const char *name)
 {
 	IRDA_ASSERT(name != NULL, return NULL;);
 
@@ -215,7 +215,7 @@ EXPORT_SYMBOL(irias_find_object);
  *    Find named attribute in object
  *
  */
-struct ias_attrib *irias_find_attrib(struct ias_object *obj, char *name)
+struct ias_attrib *irias_find_attrib(struct ias_object *obj, const char *name)
 {
 	struct ias_attrib *attrib;
 
@@ -258,7 +258,8 @@ static void irias_add_attrib(struct ias_object *obj, struct ias_attrib *attrib,
  *    Change the value of an objects attribute.
  *
  */
-int irias_object_change_attribute(char *obj_name, char *attrib_name,
+int irias_object_change_attribute(const char *obj_name,
+				  const char *attrib_name,
 				  struct ias_value *new_value)
 {
 	struct ias_object *obj;
@@ -310,8 +311,8 @@ EXPORT_SYMBOL(irias_object_change_attribute);
  *    Add an integer attribute to an LM-IAS object
  *
  */
-void irias_add_integer_attrib(struct ias_object *obj, char *name, int value,
-			      int owner)
+void irias_add_integer_attrib(struct ias_object *obj, const char *name,
+			      int value, int owner)
 {
 	struct ias_attrib *attrib;
 
@@ -352,8 +353,8 @@ EXPORT_SYMBOL(irias_add_integer_attrib);
  *
  */
 
-void irias_add_octseq_attrib(struct ias_object *obj, char *name, __u8 *octets,
-			     int len, int owner)
+void irias_add_octseq_attrib(struct ias_object *obj, const char *name,
+			     __u8 *octets, int len, int owner)
 {
 	struct ias_attrib *attrib;
 
@@ -394,8 +395,8 @@ EXPORT_SYMBOL(irias_add_octseq_attrib);
  *    Add a string attribute to an LM-IAS object
  *
  */
-void irias_add_string_attrib(struct ias_object *obj, char *name, char *value,
-			     int owner)
+void irias_add_string_attrib(struct ias_object *obj, const char *name,
+			     const char *value, int owner)
 {
 	struct ias_attrib *attrib;
 
@@ -461,7 +462,7 @@ EXPORT_SYMBOL(irias_new_integer_value);
  *
  * Per IrLMP 1.1, 4.3.3.2, strings are up to 256 chars - Jean II
  */
-struct ias_value *irias_new_string_value(char *string)
+struct ias_value *irias_new_string_value(const char *string)
 {
 	struct ias_value *value;
 
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index f5778ef..2650433 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -106,9 +106,9 @@ extern struct proc_dir_entry *proc_irda;
 
 static struct irlan_cb *irlan_open(__u32 saddr, __u32 daddr);
 static void __irlan_close(struct irlan_cb *self);
-static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
-				__u8 value_byte, __u16 value_short,
-				__u8 *value_array, __u16 value_len);
+static int __irlan_insert_param(struct sk_buff *skb, const char *param,
+				int type, __u8 value_byte, __u16 value_short,
+				const __u8 *value_array, __u16 value_len);
 static void irlan_open_unicast_addr(struct irlan_cb *self);
 static void irlan_get_unicast_addr(struct irlan_cb *self);
 void irlan_close_tsaps(struct irlan_cb *self);
@@ -960,12 +960,12 @@ void irlan_get_media_char(struct irlan_cb *self)
  *    Insert byte parameter into frame
  *
  */
-int irlan_insert_byte_param(struct sk_buff *skb, char *param, __u8 value)
+int irlan_insert_byte_param(struct sk_buff *skb, const char *param, __u8 value)
 {
 	return __irlan_insert_param(skb, param, IRLAN_BYTE, value, 0, NULL, 0);
 }
 
-int irlan_insert_short_param(struct sk_buff *skb, char *param, __u16 value)
+int irlan_insert_short_param(struct sk_buff *skb, const char *param, __u16 value)
 {
 	return __irlan_insert_param(skb, param, IRLAN_SHORT, 0, value, NULL, 0);
 }
@@ -976,7 +976,8 @@ int irlan_insert_short_param(struct sk_buff *skb, char *param, __u16 value)
  *    Insert string parameter into frame
  *
  */
-int irlan_insert_string_param(struct sk_buff *skb, char *param, char *string)
+int irlan_insert_string_param(struct sk_buff *skb, const char *param,
+			      const char *string)
 {
 	int string_len = strlen(string);
 
@@ -990,8 +991,8 @@ int irlan_insert_string_param(struct sk_buff *skb, char *param, char *string)
  *    Insert array parameter into frame
  *
  */
-int irlan_insert_array_param(struct sk_buff *skb, char *name, __u8 *array,
-			     __u16 array_len)
+int irlan_insert_array_param(struct sk_buff *skb, const char *name,
+			     __u8 *array, __u16 array_len)
 {
 	return __irlan_insert_param(skb, name, IRLAN_ARRAY, 0, 0, array,
 				    array_len);
@@ -1006,9 +1007,9 @@ int irlan_insert_array_param(struct sk_buff *skb, char *name, __u8 *array,
  *    | Name Length[1] | Param Name[1..255] | Val Length[2] | Value[0..1016]|
  *    -----------------------------------------------------------------------
  */
-static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
-				__u8 value_byte, __u16 value_short,
-				__u8 *value_array, __u16 value_len)
+static int __irlan_insert_param(struct sk_buff *skb, const char *param,
+				int type, __u8 value_byte, __u16 value_short,
+				const __u8 *value_array, __u16 value_len)
 {
 	__u8 *frame;
 	__u8 param_len;
diff --git a/net/irda/irlan/irlan_event.c b/net/irda/irlan/irlan_event.c
index 623e0fd..2d5d4c5 100644
--- a/net/irda/irlan/irlan_event.c
+++ b/net/irda/irlan/irlan_event.c
@@ -24,7 +24,7 @@
 
 #include <net/irda/irlan_event.h>
 
-char *irlan_state[] = {
+const char *irlan_state[] = {
 	"IRLAN_IDLE",
 	"IRLAN_QUERY",
 	"IRLAN_CONN",
diff --git a/net/irda/irlap.c b/net/irda/irlap.c
index 3d76aaf..587f249 100644
--- a/net/irda/irlap.c
+++ b/net/irda/irlap.c
@@ -63,7 +63,7 @@ static void irlap_init_qos_capabilities(struct irlap_cb *self,
 					struct qos_info *qos_user);
 
 #ifdef CONFIG_IRDA_DEBUG
-static char *lap_reasons[] = {
+static const char *lap_reasons[] = {
 	"ERROR, NOT USED",
 	"LAP_DISC_INDICATION",
 	"LAP_NO_RESPONSE",
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index a4f1439..f06c52f 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -1730,7 +1730,7 @@ irnet_proc_read(char *	buf,
 		int	len)
 {
   irnet_socket *	self;
-  char *		state;
+  const char *		state;
   int			i = 0;
 
   len = 0;
diff --git a/net/irda/parameters.c b/net/irda/parameters.c
index 2627dad..0486a8a 100644
--- a/net/irda/parameters.c
+++ b/net/irda/parameters.c
@@ -51,7 +51,7 @@ static int irda_insert_integer(void *self, __u8 *buf, int len, __u8 pi,
 static int irda_insert_no_value(void *self, __u8 *buf, int len, __u8 pi,
 				PV_TYPE type, PI_HANDLER func);
 
-static int irda_param_unpack(__u8 *buf, char *fmt, ...);
+static int irda_param_unpack(__u8 *buf, const char *fmt, ...);
 
 /* Parameter value call table. Must match PV_TYPE */
 static PV_HANDLER pv_extract_table[] = {
@@ -362,11 +362,11 @@ static int irda_extract_octseq(void *self, __u8 *buf, int len, __u8 pi,
  *        's' = string
  *
  */
-int irda_param_pack(__u8 *buf, char *fmt, ...)
+int irda_param_pack(__u8 *buf, const char *fmt, ...)
 {
 	irda_pv_t arg;
 	va_list args;
-	char *p;
+	const char *p;
 	int n = 0;
 
 	va_start(args, fmt);
@@ -405,11 +405,11 @@ EXPORT_SYMBOL(irda_param_pack);
 /*
  * Function irda_param_unpack (skb, fmt, ...)
  */
-static int irda_param_unpack(__u8 *buf, char *fmt, ...)
+static int irda_param_unpack(__u8 *buf, const char *fmt, ...)
 {
 	irda_pv_t arg;
 	va_list args;
-	char *p;
+	const char *p;
 	int n = 0;
 
 	va_start(args, fmt);
diff --git a/net/llc/llc_proc.c b/net/llc/llc_proc.c
index 49be6c9..700f229 100644
--- a/net/llc/llc_proc.c
+++ b/net/llc/llc_proc.c
@@ -141,7 +141,7 @@ out:
 	return 0;
 }
 
-static char *llc_conn_state_names[] = {
+static const char *llc_conn_state_names[] = {
 	[LLC_CONN_STATE_ADM] =        "adm",
 	[LLC_CONN_STATE_SETUP] =      "setup",
 	[LLC_CONN_STATE_NORMAL] =     "normal",
diff --git a/net/mac80211/debugfs_key.c b/net/mac80211/debugfs_key.c
index 7d56dc9..dd99896 100644
--- a/net/mac80211/debugfs_key.c
+++ b/net/mac80211/debugfs_key.c
@@ -46,7 +46,7 @@ static ssize_t key_algorithm_read(struct file *file,
 				  char __user *userbuf,
 				  size_t count, loff_t *ppos)
 {
-	char *alg;
+	const char *alg;
 	struct ieee80211_key *key = file->private_data;
 
 	switch (key->alg) {
diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index e42ab23..195768b 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -53,7 +53,7 @@ enum amanda_strings {
 };
 
 static struct {
-	char			*string;
+	const char		*string;
 	size_t			len;
 	struct ts_config	*ts;
 } search[] __read_mostly = {
diff --git a/net/rose/rose_subr.c b/net/rose/rose_subr.c
index b05108f..3ae46d1 100644
--- a/net/rose/rose_subr.c
+++ b/net/rose/rose_subr.c
@@ -398,7 +398,7 @@ int rose_parse_facilities(unsigned char *p,
 static int rose_create_facilities(unsigned char *buffer, struct rose_sock *rose)
 {
 	unsigned char *p = buffer + 1;
-	char *callsign;
+	const char *callsign;
 	char buf[11];
 	int len, nb;
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index feef366..fc1585a 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -457,7 +457,8 @@ errout:
 }
 
 struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
-				    char *name, int ovr, int bind, int *err)
+				    const char *name, int ovr, int bind, 
+				    int *err)
 {
 	struct tc_action *a;
 	struct tc_action_ops *a_o;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ee88f2e..97ed3b8 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -105,7 +105,7 @@ static int sctp_do_bind(struct sock *, union sctp_addr *, int);
 static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
-static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
+static const char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;
 
 extern struct kmem_cache *sctp_bucket_cachep;
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index bfb6a29..4958a7f 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -130,8 +130,8 @@ checksummer(struct scatterlist *sg, void *data)
 
 /* checksum the plaintext data and hdrlen bytes of the token header */
 s32
-make_checksum(char *cksumname, char *header, int hdrlen, struct xdr_buf *body,
-		   int body_offset, struct xdr_netobj *cksum)
+make_checksum(const char *cksumname, char *header, int hdrlen,
+	      struct xdr_buf *body, int body_offset, struct xdr_netobj *cksum)
 {
 	struct hash_desc                desc; /* XXX add to ctx? */
 	struct scatterlist              sg[1];
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 9843eac..8786cde 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -82,7 +82,7 @@ get_key(const void *p, const void *end, struct crypto_blkcipher **res)
 {
 	struct xdr_netobj	key;
 	int			alg;
-	char			*alg_name;
+	const char		*alg_name;
 
 	p = simple_get_bytes(p, end, &alg, sizeof(alg));
 	if (IS_ERR(p))
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 61801a0..66b59da 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -66,9 +66,9 @@ gss_mech_free(struct gss_api_mech *gm)
 }
 
 static inline char *
-make_auth_domain_name(char *name)
+make_auth_domain_name(const char *name)
 {
-	static char	*prefix = "gss/";
+	static const char *prefix = "gss/";
 	char		*new;
 
 	new = kmalloc(strlen(name) + strlen(prefix) + 1, GFP_KERNEL);
diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
index d158635..2102a6e 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_seal.c
@@ -142,7 +142,7 @@ make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
 		    unsigned int hdrlen, struct xdr_buf *body,
 		    unsigned int body_offset, struct xdr_netobj *cksum)
 {
-	char				*cksumname;
+	const char			*cksumname;
 	struct hash_desc		desc; /* XXX add to ctx? */
 	struct scatterlist		sg[1];
 	int err;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 52429b1..2ace90f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -121,7 +121,7 @@ rpc_setup_pipedir(struct rpc_clnt *clnt, char *dir_name)
 	}
 }
 
-static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, struct rpc_program *program, u32 vers, rpc_authflavor_t flavor)
+static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, const char *servname, struct rpc_program *program, u32 vers, rpc_authflavor_t flavor)
 {
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
@@ -650,7 +650,7 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr);
  * @format: address format
  *
  */
-char *rpc_peeraddr2str(struct rpc_clnt *clnt, enum rpc_display_format_t format)
+const char *rpc_peeraddr2str(struct rpc_clnt *clnt, enum rpc_display_format_t format)
 {
 	struct rpc_xprt *xprt = clnt->cl_xprt;
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 650af06..dff06f4 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -392,7 +392,7 @@ enum {
  * Description of fs contents.
  */
 struct rpc_filelist {
-	char *name;
+	const char *name;
 	const struct file_operations *i_fop;
 	int mode;
 };
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index d1740db..2dcc503 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -129,9 +129,9 @@ struct rpcbind_args {
 	u32			r_vers;
 	u32			r_prot;
 	unsigned short		r_port;
-	char *			r_netid;
+	const char *		r_netid;
 	char			r_addr[RPCB_MAXADDRLEN];
-	char *			r_owner;
+	const char *		r_owner;
 };
 
 static struct rpc_procinfo rpcb_procedures2[];
@@ -175,8 +175,9 @@ static void rpcb_wake_rpcbind_waiters(struct rpc_xprt *xprt, int status)
 	rpc_wake_up_status(&xprt->binding, status);
 }
 
-static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-					int proto, int version, int privileged)
+static struct rpc_clnt *rpcb_create(const char *hostname, 
+				    struct sockaddr *srvaddr, int proto,
+				    int version, int privileged)
 {
 	struct rpc_create_args args = {
 		.protocol	= proto,
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 4114794..cad05a8 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -164,7 +164,7 @@ static void ip_map_request(struct cache_detail *cd,
 	(*bpp)[-1] = '\n';
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr);
+static struct ip_map *ip_map_lookup(const char *class, struct in_addr addr);
 static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -239,7 +239,7 @@ static int ip_map_show(struct seq_file *m,
 {
 	struct ip_map *im;
 	struct in_addr addr;
-	char *dom = "-no-domain-";
+	const char *dom = "-no-domain-";
 
 	if (h == NULL) {
 		seq_puts(m, "#class IP domain\n");
@@ -280,7 +280,7 @@ struct cache_detail ip_map_cache = {
 	.alloc		= ip_map_alloc,
 };
 
-static struct ip_map *ip_map_lookup(char *class, struct in_addr addr)
+static struct ip_map *ip_map_lookup(const char *class, struct in_addr addr)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4ae7eed..43b3405 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -186,7 +186,7 @@ static ctl_table sunrpc_table[] = {
 #endif
 
 #ifdef RPC_DEBUG_DATA
-static void xs_pktdump(char *msg, u32 *packet, unsigned int count)
+static void xs_pktdump(const char *msg, u32 *packet, unsigned int count)
 {
 	u8 *buf = (u8 *) packet;
 	int j;
@@ -204,7 +204,7 @@ static void xs_pktdump(char *msg, u32 *packet, unsigned int count)
 	dprintk("\n");
 }
 #else
-static inline void xs_pktdump(char *msg, u32 *packet, unsigned int count)
+static inline void xs_pktdump(const char *msg, u32 *packet, unsigned int count)
 {
 	/* NOP */
 }
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 271a375..9973378 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -89,7 +89,7 @@ static struct media *media_find(const char *name)
  */
 
 int  tipc_register_media(u32 media_type,
-			 char *name,
+			 const char *name,
 			 int (*enable)(struct tipc_bearer *),
 			 void (*disable)(struct tipc_bearer *),
 			 int (*send_msg)(struct sk_buff *,
diff --git a/net/tipc/config.c b/net/tipc/config.c
index c71337a..6613d19 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -87,7 +87,7 @@ struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
 }
 
 int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size)
+			const void *tlv_data, int tlv_data_size)
 {
 	struct tlv_desc *tlv = (struct tlv_desc *)skb_tail_pointer(buf);
 	int new_tlv_space = TLV_SPACE(tlv_data_size);
@@ -118,7 +118,7 @@ struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value)
 	return buf;
 }
 
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string)
+struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, const char *string)
 {
 	struct sk_buff *buf;
 	int string_len = strlen(string) + 1;
diff --git a/net/tipc/config.h b/net/tipc/config.h
index 5cd7cc5..09618d5 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -44,9 +44,9 @@
 
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size);
 int tipc_cfg_append_tlv(struct sk_buff *buf, int tlv_type,
-			void *tlv_data, int tlv_data_size);
+			const void *tlv_data, int tlv_data_size);
 struct sk_buff *tipc_cfg_reply_unsigned_type(u16 tlv_type, u32 value);
-struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, char *string);
+struct sk_buff *tipc_cfg_reply_string_type(u16 tlv_type, const char *string);
 
 static inline struct sk_buff *tipc_cfg_reply_none(void)
 {
@@ -58,12 +58,12 @@ static inline struct sk_buff *tipc_cfg_reply_unsigned(u32 value)
 	return tipc_cfg_reply_unsigned_type(TIPC_TLV_UNSIGNED, value);
 }
 
-static inline struct sk_buff *tipc_cfg_reply_error_string(char *string)
+static inline struct sk_buff *tipc_cfg_reply_error_string(const char *string)
 {
 	return tipc_cfg_reply_string_type(TIPC_TLV_ERROR_STRING, string);
 }
 
-static inline struct sk_buff *tipc_cfg_reply_ultra_string(char *string)
+static inline struct sk_buff *tipc_cfg_reply_ultra_string(const char *string)
 {
 	return tipc_cfg_reply_string_type(TIPC_TLV_ULTRA_STRING, string);
 }
diff --git a/net/tipc/dbg.c b/net/tipc/dbg.c
index e809d2a..aa2d8d1 100644
--- a/net/tipc/dbg.c
+++ b/net/tipc/dbg.c
@@ -132,7 +132,7 @@ int tipc_printbuf_empty(struct print_buf *pb)
 
 int tipc_printbuf_validate(struct print_buf *pb)
 {
-	char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
+	const char *err = "\n\n*** PRINT BUFFER OVERFLOW ***\n\n";
 	char *cp_buf;
 	struct print_buf cb;
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1d674e0..c3ba2ed 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -3017,7 +3017,7 @@ static int tipc_link_stats(const char *name, char *buf, const u32 buf_size)
 	struct print_buf pb;
 	struct link *l_ptr;
 	struct node *node;
-	char *status;
+	const char *status;
 	u32 profile_total = 0;
 
 	if (!strcmp(name, tipc_bclink_name))
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index d8473ee..d27094d 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -858,7 +858,7 @@ static void subseq_list(struct sub_seq *sseq, struct print_buf *buf, u32 depth,
 			u32 index)
 {
 	char portIdStr[27];
-	char *scopeStr;
+	const char *scopeStr;
 	struct publication *publ = sseq->zone_list;
 
 	tipc_printf(buf, "%-10u %-10u ", sseq->lower, sseq->upper);
diff --git a/net/wireless/wext.c b/net/wireless/wext.c
index d6aaf65..d950cef 100644
--- a/net/wireless/wext.c
+++ b/net/wireless/wext.c
@@ -1187,7 +1187,7 @@ static void rtmsg_iwinfo(struct net_device *dev, char *event, int event_len)
 void wireless_send_event(struct net_device *	dev,
 			 unsigned int		cmd,
 			 union iwreq_data *	wrqu,
-			 char *			extra)
+			 const char *		extra)
 {
 	const struct iw_ioctl_description *	descr = NULL;
 	int extra_len = 0;
