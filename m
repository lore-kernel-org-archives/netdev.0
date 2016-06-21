From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Tue, 21 Jun 2016 18:18:36 +0200
Message-ID: <1466525921-15738-3-git-send-email-phil@nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46938 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbcFUQ1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 12:27:39 -0400
In-Reply-To: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This big patch was compiled by vimgrepping for memset calls and changing
to C99 initializer if applicable. One notable exception is the
initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
for older gcc versions (at least <=3.4.6).

Calls to memset for struct rtattr pointer fields for parse_rtattr*()
were just dropped since they are not needed.

The changes here allowed the compiler to discover some unused variables,
so get rid of them, too.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Dropped former changes to tc/tc_bpf.c as they are incompatible to older
  gcc versions (at least <=3.4.6).
---
 bridge/fdb.c     |  29 +++++++------
 bridge/link.c    |  16 +++----
 bridge/mdb.c     |  19 ++++-----
 bridge/vlan.c    |  19 ++++-----
 genl/ctrl.c      |  48 +++++++++------------
 ip/ip6tunnel.c   |  10 ++---
 ip/ipaddress.c   |  31 ++++++--------
 ip/ipaddrlabel.c |  23 +++++-----
 ip/iplink.c      |  67 ++++++++++++++---------------
 ip/iplink_can.c  |   4 +-
 ip/ipmaddr.c     |  27 +++++-------
 ip/ipmroute.c    |   8 +---
 ip/ipneigh.c     |  36 ++++++++--------
 ip/ipnetconf.c   |  12 +++---
 ip/ipnetns.c     |  45 ++++++++++---------
 ip/ipntable.c    |  27 +++++-------
 ip/iproute.c     |  85 ++++++++++++++++--------------------
 ip/iprule.c      |  26 +++++------
 ip/iptoken.c     |  21 ++++-----
 ip/iptunnel.c    |  31 ++++----------
 ip/ipxfrm.c      |  26 +++--------
 ip/link_gre.c    |  22 +++++-----
 ip/link_gre6.c   |  22 +++++-----
 ip/link_ip6tnl.c |  29 ++++++-------
 ip/link_iptnl.c  |  26 +++++------
 ip/link_vti.c    |  22 +++++-----
 ip/link_vti6.c   |  22 +++++-----
 ip/xfrm_policy.c | 110 ++++++++++++++++++++++-------------------------
 ip/xfrm_state.c  | 128 +++++++++++++++++++++++++++----------------------------
 lib/libnetlink.c |  74 ++++++++++++++------------------
 lib/ll_map.c     |   1 -
 misc/arpd.c      |  68 ++++++++++++++---------------
 misc/ss.c        |  41 ++++++++----------
 tc/e_bpf.c       |   7 +--
 tc/em_cmp.c      |   4 +-
 tc/em_ipset.c    |   4 +-
 tc/em_meta.c     |   4 +-
 tc/em_nbyte.c    |   4 +-
 tc/em_u32.c      |   4 +-
 tc/f_flow.c      |   3 --
 tc/f_flower.c    |   3 +-
 tc/f_fw.c        |   6 +--
 tc/f_route.c     |   3 --
 tc/f_rsvp.c      |   6 +--
 tc/f_u32.c       |  12 ++----
 tc/m_bpf.c       |   5 +--
 tc/m_csum.c      |   4 +-
 tc/m_ematch.c    |   4 +-
 tc/m_gact.c      |   5 +--
 tc/m_ife.c       |   5 +--
 tc/m_mirred.c    |   7 +--
 tc/m_nat.c       |   4 +-
 tc/m_pedit.c     |   8 +---
 tc/m_police.c    |   5 +--
 tc/q_atm.c       |   3 +-
 tc/q_cbq.c       |  22 +++-------
 tc/q_choke.c     |   4 +-
 tc/q_codel.c     |   3 +-
 tc/q_dsmark.c    |   1 -
 tc/q_fifo.c      |   4 +-
 tc/q_fq_codel.c  |   3 +-
 tc/q_hfsc.c      |  13 ++----
 tc/q_htb.c       |  15 +++----
 tc/q_netem.c     |  16 +++----
 tc/q_red.c       |   4 +-
 tc/q_sfb.c       |  17 ++++----
 tc/q_sfq.c       |   4 +-
 tc/q_tbf.c       |   4 +-
 tc/tc_bpf.c      |  47 +++++++++-----------
 tc/tc_class.c    |  33 ++++++--------
 tc/tc_exec.c     |   3 +-
 tc/tc_filter.c   |  35 ++++++---------
 tc/tc_qdisc.c    |  35 ++++++---------
 tc/tc_stab.c     |   4 +-
 tc/tc_util.c     |   3 +-
 75 files changed, 657 insertions(+), 898 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index be849f980a802..a59d6a9c13018 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -177,16 +177,15 @@ static int fdb_show(int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ifinfomsg	ifm;
 		char			buf[256];
-	} req;
+	} req = {
+		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+		.ifm.ifi_family = PF_BRIDGE
+	};
 
 	char *filter_dev = NULL;
 	char *br = NULL;
 	int msg_size = sizeof(struct ifinfomsg);
 
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.ifm.ifi_family = PF_BRIDGE;
-
 	while (argc > 0) {
 		if ((strcmp(*argv, "brport") == 0) || strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
@@ -247,7 +246,17 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ndmsg		ndm;
 		char			buf[256];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.ndm = {
+			.ndm_family = PF_BRIDGE,
+			.ndm_state = NUD_NOARP
+		}
+	};
 	char *addr = NULL;
 	char *d = NULL;
 	char abuf[ETH_ALEN];
@@ -259,14 +268,6 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	char *endptr;
 	short vid = -1;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.ndm.ndm_family = PF_BRIDGE;
-	req.ndm.ndm_state = NUD_NOARP;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/bridge/link.c b/bridge/link.c
index 353e1c3da45db..a9680e614804f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -255,7 +255,14 @@ static int brlink_modify(int argc, char **argv)
 		struct nlmsghdr  n;
 		struct ifinfomsg ifm;
 		char             buf[512];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_SETLINK
+		},
+		.ifm.ifi_family = PF_BRIDGE
+	};
 	char *d = NULL;
 	__s8 learning = -1;
 	__s8 learning_sync = -1;
@@ -271,13 +278,6 @@ static int brlink_modify(int argc, char **argv)
 	__u16 flags = 0;
 	struct rtattr *nest;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_SETLINK;
-	req.ifm.ifi_family = PF_BRIDGE;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/bridge/mdb.c b/bridge/mdb.c
index 6c904f8e6ae84..9d095602dad7f 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -234,19 +234,18 @@ static int mdb_modify(int cmd, int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct br_port_msg	bpm;
 		char			buf[1024];
-	} req;
-	struct br_mdb_entry entry;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct br_port_msg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.bpm.family = PF_BRIDGE
+	};
+	struct br_mdb_entry entry = { 0 };
 	char *d = NULL, *p = NULL, *grp = NULL;
 	short vid = 0;
 
-	memset(&req, 0, sizeof(req));
-	memset(&entry, 0, sizeof(entry));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct br_port_msg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.bpm.family = PF_BRIDGE;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 717025ae6eeca..031183f85afd7 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -29,22 +29,21 @@ static int vlan_modify(int cmd, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ifinfomsg	ifm;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = cmd
+		},
+		.ifm.ifi_family = PF_BRIDGE
+	};
 	char *d = NULL;
 	short vid = -1;
 	short vid_end = -1;
 	struct rtattr *afspec;
-	struct bridge_vlan_info vinfo;
+	struct bridge_vlan_info vinfo = { 0 };
 	unsigned short flags = 0;
 
-	memset(&vinfo, 0, sizeof(vinfo));
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = cmd;
-	req.ifm.ifi_family = PF_BRIDGE;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/genl/ctrl.c b/genl/ctrl.c
index ffa34af56b246..48cc87f666895 100644
--- a/genl/ctrl.c
+++ b/genl/ctrl.c
@@ -42,23 +42,21 @@ static int usage(void)
 int genl_ctrl_resolve_family(const char *family)
 {
 	struct rtnl_handle rth;
-	struct nlmsghdr *nlh;
-	struct genlmsghdr *ghdr;
 	int ret = 0;
 	struct {
 		struct nlmsghdr         n;
+		struct genlmsghdr	g;
 		char                    buf[4096];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-
-	nlh = &req.n;
-	nlh->nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
-	nlh->nlmsg_type = GENL_ID_CTRL;
-
-	ghdr = NLMSG_DATA(&req.n);
-	ghdr->cmd = CTRL_CMD_GETFAMILY;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN),
+			.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK,
+			.nlmsg_type = GENL_ID_CTRL
+		},
+		.g.cmd = CTRL_CMD_GETFAMILY
+	};
+	struct nlmsghdr *nlh = &req.n;
+	struct genlmsghdr *ghdr = &req.g;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
 		fprintf(stderr, "Cannot open generic netlink socket\n");
@@ -74,7 +72,6 @@ int genl_ctrl_resolve_family(const char *family)
 
 	{
 		struct rtattr *tb[CTRL_ATTR_MAX + 1];
-		struct genlmsghdr *ghdr = NLMSG_DATA(nlh);
 		int len = nlh->nlmsg_len;
 		struct rtattr *attrs;
 
@@ -291,24 +288,21 @@ static int print_ctrl2(const struct sockaddr_nl *who,
 static int ctrl_list(int cmd, int argc, char **argv)
 {
 	struct rtnl_handle rth;
-	struct nlmsghdr *nlh;
-	struct genlmsghdr *ghdr;
 	int ret = -1;
 	char d[GENL_NAMSIZ];
 	struct {
 		struct nlmsghdr         n;
+		struct genlmsghdr	g;
 		char                    buf[4096];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-
-	nlh = &req.n;
-	nlh->nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN);
-	nlh->nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK;
-	nlh->nlmsg_type = GENL_ID_CTRL;
-
-	ghdr = NLMSG_DATA(&req.n);
-	ghdr->cmd = CTRL_CMD_GETFAMILY;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN),
+			.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK,
+			.nlmsg_type = GENL_ID_CTRL
+		},
+		.g.cmd = CTRL_CMD_GETFAMILY
+	};
+	struct nlmsghdr *nlh = &req.n;
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_GENERIC) < 0) {
 		fprintf(stderr, "Cannot open generic netlink socket\n");
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index c02fa0746ab69..829692df3af2e 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -135,9 +135,7 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 {
 	int count = 0;
-	char medium[IFNAMSIZ];
-
-	memset(medium, 0, sizeof(medium));
+	char medium[IFNAMSIZ] = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
@@ -276,9 +274,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
-				struct ip6_tnl_parm2 old_p;
+				struct ip6_tnl_parm2 old_p = { 0 };
 
-				memset(&old_p, 0, sizeof(old_p));
 				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
 				*p = old_p;
@@ -351,7 +348,7 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
 		char name[IFNAMSIZ];
 		int index, type;
-		struct ip6_tnl_parm2 p1;
+		struct ip6_tnl_parm2 p1 = { 0 };
 		char *ptr;
 
 		buf[sizeof(buf) - 1] = '\0';
@@ -372,7 +369,6 @@ static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 		}
 		if (type != ARPHRD_TUNNEL6 && type != ARPHRD_IP6GRE)
 			continue;
-		memset(&p1, 0, sizeof(p1));
 		ip6_tnl_parm_init(&p1, 0);
 		if (type == ARPHRD_IP6GRE)
 			p1.proto = IPPROTO_GRE;
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 8766530f7fa7c..afb115e5f592a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -172,13 +172,12 @@ static void print_queuelen(FILE *f, struct rtattr *tb[IFLA_MAX + 1])
 	if (tb[IFLA_TXQLEN])
 		qlen = *(int *)RTA_DATA(tb[IFLA_TXQLEN]);
 	else {
-		struct ifreq ifr;
+		struct ifreq ifr = { 0 };
 		int s = socket(AF_INET, SOCK_STREAM, 0);
 
 		if (s < 0)
 			return;
 
-		memset(&ifr, 0, sizeof(ifr));
 		strcpy(ifr.ifr_name, rta_getattr_str(tb[IFLA_IFNAME]));
 		if (ioctl(s, SIOCGIFTXQLEN, &ifr) < 0) {
 			fprintf(f, "ioctl(SIOCGIFTXQLEN) failed: %s\n", strerror(errno));
@@ -1037,10 +1036,8 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	}
 	if (filter.pfx.family) {
 		if (rta_tb[IFA_LOCAL]) {
-			inet_prefix dst;
+			inet_prefix dst = { .family = ifa->ifa_family };
 
-			memset(&dst, 0, sizeof(dst));
-			dst.family = ifa->ifa_family;
 			memcpy(&dst.data, RTA_DATA(rta_tb[IFA_LOCAL]), RTA_PAYLOAD(rta_tb[IFA_LOCAL]));
 			if (inet_addr_match(&dst, &filter.pfx, filter.pfx.bitlen))
 				return 0;
@@ -1396,10 +1393,8 @@ static void ipaddr_filter(struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
 					tb[IFA_LOCAL] = tb[IFA_ADDRESS];
 
 				if (filter.pfx.family && tb[IFA_LOCAL]) {
-					inet_prefix dst;
+					inet_prefix dst = { .family = ifa->ifa_family };
 
-					memset(&dst, 0, sizeof(dst));
-					dst.family = ifa->ifa_family;
 					memcpy(&dst.data, RTA_DATA(tb[IFA_LOCAL]), RTA_PAYLOAD(tb[IFA_LOCAL]));
 					if (inet_addr_match(&dst, &filter.pfx, filter.pfx.bitlen))
 						continue;
@@ -1827,7 +1822,14 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ifaddrmsg	ifa;
 		char			buf[256];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.ifa.ifa_family = preferred_family
+	};
 	char  *d = NULL;
 	char  *l = NULL;
 	char  *lcl_arg = NULL;
@@ -1842,16 +1844,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	int scoped = 0;
 	__u32 preferred_lft = INFINITY_LIFE_TIME;
 	__u32 valid_lft = INFINITY_LIFE_TIME;
-	struct ifa_cacheinfo cinfo;
 	unsigned int ifa_flags = 0;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST | flags;
-	req.n.nlmsg_type = cmd;
-	req.ifa.ifa_family = preferred_family;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "peer") == 0 ||
 		    strcmp(*argv, "remote") == 0) {
@@ -2008,6 +2002,8 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 	}
 
 	if (valid_lftp || preferred_lftp) {
+		struct ifa_cacheinfo cinfo = { 0 };
+
 		if (!valid_lft) {
 			fprintf(stderr, "valid_lft is zero\n");
 			return -1;
@@ -2017,7 +2013,6 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
 			return -1;
 		}
 
-		memset(&cinfo, 0, sizeof(cinfo));
 		cinfo.ifa_prefered = preferred_lft;
 		cinfo.ifa_valid = valid_lft;
 		addattr_l(&req.n, sizeof(req), IFA_CACHEINFO, &cinfo,
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index b4cd784094719..98538001ec860 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -127,23 +127,20 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ifaddrlblmsg	ifal;
 		char			buf[1024];
-	} req;
-
-	inet_prefix prefix;
+	} req = {
+		.n = {
+			.nlmsg_type = cmd,
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrlblmsg)),
+			.nlmsg_flags = NLM_F_REQUEST
+		},
+		.ifal.ifal_family = preferred_family,
+	};
+
+	inet_prefix prefix = { 0 };
 	uint32_t label = 0xffffffffUL;
 	char *p = NULL;
 	char *l = NULL;
 
-	memset(&req, 0, sizeof(req));
-	memset(&prefix, 0, sizeof(prefix));
-
-	req.n.nlmsg_type = cmd;
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifaddrlblmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.ifal.ifal_family = preferred_family;
-	req.ifal.ifal_prefixlen = 0;
-	req.ifal.ifal_index = 0;
-
 	if (cmd == RTM_NEWADDRLABEL) {
 		req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
 	}
diff --git a/ip/iplink.c b/ip/iplink.c
index d2e586b6d1332..ad5e191c010c9 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -206,16 +206,16 @@ static int iplink_have_newlink(void)
 		struct nlmsghdr		n;
 		struct ifinfomsg	i;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK,
+			.nlmsg_type = RTM_NEWLINK
+		},
+		.i.ifi_family = AF_UNSPEC
+	};
 
 	if (have_rtnl_newlink < 0) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-		req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
-		req.n.nlmsg_type = RTM_NEWLINK;
-		req.i.ifi_family = AF_UNSPEC;
-
 		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
 			perror("request send failed");
 			exit(1);
@@ -690,16 +690,16 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	int index = -1;
 	int group;
 	struct link_util *lu = NULL;
-	struct iplink_req req;
+	struct iplink_req req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.i.ifi_family = preferred_family
+	};
 	int ret;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.i.ifi_family = preferred_family;
-
 	ret = iplink_parse(argc, argv, &req, &name, &type, &link, &dev, &group, &index);
 	if (ret < 0)
 		return ret;
@@ -829,19 +829,19 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
 {
 	int len;
-	struct iplink_req req;
+	struct iplink_req req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i.ifi_family = preferred_family
+	};
 	struct {
 		struct nlmsghdr n;
 		char buf[16384];
 	} answer;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = RTM_GETLINK;
-	req.i.ifi_family = preferred_family;
-
 	if (name) {
 		len = strlen(name) + 1;
 		if (len == 1)
@@ -935,16 +935,14 @@ static int do_changename(const char *dev, const char *newdev)
 
 static int set_qlen(const char *dev, int qlen)
 {
-	struct ifreq ifr;
+	struct ifreq ifr = { .ifr_qlen = qlen };
 	int s;
 
 	s = get_ctl_fd();
 	if (s < 0)
 		return -1;
 
-	memset(&ifr, 0, sizeof(ifr));
 	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
-	ifr.ifr_qlen = qlen;
 	if (ioctl(s, SIOCSIFTXQLEN, &ifr) < 0) {
 		perror("SIOCSIFXQLEN");
 		close(s);
@@ -957,16 +955,14 @@ static int set_qlen(const char *dev, int qlen)
 
 static int set_mtu(const char *dev, int mtu)
 {
-	struct ifreq ifr;
+	struct ifreq ifr = { .ifr_mtu = mtu };
 	int s;
 
 	s = get_ctl_fd();
 	if (s < 0)
 		return -1;
 
-	memset(&ifr, 0, sizeof(ifr));
 	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
-	ifr.ifr_mtu = mtu;
 	if (ioctl(s, SIOCSIFMTU, &ifr) < 0) {
 		perror("SIOCSIFMTU");
 		close(s);
@@ -979,8 +975,11 @@ static int set_mtu(const char *dev, int mtu)
 
 static int get_address(const char *dev, int *htype)
 {
-	struct ifreq ifr;
-	struct sockaddr_ll me;
+	struct ifreq ifr = { 0 };
+	struct sockaddr_ll me = {
+		.sll_family = AF_PACKET,
+		.sll_protocol = htons(ETH_P_LOOP)
+	};
 	socklen_t alen;
 	int s;
 
@@ -990,7 +989,6 @@ static int get_address(const char *dev, int *htype)
 		return -1;
 	}
 
-	memset(&ifr, 0, sizeof(ifr));
 	strncpy(ifr.ifr_name, dev, IFNAMSIZ);
 	if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
 		perror("SIOCGIFINDEX");
@@ -998,10 +996,7 @@ static int get_address(const char *dev, int *htype)
 		return -1;
 	}
 
-	memset(&me, 0, sizeof(me));
-	me.sll_family = AF_PACKET;
 	me.sll_ifindex = ifr.ifr_ifindex;
-	me.sll_protocol = htons(ETH_P_LOOP);
 	if (bind(s, (struct sockaddr *)&me, sizeof(me)) == -1) {
 		perror("bind");
 		close(s);
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index a00d423110aef..5d159590fdb54 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -110,11 +110,9 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
-	struct can_bittiming bt, dbt;
+	struct can_bittiming bt = { 0 }, dbt = { 0 };
 	struct can_ctrlmode cm = {0, 0};
 
-	memset(&bt, 0, sizeof(bt));
-	memset(&dbt, 0, sizeof(dbt));
 	while (argc > 0) {
 		if (matches(*argv, "bitrate") == 0) {
 			NEXT_ARG();
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index c3673979f9761..f7fa17f196af8 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -93,18 +93,15 @@ static void read_dev_mcast(struct ma_info **result_p)
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		char hexa[256];
-		struct ma_info m;
+		struct ma_info m = { .addr.family = AF_PACKET };
 		int len;
 		int st;
 
-		memset(&m, 0, sizeof(m));
 		sscanf(buf, "%d%s%d%d%s", &m.index, m.name, &m.users, &st,
 		       hexa);
 		if (filter.dev && strcmp(filter.dev, m.name))
 			continue;
 
-		m.addr.family = AF_PACKET;
-
 		len = parse_hex(hexa, (unsigned char *)&m.addr.data, sizeof(m.addr.data));
 		if (len >= 0) {
 			struct ma_info *ma = malloc(sizeof(m));
@@ -122,22 +119,23 @@ static void read_dev_mcast(struct ma_info **result_p)
 
 static void read_igmp(struct ma_info **result_p)
 {
-	struct ma_info m;
+	struct ma_info m = {
+		.addr = {
+			.family = AF_INET,
+			.bitlen = 32,
+			.bytelen = 4
+		}
+	};
 	char buf[256];
 	FILE *fp = fopen("/proc/net/igmp", "r");
 
 	if (!fp)
 		return;
-	memset(&m, 0, sizeof(m));
 	if (!fgets(buf, sizeof(buf), fp)) {
 		fclose(fp);
 		return;
 	}
 
-	m.addr.family = AF_INET;
-	m.addr.bitlen = 32;
-	m.addr.bytelen = 4;
-
 	while (fgets(buf, sizeof(buf), fp)) {
 		struct ma_info *ma;
 
@@ -169,17 +167,14 @@ static void read_igmp6(struct ma_info **result_p)
 
 	while (fgets(buf, sizeof(buf), fp)) {
 		char hexa[256];
-		struct ma_info m;
+		struct ma_info m = { .addr.family = AF_INET6 };
 		int len;
 
-		memset(&m, 0, sizeof(m));
 		sscanf(buf, "%d%s%s%d", &m.index, m.name, hexa, &m.users);
 
 		if (filter.dev && strcmp(filter.dev, m.name))
 			continue;
 
-		m.addr.family = AF_INET6;
-
 		len = parse_hex(hexa, (unsigned char *)&m.addr.data, sizeof(m.addr.data));
 		if (len >= 0) {
 			struct ma_info *ma = malloc(sizeof(m));
@@ -274,11 +269,9 @@ static int multiaddr_list(int argc, char **argv)
 
 static int multiaddr_modify(int cmd, int argc, char **argv)
 {
-	struct ifreq ifr;
+	struct ifreq ifr = { 0 };
 	int fd;
 
-	memset(&ifr, 0, sizeof(ifr));
-
 	if (cmd == RTM_NEWADDR)
 		cmd = SIOCADDMULTI;
 	else
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index c33cdcbbde21b..5d6922a23ae66 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -97,20 +97,16 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		return 0;
 
 	if (tb[RTA_DST] && filter.mdst.bitlen > 0) {
-		inet_prefix dst;
+		inet_prefix dst = { .family = r->rtm_family };
 
-		memset(&dst, 0, sizeof(dst));
-		dst.family = r->rtm_family;
 		memcpy(&dst.data, RTA_DATA(tb[RTA_DST]), RTA_PAYLOAD(tb[RTA_DST]));
 		if (inet_addr_match(&dst, &filter.mdst, filter.mdst.bitlen))
 			return 0;
 	}
 
 	if (tb[RTA_SRC] && filter.msrc.bitlen > 0) {
-		inet_prefix src;
+		inet_prefix src = { .family = r->rtm_family };
 
-		memset(&src, 0, sizeof(src));
-		src.family = r->rtm_family;
 		memcpy(&src.data, RTA_DATA(tb[RTA_SRC]), RTA_PAYLOAD(tb[RTA_SRC]));
 		if (inet_addr_match(&src, &filter.msrc, filter.msrc.bitlen))
 			return 0;
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 4ddb747e20863..35e16af622bd0 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -100,7 +100,17 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ndmsg		ndm;
 		char			buf[256];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.ndm = {
+			.ndm_family = preferred_family,
+			.ndm_state = NUD_PERMANENT
+		}
+	};
 	char  *dev = NULL;
 	int dst_ok = 0;
 	int dev_ok = 0;
@@ -108,14 +118,6 @@ static int ipneigh_modify(int cmd, int flags, int argc, char **argv)
 	char *lla = NULL;
 	inet_prefix dst;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.ndm.ndm_family = preferred_family;
-	req.ndm.ndm_state = NUD_PERMANENT;
-
 	while (argc > 0) {
 		if (matches(*argv, "lladdr") == 0) {
 			NEXT_ARG();
@@ -238,10 +240,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[NDA_DST]) {
 		if (filter.pfx.family) {
-			inet_prefix dst;
+			inet_prefix dst = { .family = r->ndm_family };
 
-			memset(&dst, 0, sizeof(dst));
-			dst.family = r->ndm_family;
 			memcpy(&dst.data, RTA_DATA(tb[NDA_DST]), RTA_PAYLOAD(tb[NDA_DST]));
 			if (inet_addr_match(&dst, &filter.pfx, filter.pfx.bitlen))
 				return 0;
@@ -347,15 +347,15 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		struct nlmsghdr	n;
 		struct ndmsg		ndm;
 		char			buf[256];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_type = RTM_GETNEIGH,
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg))
+		}
+	};
 	char *filter_dev = NULL;
 	int state_given = 0;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_type = RTM_GETNEIGH;
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
-
 	ipneigh_reset_filter(0);
 
 	if (!filter.family)
diff --git a/ip/ipnetconf.c b/ip/ipnetconf.c
index 5fdbfb644dbe9..5788c396399fd 100644
--- a/ip/ipnetconf.c
+++ b/ip/ipnetconf.c
@@ -154,7 +154,13 @@ static int do_show(int argc, char **argv)
 		struct nlmsghdr		n;
 		struct netconfmsg	ncm;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct netconfmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | NLM_F_ACK,
+			.nlmsg_type = RTM_GETNETCONF
+		}
+	};
 
 	ipnetconf_reset_filter(0);
 	filter.family = preferred_family;
@@ -176,10 +182,6 @@ static int do_show(int argc, char **argv)
 
 	ll_init_map(&rth);
 	if (filter.ifindex) {
-		memset(&req, 0, sizeof(req));
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct netconfmsg));
-		req.n.nlmsg_flags = NLM_F_REQUEST|NLM_F_ACK;
-		req.n.nlmsg_type = RTM_GETNETCONF;
 		req.ncm.ncm_family = filter.family;
 		if (filter.ifindex)
 			addattr_l(&req.n, sizeof(req), NETCONFA_IFINDEX,
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index b3ee23c23aaa2..0d91760cda67c 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -61,16 +61,17 @@ static int ipnetns_have_nsid(void)
 		struct nlmsghdr n;
 		struct rtgenmsg g;
 		char            buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETNSID
+		},
+		.g.rtgen_family = AF_UNSPEC
+	};
 	int fd;
 
 	if (have_rtnl_getnsid < 0) {
-		memset(&req, 0, sizeof(req));
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETNSID;
-		req.g.rtgen_family = AF_UNSPEC;
-
 		fd = open("/proc/self/ns/net", O_RDONLY);
 		if (fd < 0) {
 			perror("open(\"/proc/self/ns/net\")");
@@ -96,17 +97,18 @@ static int get_netnsid_from_name(const char *name)
 		struct nlmsghdr n;
 		struct rtgenmsg g;
 		char            buf[1024];
-	} req, answer;
+	} answer, req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETNSID
+		},
+		.g.rtgen_family = AF_UNSPEC
+	};
 	struct rtattr *tb[NETNSA_MAX + 1];
 	struct rtgenmsg *rthdr;
 	int len, fd;
 
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_GETNSID;
-	req.g.rtgen_family = AF_UNSPEC;
-
 	fd = netns_get_fd(name);
 	if (fd < 0)
 		return fd;
@@ -685,15 +687,16 @@ static int set_netnsid_from_name(const char *name, int nsid)
 		struct nlmsghdr n;
 		struct rtgenmsg g;
 		char            buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_NEWNSID
+		},
+		.g.rtgen_family = AF_UNSPEC
+	};
 	int fd, err = 0;
 
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_NEWNSID;
-	req.g.rtgen_family = AF_UNSPEC;
-
 	fd = netns_get_fd(name);
 	if (fd < 0)
 		return fd;
diff --git a/ip/ipntable.c b/ip/ipntable.c
index 8e78773d0e4b0..b973aeb801bdf 100644
--- a/ip/ipntable.c
+++ b/ip/ipntable.c
@@ -66,26 +66,21 @@ static int ipntable_modify(int cmd, int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct ndtmsg		ndtm;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndtmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.ndtm.ndtm_family = preferred_family
+	};
 	char *namep = NULL;
 	char *threshsp = NULL;
 	char *gc_intp = NULL;
-	char parms_buf[1024];
+	char parms_buf[1024] = { 0 };
 	struct rtattr *parms_rta = (struct rtattr *)parms_buf;
 	int parms_change = 0;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndtmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-
-	req.ndtm.ndtm_family = preferred_family;
-	req.ndtm.ndtm_pad1 = 0;
-	req.ndtm.ndtm_pad2 = 0;
-
-	memset(&parms_buf, 0, sizeof(parms_buf));
-
 	parms_rta->rta_type = NDTA_PARMS;
 	parms_rta->rta_len = RTA_LENGTH(0);
 
@@ -322,15 +317,13 @@ static int ipntable_modify(int cmd, int flags, int argc, char **argv)
 static const char *ntable_strtime_delta(__u32 msec)
 {
 	static char str[32];
-	struct timeval now;
+	struct timeval now = { 0 };
 	time_t t;
 	struct tm *tp;
 
 	if (msec == 0)
 		goto error;
 
-	memset(&now, 0, sizeof(now));
-
 	if (gettimeofday(&now, NULL) < 0) {
 		perror("gettimeofday");
 		goto error;
diff --git a/ip/iproute.c b/ip/iproute.c
index 8224d7ffa94bf..b6519dc30f578 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -140,10 +140,10 @@ static int flush_update(void)
 static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 {
 	struct rtmsg *r = NLMSG_DATA(n);
-	inet_prefix dst;
-	inet_prefix src;
-	inet_prefix via;
-	inet_prefix prefsrc;
+	inet_prefix dst = { .family = r->rtm_family };
+	inet_prefix src = { .family = r->rtm_family };
+	inet_prefix via = { .family = r->rtm_family };
+	inet_prefix prefsrc = { .family = r->rtm_family };
 	__u32 table;
 	static int ip6_multiple_tables;
 
@@ -210,19 +210,13 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 	if (filter.rprefsrc.family && r->rtm_family != filter.rprefsrc.family)
 		return 0;
 
-	memset(&dst, 0, sizeof(dst));
-	dst.family = r->rtm_family;
 	if (tb[RTA_DST])
 		memcpy(&dst.data, RTA_DATA(tb[RTA_DST]), (r->rtm_dst_len+7)/8);
 	if (filter.rsrc.family || filter.msrc.family) {
-		memset(&src, 0, sizeof(src));
-		src.family = r->rtm_family;
 		if (tb[RTA_SRC])
 			memcpy(&src.data, RTA_DATA(tb[RTA_SRC]), (r->rtm_src_len+7)/8);
 	}
 	if (filter.rvia.bitlen > 0) {
-		memset(&via, 0, sizeof(via));
-		via.family = r->rtm_family;
 		if (tb[RTA_GATEWAY])
 			memcpy(&via.data, RTA_DATA(tb[RTA_GATEWAY]), host_len/8);
 		if (tb[RTA_VIA]) {
@@ -234,8 +228,6 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 		}
 	}
 	if (filter.rprefsrc.bitlen > 0) {
-		memset(&prefsrc, 0, sizeof(prefsrc));
-		prefsrc.family = r->rtm_family;
 		if (tb[RTA_PREFSRC])
 			memcpy(&prefsrc.data, RTA_DATA(tb[RTA_PREFSRC]), host_len/8);
 	}
@@ -827,7 +819,18 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct rtmsg		r;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.r = {
+			.rtm_family = preferred_family,
+			.rtm_table = RT_TABLE_MAIN,
+			.rtm_scope = RT_SCOPE_NOWHERE
+		}
+	};
 	char  mxbuf[256];
 	struct rtattr *mxrta = (void *)mxbuf;
 	unsigned int mxlock = 0;
@@ -841,15 +844,6 @@ static int iproute_modify(int cmd, unsigned int flags, int argc, char **argv)
 	int type_ok = 0;
 	static int hz;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.r.rtm_family = preferred_family;
-	req.r.rtm_table = RT_TABLE_MAIN;
-	req.r.rtm_scope = RT_SCOPE_NOWHERE;
-
 	if (cmd != RTM_DELROUTE) {
 		req.r.rtm_protocol = RTPROT_BOOT;
 		req.r.rtm_scope = RT_SCOPE_UNIVERSE;
@@ -1264,20 +1258,20 @@ static int rtnl_rtcache_request(struct rtnl_handle *rth, int family)
 	struct {
 		struct nlmsghdr nlh;
 		struct rtmsg rtm;
-	} req;
-	struct sockaddr_nl nladdr;
-
-	memset(&nladdr, 0, sizeof(nladdr));
-	memset(&req, 0, sizeof(req));
-	nladdr.nl_family = AF_NETLINK;
+	} req = {
+		.nlh = {
+			.nlmsg_len = sizeof(req),
+			.nlmsg_type = RTM_GETROUTE,
+			.nlmsg_flags = NLM_F_ROOT | NLM_F_REQUEST
+		},
+		.rtm = {
+			.rtm_family = family,
+			.rtm_flags = RTM_F_CLONED
+		}
+	};
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = RTM_GETROUTE;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_REQUEST;
-	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
-	req.rtm.rtm_family = family;
-	req.rtm.rtm_flags |= RTM_F_CLONED;
 
 	return sendto(rth->fd, (void *)&req, sizeof(req), 0, (struct sockaddr *)&nladdr, sizeof(nladdr));
 }
@@ -1620,30 +1614,23 @@ static int iproute_get(int argc, char **argv)
 		struct nlmsghdr	n;
 		struct rtmsg		r;
 		char			buf[1024];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETROUTE
+		},
+		.r.rtm_family = preferred_family
+	};
 	char  *idev = NULL;
 	char  *odev = NULL;
 	int connected = 0;
 	int from_ok = 0;
 	unsigned int mark = 0;
 
-	memset(&req, 0, sizeof(req));
-
 	iproute_reset_filter(0);
 	filter.cloned = 2;
 
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_GETROUTE;
-	req.r.rtm_family = preferred_family;
-	req.r.rtm_table = 0;
-	req.r.rtm_protocol = 0;
-	req.r.rtm_scope = 0;
-	req.r.rtm_type = 0;
-	req.r.rtm_src_len = 0;
-	req.r.rtm_dst_len = 0;
-	req.r.rtm_tos = 0;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "tos") == 0 ||
 		    matches(*argv, "dsfield") == 0) {
diff --git a/ip/iprule.c b/ip/iprule.c
index 7cb19e4d5ebd0..42a37a13db180 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -316,19 +316,19 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct rtmsg		r;
 		char			buf[1024];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_type = cmd;
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.r.rtm_family = preferred_family;
-	req.r.rtm_protocol = RTPROT_BOOT;
-	req.r.rtm_scope = RT_SCOPE_UNIVERSE;
-	req.r.rtm_table = 0;
-	req.r.rtm_type = RTN_UNSPEC;
-	req.r.rtm_flags = 0;
+	} req = {
+		.n = {
+			.nlmsg_type = cmd,
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)),
+			.nlmsg_flags = NLM_F_REQUEST
+		},
+		.r = {
+			.rtm_family = preferred_family,
+			.rtm_protocol = RTPROT_BOOT,
+			.rtm_scope = RT_SCOPE_UNIVERSE,
+			.rtm_type = RTN_UNSPEC
+		}
+	};
 
 	if (cmd == RTM_NEWRULE) {
 		req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 722b526add08f..808f713ea6abe 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -89,10 +89,7 @@ static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *
 static int iptoken_list(int argc, char **argv)
 {
 	int af = AF_INET6;
-	struct rtnl_dump_args da;
-
-	memset(&da, 0, sizeof(da));
-	da.fp = stdout;
+	struct rtnl_dump_args da = { .fp = stdout };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -123,18 +120,18 @@ static int iptoken_set(int argc, char **argv, bool delete)
 		struct nlmsghdr n;
 		struct ifinfomsg ifi;
 		char buf[512];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_SETLINK
+		},
+		.ifi.ifi_family = AF_INET6
+	};
 	struct rtattr *afs, *afs6;
 	bool have_token = delete, have_dev = false;
 	inet_prefix addr = { .bytelen = 16, };
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_SETLINK;
-	req.ifi.ifi_family = AF_INET6;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index e3161d81beded..231ef3f8b3590 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -60,12 +60,10 @@ static void set_tunnel_proto(struct ip_tunnel_parm *p, int proto)
 static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 {
 	int count = 0;
-	char medium[IFNAMSIZ];
+	char medium[IFNAMSIZ] = { 0 };
 	int isatap = 0;
 
 	memset(p, 0, sizeof(*p));
-	memset(&medium, 0, sizeof(medium));
-
 	p->iph.version = 4;
 	p->iph.ihl = 5;
 #ifndef IP_DF
@@ -182,9 +180,8 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
-				struct ip_tunnel_parm old_p;
+				struct ip_tunnel_parm old_p = { 0 };
 
-				memset(&old_p, 0, sizeof(old_p));
 				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
 				*p = old_p;
@@ -296,12 +293,10 @@ static int do_del(int argc, char **argv)
 
 static void print_tunnel(struct ip_tunnel_parm *p)
 {
-	struct ip_tunnel_6rd ip6rd;
+	struct ip_tunnel_6rd ip6rd = { 0 };
 	char s1[1024];
 	char s2[1024];
 
-	memset(&ip6rd, 0, sizeof(ip6rd));
-
 	/* Do not use format_host() for local addr,
 	 * symbolic name will not be useful.
 	 */
@@ -312,10 +307,9 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	       p->iph.saddr ? rt_addr_n2a_r(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
-		struct ip_tunnel_prl prl[16];
+		struct ip_tunnel_prl prl[16] = { 0 };
 		int i;
 
-		memset(prl, 0, sizeof(prl));
 		prl[0].datalen = sizeof(prl) - sizeof(prl[0]);
 		prl[0].addr = htonl(INADDR_ANY);
 
@@ -405,7 +399,7 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
 		char name[IFNAMSIZ];
 		int index, type;
-		struct ip_tunnel_parm p1;
+		struct ip_tunnel_parm p1 = { 0 };
 		char *ptr;
 
 		buf[sizeof(buf) - 1] = 0;
@@ -427,7 +421,6 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		}
 		if (type != ARPHRD_TUNNEL && type != ARPHRD_IPGRE && type != ARPHRD_SIT)
 			continue;
-		memset(&p1, 0, sizeof(p1));
 		if (tnl_get_ioctl(name, &p1))
 			continue;
 		if ((p->link && p1.link != p->link) ||
@@ -470,14 +463,11 @@ static int do_show(int argc, char **argv)
 
 static int do_prl(int argc, char **argv)
 {
-	struct ip_tunnel_prl p;
+	struct ip_tunnel_prl p = { 0 };
 	int count = 0;
 	int devname = 0;
 	int cmd = 0;
-	char medium[IFNAMSIZ];
-
-	memset(&p, 0, sizeof(p));
-	memset(&medium, 0, sizeof(medium));
+	char medium[IFNAMSIZ] = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "prl-default") == 0) {
@@ -522,15 +512,12 @@ static int do_prl(int argc, char **argv)
 
 static int do_6rd(int argc, char **argv)
 {
-	struct ip_tunnel_6rd ip6rd;
+	struct ip_tunnel_6rd ip6rd = { 0 };
 	int devname = 0;
 	int cmd = 0;
-	char medium[IFNAMSIZ];
+	char medium[IFNAMSIZ] = { 0 };
 	inet_prefix prefix;
 
-	memset(&ip6rd, 0, sizeof(ip6rd));
-	memset(&medium, 0, sizeof(medium));
-
 	while (argc > 0) {
 		if (strcmp(*argv, "6rd-prefix") == 0) {
 			NEXT_ARG();
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 8d786d1334df1..a1af3ae9baeb0 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -867,9 +867,7 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 
 static int xfrm_selector_iszero(struct xfrm_selector *s)
 {
-	struct xfrm_selector s0;
-
-	memset(&s0, 0, sizeof(s0));
+	struct xfrm_selector s0 = { 0 };
 
 	return (memcmp(&s0, s, sizeof(s0)) == 0);
 }
@@ -878,11 +876,9 @@ void xfrm_state_info_print(struct xfrm_usersa_info *xsinfo,
 			    struct rtattr *tb[], FILE *fp, const char *prefix,
 			    const char *title)
 {
-	char buf[STRBUF_SIZE];
+	char buf[STRBUF_SIZE] = { 0 };
 	int force_spi = xfrm_xfrmproto_is_ipsec(xsinfo->id.proto);
 
-	memset(buf, '\0', sizeof(buf));
-
 	xfrm_id_info_print(&xsinfo->saddr, &xsinfo->id, xsinfo->mode,
 			   xsinfo->reqid, xsinfo->family, force_spi, fp,
 			   prefix, title);
@@ -959,9 +955,7 @@ void xfrm_policy_info_print(struct xfrm_userpolicy_info *xpinfo,
 			    struct rtattr *tb[], FILE *fp, const char *prefix,
 			    const char *title)
 {
-	char buf[STRBUF_SIZE];
-
-	memset(buf, '\0', sizeof(buf));
+	char buf[STRBUF_SIZE] = { 0 };
 
 	xfrm_selector_print(&xpinfo->sel, preferred_family, fp, title);
 
@@ -1062,11 +1056,8 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 {
 	int argc = *argcp;
 	char **argv = *argvp;
-	inet_prefix dst;
-	inet_prefix src;
-
-	memset(&dst, 0, sizeof(dst));
-	memset(&src, 0, sizeof(src));
+	inet_prefix dst = { 0 };
+	inet_prefix src = { 0 };
 
 	while (1) {
 		if (strcmp(*argv, "src") == 0) {
@@ -1371,13 +1362,10 @@ int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp)
 {
 	int argc = *argcp;
 	char **argv = *argvp;
-	inet_prefix dst;
-	inet_prefix src;
+	inet_prefix dst = { 0 };
+	inet_prefix src = { 0 };
 	char *upspecp = NULL;
 
-	memset(&dst, 0, sizeof(dst));
-	memset(&src, 0, sizeof(src));
-
 	while (1) {
 		if (strcmp(*argv, "src") == 0) {
 			NEXT_ARG();
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 492c22053b891..281f6283778f6 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -50,12 +50,22 @@ static void usage(void)
 static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[16384];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
@@ -77,14 +87,6 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 metadata = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index bddfc0ff97aa0..940d04e97220b 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -60,12 +60,22 @@ static void usage(void)
 static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[1024];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
@@ -83,14 +93,6 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 8a31d0dcd1883..43294ccff1c19 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -58,18 +58,28 @@ static void usage(void)
 static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 			       struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[2048];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
 	int len;
-	struct in6_addr laddr;
-	struct in6_addr raddr;
+	struct in6_addr laddr = { 0 };
+	struct in6_addr raddr = { 0 };
 	__u8 hop_limit = DEFAULT_TNL_HOP_LIMIT;
 	__u8 encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
 	__u32 flowinfo = 0;
@@ -77,18 +87,7 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 link = 0;
 	__u8 proto = 0;
 
-	memset(&laddr, 0, sizeof(laddr));
-	memset(&raddr, 0, sizeof(raddr));
-
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 8411a6a00a1b4..3ea221e27c878 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -53,12 +53,22 @@ static void usage(int sit)
 static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 			      struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[2048];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *iptuninfo[IFLA_IPTUN_MAX + 1];
@@ -71,7 +81,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 pmtudisc = 1;
 	__u16 iflags = 0;
 	__u8 proto = 0;
-	struct in6_addr ip6rdprefix;
+	struct in6_addr ip6rdprefix = { 0 };
 	__u16 ip6rdprefixlen = 0;
 	__u32 ip6rdrelayprefix = 0;
 	__u16 ip6rdrelayprefixlen = 0;
@@ -80,17 +90,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 
-	memset(&ip6rdprefix, 0, sizeof(ip6rdprefix));
-
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 8052e7514989a..edc3f17f8a983 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -46,12 +46,22 @@ static void usage(void)
 static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[1024];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
@@ -63,14 +73,6 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 9bcf7fe9dea46..f799dc222ffb0 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -42,12 +42,22 @@ static void usage(void)
 static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
 	struct {
 		struct nlmsghdr n;
 		struct ifinfomsg i;
 		char buf[1024];
-	} req;
-	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_GETLINK
+		},
+		.i = {
+			.ifi_family = preferred_family,
+			.ifi_index = ifi->ifi_index
+		}
+	};
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct rtattr *vtiinfo[IFLA_VTI_MAX + 1];
@@ -59,14 +69,6 @@ static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
-		memset(&req, 0, sizeof(req));
-
-		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
-		req.n.nlmsg_flags = NLM_F_REQUEST;
-		req.n.nlmsg_type = RTM_GETLINK;
-		req.i.ifi_family = preferred_family;
-		req.i.ifi_index = ifi->ifi_index;
-
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
 get_failed:
 			fprintf(stderr,
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index f1ac3e91d8097..2cec132397a62 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -248,34 +248,32 @@ static int xfrm_policy_modify(int cmd, unsigned int flags, int argc, char **argv
 		struct nlmsghdr			n;
 		struct xfrm_userpolicy_info	xpinfo;
 		char				buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpinfo)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.xpinfo = {
+			.sel.family = preferred_family,
+			.lft.soft_byte_limit = XFRM_INF,
+			.lft.hard_byte_limit = XFRM_INF,
+			.lft.soft_packet_limit = XFRM_INF,
+			.lft.hard_packet_limit = XFRM_INF
+		}
+	};
 	char *dirp = NULL;
 	char *selp = NULL;
 	char *ptypep = NULL;
 	char *sctxp = NULL;
-	struct xfrm_userpolicy_type upt;
-	char tmpls_buf[XFRM_TMPLS_BUF_SIZE];
+	struct xfrm_userpolicy_type upt = { 0 };
+	char tmpls_buf[XFRM_TMPLS_BUF_SIZE] = { 0 };
 	int tmpls_len = 0;
 	struct xfrm_mark mark = {0, 0};
 	struct {
 		struct xfrm_user_sec_ctx sctx;
 		char	str[CTX_BUF_SIZE];
-	} ctx;
-
-	memset(&req, 0, sizeof(req));
-	memset(&upt, 0, sizeof(upt));
-	memset(&tmpls_buf, 0, sizeof(tmpls_buf));
-	memset(&ctx, 0, sizeof(ctx));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpinfo));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.xpinfo.sel.family = preferred_family;
-
-	req.xpinfo.lft.soft_byte_limit = XFRM_INF;
-	req.xpinfo.lft.hard_byte_limit = XFRM_INF;
-	req.xpinfo.lft.soft_packet_limit = XFRM_INF;
-	req.xpinfo.lft.hard_packet_limit = XFRM_INF;
+	} ctx = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dir") == 0) {
@@ -561,27 +559,24 @@ static int xfrm_policy_get_or_delete(int argc, char **argv, int delete,
 		struct nlmsghdr			n;
 		struct xfrm_userpolicy_id	xpid;
 		char				buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpid)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = delete ? XFRM_MSG_DELPOLICY : XFRM_MSG_GETPOLICY
+		}
+	};
 	char *dirp = NULL;
 	char *selp = NULL;
 	char *indexp = NULL;
 	char *ptypep = NULL;
 	char *sctxp = NULL;
-	struct xfrm_userpolicy_type upt;
+	struct xfrm_userpolicy_type upt = { 0 };
 	struct xfrm_mark mark = {0, 0};
 	struct {
 		struct xfrm_user_sec_ctx sctx;
 		char    str[CTX_BUF_SIZE];
-	} ctx;
-
-
-	memset(&req, 0, sizeof(req));
-	memset(&upt, 0, sizeof(upt));
-	memset(&ctx, 0, sizeof(ctx));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xpid));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = delete ? XFRM_MSG_DELPOLICY : XFRM_MSG_GETPOLICY;
+	} ctx = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dir") == 0) {
@@ -684,11 +679,9 @@ static int xfrm_policy_delete(int argc, char **argv)
 
 static int xfrm_policy_get(int argc, char **argv)
 {
-	char buf[NLMSG_BUF_SIZE];
+	char buf[NLMSG_BUF_SIZE] = { 0 };
 	struct nlmsghdr *n = (struct nlmsghdr *)buf;
 
-	memset(buf, 0, sizeof(buf));
-
 	xfrm_policy_get_or_delete(argc, argv, 0, n, sizeof(buf));
 
 	if (xfrm_policy_print(NULL, n, (void *)stdout) < 0) {
@@ -1012,18 +1005,18 @@ static int xfrm_spd_setinfo(int argc, char **argv)
 		struct nlmsghdr			n;
 		__u32				flags;
 		char				buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(__u32)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_NEWSPDINFO
+		},
+		.flags = 0XFFFFFFFF
+	};
 
 	char *thr4 = NULL;
 	char *thr6 = NULL;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(__u32));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_NEWSPDINFO;
-	req.flags = 0XFFFFFFFF;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "hthresh4") == 0) {
 			struct xfrmu_spdhthresh thr;
@@ -1080,14 +1073,14 @@ static int xfrm_spd_getinfo(int argc, char **argv)
 		struct nlmsghdr			n;
 		__u32				flags;
 		char				ans[128];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(__u32));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_GETSPDINFO;
-	req.flags = 0XFFFFFFFF;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(__u32)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_GETSPDINFO
+		},
+		.flags = 0XFFFFFFFF
+	};
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
@@ -1108,16 +1101,15 @@ static int xfrm_policy_flush(int argc, char **argv)
 	struct {
 		struct nlmsghdr	n;
 		char		buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(0), /* nlmsg data is nothing */
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_FLUSHPOLICY
+		}
+	};
 	char *ptypep = NULL;
-	struct xfrm_userpolicy_type upt;
-
-	memset(&req, 0, sizeof(req));
-	memset(&upt, 0, sizeof(upt));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(0); /* nlmsg data is nothing */
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_FLUSHPOLICY;
+	struct xfrm_userpolicy_type upt = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "ptype") == 0) {
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 21ada3647ba48..333caf67b44c0 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -271,9 +271,24 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct xfrm_usersa_info xsinfo;
 		char			buf[RTA_BUF_SIZE];
-	} req;
-	struct xfrm_replay_state replay;
-	struct xfrm_replay_state_esn replay_esn;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.xsinfo = {
+			.family = preferred_family,
+			.lft = {
+				.soft_byte_limit = XFRM_INF,
+				.hard_byte_limit = XFRM_INF,
+				.soft_packet_limit = XFRM_INF,
+				.hard_packet_limit = XFRM_INF
+			}
+		}
+	};
+	struct xfrm_replay_state replay = { 0 };
+	struct xfrm_replay_state_esn replay_esn = { 0 };
 	__u32 replay_window = 0;
 	__u32 seq = 0, oseq = 0, seq_hi = 0, oseq_hi = 0;
 	char *idp = NULL;
@@ -288,22 +303,7 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 	struct {
 		struct xfrm_user_sec_ctx sctx;
 		char    str[CTX_BUF_SIZE];
-	} ctx;
-
-	memset(&req, 0, sizeof(req));
-	memset(&replay, 0, sizeof(replay));
-	memset(&replay_esn, 0, sizeof(replay_esn));
-	memset(&ctx, 0, sizeof(ctx));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsinfo));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.xsinfo.family = preferred_family;
-
-	req.xsinfo.lft.soft_byte_limit = XFRM_INF;
-	req.xsinfo.lft.hard_byte_limit = XFRM_INF;
-	req.xsinfo.lft.soft_packet_limit = XFRM_INF;
-	req.xsinfo.lft.hard_packet_limit = XFRM_INF;
+	} ctx = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
@@ -369,7 +369,7 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 				  (void *)&encap, sizeof(encap));
 		} else if (strcmp(*argv, "coa") == 0) {
 			inet_prefix coa;
-			xfrm_address_t xcoa;
+			xfrm_address_t xcoa = { 0 };
 
 			if (coap)
 				duparg("coa", *argv);
@@ -383,7 +383,6 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 			if (coa.bytelen > sizeof(xcoa))
 				invarg("value after \"coa\" is too large", *argv);
 
-			memset(&xcoa, 0, sizeof(xcoa));
 			memcpy(&xcoa, &coa.data, coa.bytelen);
 
 			addattr_l(&req.n, sizeof(req.buf), XFRMA_COADDR,
@@ -699,30 +698,31 @@ static int xfrm_state_allocspi(int argc, char **argv)
 		struct nlmsghdr	n;
 		struct xfrm_userspi_info xspi;
 		char			buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xspi)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_ALLOCSPI
+		},
+		.xspi = {
+			.info.family = preferred_family,
+#if 0
+			.lft = {
+				.soft_byte_limit = XFRM_INF,
+				.hard_byte_limit = XFRM_INF,
+				.soft_packet_limit = XFRM_INF,
+				.hard_packet_limit = XFRM_INF
+			}
+#endif
+		}
+	};
 	char *idp = NULL;
 	char *minp = NULL;
 	char *maxp = NULL;
 	struct xfrm_mark mark = {0, 0};
-	char res_buf[NLMSG_BUF_SIZE];
+	char res_buf[NLMSG_BUF_SIZE] = { 0 };
 	struct nlmsghdr *res_n = (struct nlmsghdr *)res_buf;
 
-	memset(res_buf, 0, sizeof(res_buf));
-
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xspi));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_ALLOCSPI;
-	req.xspi.info.family = preferred_family;
-
-#if 0
-	req.xsinfo.lft.soft_byte_limit = XFRM_INF;
-	req.xsinfo.lft.hard_byte_limit = XFRM_INF;
-	req.xsinfo.lft.soft_packet_limit = XFRM_INF;
-	req.xsinfo.lft.hard_packet_limit = XFRM_INF;
-#endif
-
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
 			NEXT_ARG();
@@ -956,18 +956,18 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 		struct nlmsghdr	n;
 		struct xfrm_usersa_id	xsid;
 		char			buf[RTA_BUF_SIZE];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsid)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = delete ? XFRM_MSG_DELSA : XFRM_MSG_GETSA
+		},
+		.xsid.family = preferred_family
+	};
 	struct xfrm_id id;
 	char *idp = NULL;
 	struct xfrm_mark mark = {0, 0};
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsid));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = delete ? XFRM_MSG_DELSA : XFRM_MSG_GETSA;
-	req.xsid.family = preferred_family;
-
 	while (argc > 0) {
 		xfrm_address_t saddr;
 
@@ -1014,11 +1014,9 @@ static int xfrm_state_get_or_delete(int argc, char **argv, int delete)
 		if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
 			exit(2);
 	} else {
-		char buf[NLMSG_BUF_SIZE];
+		char buf[NLMSG_BUF_SIZE] = { 0 };
 		struct nlmsghdr *res_n = (struct nlmsghdr *)buf;
 
-		memset(buf, 0, sizeof(buf));
-
 		if (rtnl_talk(&rth, &req.n, res_n, sizeof(req)) < 0)
 			exit(2);
 
@@ -1282,13 +1280,14 @@ static int xfrm_sad_getinfo(int argc, char **argv)
 		struct nlmsghdr			n;
 		__u32				flags;
 		char				ans[64];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.flags));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_GETSADINFO;
-	req.flags = 0XFFFFFFFF;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.flags)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_GETSADINFO
+		},
+		.flags = 0XFFFFFFFF
+	};
 
 	if (rtnl_open_byproto(&rth, 0, NETLINK_XFRM) < 0)
 		exit(1);
@@ -1309,16 +1308,15 @@ static int xfrm_state_flush(int argc, char **argv)
 	struct {
 		struct nlmsghdr			n;
 		struct xfrm_usersa_flush	xsf;
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsf)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = XFRM_MSG_FLUSHSA
+		}
+	};
 	char *protop = NULL;
 
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsf));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = XFRM_MSG_FLUSHSA;
-	req.xsf.proto = 0;
-
 	while (argc > 0) {
 		if (strcmp(*argv, "proto") == 0) {
 			int ret;
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 0adcbf3f6e389..14134034633f8 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -112,19 +112,21 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
 		/* attribute has to be NLMSG aligned */
 		struct rtattr ext_req __attribute__ ((aligned(NLMSG_ALIGNTO)));
 		__u32 ext_filter_mask;
-	} req;
+	} req = {
+		.nlh = {
+			.nlmsg_len = sizeof(req),
+			.nlmsg_type = type,
+			.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+		},
+		.ifm.ifi_family = family,
+		.ext_req = {
+			.rta_type = IFLA_EXT_MASK,
+			.rta_len = RTA_LENGTH(sizeof(__u32))
+		},
+		.ext_filter_mask = filt_mask
+	};
 
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = sizeof(req);
-	req.nlh.nlmsg_type = type;
-	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
-	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
-	req.ifm.ifi_family = family;
-
-	req.ext_req.rta_type = IFLA_EXT_MASK;
-	req.ext_req.rta_len = RTA_LENGTH(sizeof(__u32));
-	req.ext_filter_mask = filt_mask;
 
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
@@ -136,19 +138,20 @@ int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int family, int type,
 		struct nlmsghdr nlh;
 		struct ifinfomsg ifm;
 		char buf[1024];
-	} req;
+	} req = {
+		.nlh = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+			.nlmsg_type = type,
+			.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST,
+		},
+		.ifm.ifi_family = family
+	};
 	int err;
 
 	if (!filter_fn)
 		return -EINVAL;
 
-	memset(&req, 0, sizeof(req));
-	req.nlh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
-	req.nlh.nlmsg_type = type;
-	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
-	req.nlh.nlmsg_pid = 0;
 	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
-	req.ifm.ifi_family = family;
 
 	err = filter_fn(&req.nlh, sizeof(req));
 	if (err)
@@ -197,7 +200,11 @@ int rtnl_send_check(struct rtnl_handle *rth, const void *buf, int len)
 
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 {
-	struct nlmsghdr nlh;
+	struct nlmsghdr nlh = {
+		.nlmsg_len = NLMSG_LENGTH(len),
+		.nlmsg_type = type,
+		.nlmsg_flags = NLM_F_DUMP | NLM_F_REQUEST,
+	};
 	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	struct iovec iov[2] = {
 		{ .iov_base = &nlh, .iov_len = sizeof(nlh) },
@@ -205,15 +212,11 @@ int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 	};
 	struct msghdr msg = {
 		.msg_name = &nladdr,
-		.msg_namelen = 	sizeof(nladdr),
+		.msg_namelen = sizeof(nladdr),
 		.msg_iov = iov,
 		.msg_iovlen = 2,
 	};
 
-	nlh.nlmsg_len = NLMSG_LENGTH(len);
-	nlh.nlmsg_type = type;
-	nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
-	nlh.nlmsg_pid = 0;
 	nlh.nlmsg_seq = rth->dump = ++rth->seq;
 
 	return sendmsg(rth->fd, &msg, 0);
@@ -365,7 +368,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	int status;
 	unsigned seq;
 	struct nlmsghdr *h;
-	struct sockaddr_nl nladdr;
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	struct iovec iov = {
 		.iov_base = (void*) n,
 		.iov_len = n->nlmsg_len
@@ -376,10 +379,7 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		.msg_iov = &iov,
 		.msg_iovlen = 1,
 	};
-	char   buf[32768];
-
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
+	char   buf[32768] = { 0 };
 
 	n->nlmsg_seq = seq = ++rtnl->seq;
 
@@ -392,8 +392,6 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 		return -1;
 	}
 
-	memset(buf,0,sizeof(buf));
-
 	iov.iov_base = buf;
 	while (1) {
 		iov.iov_len = sizeof(buf);
@@ -498,7 +496,7 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 {
 	int status;
 	struct nlmsghdr *h;
-	struct sockaddr_nl nladdr;
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	struct iovec iov;
 	struct msghdr msg = {
 		.msg_name = &nladdr,
@@ -514,11 +512,6 @@ int rtnl_listen(struct rtnl_handle *rtnl,
 		msg.msg_controllen = sizeof(cmsgbuf);
 	}
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-	nladdr.nl_pid = 0;
-	nladdr.nl_groups = 0;
-
 	iov.iov_base = buf;
 	while (1) {
 		struct rtnl_ctrl_data ctrl;
@@ -595,15 +588,10 @@ int rtnl_from_file(FILE *rtnl, rtnl_listen_filter_t handler,
 		   void *jarg)
 {
 	int status;
-	struct sockaddr_nl nladdr;
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	char   buf[16384];
 	struct nlmsghdr *h = (void*)buf;
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-	nladdr.nl_pid = 0;
-	nladdr.nl_groups = 0;
-
 	while (1) {
 		int err, len;
 		int l;
diff --git a/lib/ll_map.c b/lib/ll_map.c
index fa14a77605b1f..571d11e1cd6b5 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -103,7 +103,6 @@ int ll_remember_index(const struct sockaddr_nl *who,
 		return 0;
 	}
 
-	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), IFLA_PAYLOAD(n));
 	ifname = rta_getattr_str(tb[IFLA_IFNAME]);
 	if (ifname == NULL)
diff --git a/misc/arpd.c b/misc/arpd.c
index 65c03cd2b422d..1a0710a811731 100644
--- a/misc/arpd.c
+++ b/misc/arpd.c
@@ -179,16 +179,22 @@ static void undo_sysctl_adjustments(void)
 
 static int send_probe(int ifindex, __u32 addr)
 {
-	struct ifreq ifr;
-	struct sockaddr_in dst;
+	struct ifreq ifr = { .ifr_ifindex = ifindex };
+	struct sockaddr_in dst = {
+		.sin_family = AF_INET,
+		.sin_port = htons(1025),
+		.sin_addr.s_addr = addr
+	};
 	socklen_t len;
 	unsigned char buf[256];
 	struct arphdr *ah = (struct arphdr *)buf;
 	unsigned char *p = (unsigned char *)(ah+1);
-	struct sockaddr_ll sll;
+	struct sockaddr_ll sll = {
+		.sll_family = AF_PACKET,
+		.sll_ifindex = ifindex,
+		.sll_protocol = htons(ETH_P_ARP)
+	};
 
-	memset(&ifr, 0, sizeof(ifr));
-	ifr.ifr_ifindex = ifindex;
 	if (ioctl(udp_sock, SIOCGIFNAME, &ifr))
 		return -1;
 	if (ioctl(udp_sock, SIOCGIFHWADDR, &ifr))
@@ -198,9 +204,6 @@ static int send_probe(int ifindex, __u32 addr)
 	if (setsockopt(udp_sock, SOL_SOCKET, SO_BINDTODEVICE, ifr.ifr_name, strlen(ifr.ifr_name)+1) < 0)
 		return -1;
 
-	dst.sin_family = AF_INET;
-	dst.sin_port = htons(1025);
-	dst.sin_addr.s_addr = addr;
 	if (connect(udp_sock, (struct sockaddr *)&dst, sizeof(dst)) < 0)
 		return -1;
 	len = sizeof(dst);
@@ -219,10 +222,7 @@ static int send_probe(int ifindex, __u32 addr)
 	memcpy(p, &dst.sin_addr, 4);
 	p += 4;
 
-	sll.sll_family = AF_PACKET;
 	memset(sll.sll_addr, 0xFF, sizeof(sll.sll_addr));
-	sll.sll_ifindex = ifindex;
-	sll.sll_protocol = htons(ETH_P_ARP);
 	memcpy(p, &sll.sll_addr, ah->ar_hln);
 	p += ah->ar_hln;
 
@@ -268,18 +268,19 @@ static int respond_to_kernel(int ifindex, __u32 addr, char *lla, int llalen)
 		struct nlmsghdr	n;
 		struct ndmsg		ndm;
 		char			buf[256];
-	} req;
-
-	memset(&req.n, 0, sizeof(req.n));
-	memset(&req.ndm, 0, sizeof(req.ndm));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST;
-	req.n.nlmsg_type = RTM_NEWNEIGH;
-	req.ndm.ndm_family = AF_INET;
-	req.ndm.ndm_state = NUD_STALE;
-	req.ndm.ndm_ifindex = ifindex;
-	req.ndm.ndm_type = RTN_UNICAST;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg)),
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_type = RTM_NEWNEIGH
+		},
+		.ndm = {
+			.ndm_family = AF_INET,
+			.ndm_state = NUD_STALE,
+			.ndm_ifindex = ifindex,
+			.ndm_type = RTN_UNICAST
+		}
+	};
 
 	addattr_l(&req.n, sizeof(req), NDA_DST, &addr, 4);
 	addattr_l(&req.n, sizeof(req), NDA_LLADDR, lla, llalen);
@@ -440,7 +441,7 @@ static void get_kern_msg(void)
 {
 	int status;
 	struct nlmsghdr *h;
-	struct sockaddr_nl nladdr;
+	struct sockaddr_nl nladdr = { 0 };
 	struct iovec iov;
 	char   buf[8192];
 	struct msghdr msg = {
@@ -450,8 +451,6 @@ static void get_kern_msg(void)
 		0
 	};
 
-	memset(&nladdr, 0, sizeof(nladdr));
-
 	iov.iov_base = buf;
 	iov.iov_len = sizeof(buf);
 
@@ -539,10 +538,8 @@ static void get_arp_pkt(void)
 
 static void catch_signal(int sig, void (*handler)(int))
 {
-	struct sigaction sa;
+	struct sigaction sa = { .sa_handler = handler };
 
-	memset(&sa, 0, sizeof(sa));
-	sa.sa_handler = handler;
 #ifdef SA_INTERRUPT
 	sa.sa_flags = SA_INTERRUPT;
 #endif
@@ -668,9 +665,8 @@ int main(int argc, char **argv)
 
 	if (ifnum) {
 		int i;
-		struct ifreq ifr;
+		struct ifreq ifr = { 0 };
 
-		memset(&ifr, 0, sizeof(ifr));
 		for (i = 0; i < ifnum; i++) {
 			strncpy(ifr.ifr_name, ifnames[i], IFNAMSIZ);
 			if (ioctl(udp_sock, SIOCGIFINDEX, &ifr)) {
@@ -772,12 +768,12 @@ int main(int argc, char **argv)
 	}
 
 	if (1) {
-		struct sockaddr_ll sll;
+		struct sockaddr_ll sll = {
+			.sll_family = AF_PACKET,
+			.sll_protocol = htons(ETH_P_ARP),
+			.sll_ifindex = (ifnum == 1 ? ifvec[0] : 0)
+		};
 
-		memset(&sll, 0, sizeof(sll));
-		sll.sll_family = AF_PACKET;
-		sll.sll_protocol = htons(ETH_P_ARP);
-		sll.sll_ifindex = (ifnum == 1 ? ifvec[0] : 0);
 		if (bind(pset[0].fd, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
 			perror("bind");
 			goto do_abort;
diff --git a/misc/ss.c b/misc/ss.c
index 9c456d4f1c324..7d3aeb612b741 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2103,11 +2103,21 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f, int protocol)
 
 static int tcpdiag_send(int fd, int protocol, struct filter *f)
 {
-	struct sockaddr_nl nladdr;
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	struct {
 		struct nlmsghdr nlh;
 		struct inet_diag_req r;
-	} req;
+	} req = {
+		.nlh = {
+			.nlmsg_len = sizeof(req),
+			.nlmsg_flags = NLM_F_ROOT | NLM_F_MATCH | NLM_F_REQUEST,
+			.nlmsg_seq = MAGIC_SEQ
+		},
+		.r = {
+			.idiag_family = AF_INET,
+			.idiag_states = f->states
+		}
+	};
 	char    *bc = NULL;
 	int	bclen;
 	struct msghdr msg;
@@ -2117,20 +2127,10 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 	if (protocol == IPPROTO_UDP)
 		return -1;
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-
-	req.nlh.nlmsg_len = sizeof(req);
 	if (protocol == IPPROTO_TCP)
 		req.nlh.nlmsg_type = TCPDIAG_GETSOCK;
 	else
 		req.nlh.nlmsg_type = DCCPDIAG_GETSOCK;
-	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
-	req.nlh.nlmsg_pid = 0;
-	req.nlh.nlmsg_seq = MAGIC_SEQ;
-	memset(&req.r, 0, sizeof(req.r));
-	req.r.idiag_family = AF_INET;
-	req.r.idiag_states = f->states;
 	if (show_mem) {
 		req.r.idiag_ext |= (1<<(INET_DIAG_MEMINFO-1));
 		req.r.idiag_ext |= (1<<(INET_DIAG_SKMEMINFO-1));
@@ -2172,8 +2172,7 @@ static int tcpdiag_send(int fd, int protocol, struct filter *f)
 
 static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 {
-	struct sockaddr_nl nladdr;
-
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
 	DIAG_REQUEST(req, struct inet_diag_req_v2 r);
 	char    *bc = NULL;
 	int	bclen;
@@ -2184,9 +2183,6 @@ static int sockdiag_send(int family, int fd, int protocol, struct filter *f)
 	if (family == PF_UNSPEC)
 		return tcpdiag_send(fd, protocol, f);
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-
 	memset(&req.r, 0, sizeof(req.r));
 	req.r.sdiag_family = family;
 	req.r.sdiag_protocol = protocol;
@@ -2664,14 +2660,13 @@ static void unix_stats_print(struct sockstat *list, struct filter *f)
 		}
 
 		if (use_proc && f->f) {
-			struct sockstat st;
+			struct sockstat st = {
+				.local.family = AF_UNIX,
+				.remote.family = AF_UNIX
+			};
 
-			st.local.family = AF_UNIX;
-			st.remote.family = AF_UNIX;
 			memcpy(st.local.data, &s->name, sizeof(s->name));
-			if (strcmp(peer, "*") == 0)
-				memset(st.remote.data, 0, sizeof(peer));
-			else
+			if (strcmp(peer, "*"))
 				memcpy(st.remote.data, &peer, sizeof(peer));
 			if (run_ssfilter(f->f, &st) == 0)
 				continue;
diff --git a/tc/e_bpf.c b/tc/e_bpf.c
index 2d650a46c2181..6c5031543cafe 100644
--- a/tc/e_bpf.c
+++ b/tc/e_bpf.c
@@ -56,8 +56,8 @@ static int parse_bpf(struct exec_util *eu, int argc, char **argv)
 	char **argv_run = argv_default, **envp_run, *tmp;
 	int ret, i, env_old, env_num, env_map;
 	const char *bpf_uds_name = NULL;
-	int fds[BPF_SCM_MAX_FDS];
-	struct bpf_map_aux aux;
+	int fds[BPF_SCM_MAX_FDS] = { 0 };
+	struct bpf_map_aux aux = { 0 };
 
 	if (argc == 0)
 		return 0;
@@ -115,9 +115,6 @@ static int parse_bpf(struct exec_util *eu, int argc, char **argv)
 		return -1;
 	}
 
-	memset(fds, 0, sizeof(fds));
-	memset(&aux, 0, sizeof(aux));
-
 	ret = bpf_recv_map_fds(bpf_uds_name, fds, &aux, ARRAY_SIZE(fds));
 	if (ret < 0) {
 		fprintf(stderr, "bpf: Could not receive fds!\n");
diff --git a/tc/em_cmp.c b/tc/em_cmp.c
index fd8bd028c1c66..510e760591ab6 100644
--- a/tc/em_cmp.c
+++ b/tc/em_cmp.c
@@ -44,9 +44,7 @@ static int cmp_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 	int align, opnd = 0;
 	unsigned long offset = 0, layer = TCF_LAYER_NETWORK, mask = 0, value = 0;
 	int offset_present = 0, value_present = 0;
-	struct tcf_em_cmp cmp;
-
-	memset(&cmp, 0, sizeof(cmp));
+	struct tcf_em_cmp cmp = { 0 };
 
 #define PARSE_ERR(CARG, FMT, ARGS...) \
 	em_parse_error(EINVAL, args, CARG, &cmp_ematch_util, FMT, ##ARGS)
diff --git a/tc/em_ipset.c b/tc/em_ipset.c
index 806a79c781824..41c4672daf445 100644
--- a/tc/em_ipset.c
+++ b/tc/em_ipset.c
@@ -198,11 +198,9 @@ static void ipset_print_usage(FILE *fd)
 static int ipset_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 			    struct bstr *args)
 {
-	struct xt_set_info set_info;
+	struct xt_set_info set_info = { 0 };
 	int ret;
 
-	memset(&set_info, 0, sizeof(set_info));
-
 #define PARSE_ERR(CARG, FMT, ARGS...) \
 	em_parse_error(EINVAL, args, CARG, &ipset_ematch_util, FMT, ##ARGS)
 
diff --git a/tc/em_meta.c b/tc/em_meta.c
index 9ce5a78a628ac..37959f91c4445 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -361,11 +361,9 @@ static int meta_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 {
 	int opnd;
 	struct bstr *a;
-	struct tcf_meta_hdr meta_hdr;
+	struct tcf_meta_hdr meta_hdr = { 0 };
 	unsigned long lvalue = 0, rvalue = 0;
 
-	memset(&meta_hdr, 0, sizeof(meta_hdr));
-
 	if (args == NULL)
 		return PARSE_ERR(args, "meta: missing arguments");
 
diff --git a/tc/em_nbyte.c b/tc/em_nbyte.c
index 76dd8573eb7ce..075fcd7b216bb 100644
--- a/tc/em_nbyte.c
+++ b/tc/em_nbyte.c
@@ -44,9 +44,7 @@ static int nbyte_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 	struct bstr *needle = args;
 	unsigned long offset = 0, layer = TCF_LAYER_NETWORK;
 	int offset_present = 0;
-	struct tcf_em_nbyte nb;
-
-	memset(&nb, 0, sizeof(nb));
+	struct tcf_em_nbyte nb = { 0 };
 
 #define PARSE_ERR(CARG, FMT, ARGS...) \
 	em_parse_error(EINVAL, args, CARG, &nbyte_ematch_util, FMT, ##ARGS)
diff --git a/tc/em_u32.c b/tc/em_u32.c
index 0369e15a377fa..36ffa132a7435 100644
--- a/tc/em_u32.c
+++ b/tc/em_u32.c
@@ -39,9 +39,7 @@ static int u32_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 	struct bstr *a;
 	int align, nh_len;
 	unsigned long key, mask, offmask = 0, offset;
-	struct tc_u32_key u_key;
-
-	memset(&u_key, 0, sizeof(u_key));
+	struct tc_u32_key u_key = { 0 };
 
 #define PARSE_ERR(CARG, FMT, ARGS...) \
 	em_parse_error(EINVAL, args, CARG, &u32_ematch_util, FMT, ##ARGS)
diff --git a/tc/f_flow.c b/tc/f_flow.c
index 6ee4dd5e50f1f..09ddcaa661796 100644
--- a/tc/f_flow.c
+++ b/tc/f_flow.c
@@ -133,7 +133,6 @@ out:
 static int flow_parse_opt(struct filter_util *fu, char *handle,
 			  int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_police tp;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	__u32 mask = ~0U, xor = 0;
@@ -141,8 +140,6 @@ static int flow_parse_opt(struct filter_util *fu, char *handle,
 	__u32 mode = FLOW_MODE_MAP;
 	__u32 tmp;
 
-	memset(&tp, 0, sizeof(tp));
-
 	if (handle) {
 		if (get_u32(&t->tcm_handle, handle, 0)) {
 			fprintf(stderr, "Illegal \"handle\"\n");
diff --git a/tc/f_flower.c b/tc/f_flower.c
index fd2014b374a1e..fe543f522ca35 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -197,10 +197,9 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle, 4);
 		} else if (matches(*argv, "indev") == 0) {
-			char ifname[IFNAMSIZ];
+			char ifname[IFNAMSIZ] = { 0 };
 
 			NEXT_ARG();
-			memset(ifname, 0, sizeof(ifname));
 			strncpy(ifname, *argv, sizeof(ifname) - 1);
 			addattrstrz(n, MAX_MSG, TCA_FLOWER_INDEV, ifname);
 		} else if (matches(*argv, "dst_mac") == 0) {
diff --git a/tc/f_fw.c b/tc/f_fw.c
index ff9648c512132..b6cb609882cb3 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -33,14 +33,11 @@ static void explain(void)
 
 static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_police tp;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	__u32 mask = 0;
 	int mask_set = 0;
 
-	memset(&tp, 0, sizeof(tp));
-
 	if (handle) {
 		char *slash;
 
@@ -94,9 +91,8 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 			}
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
-			char d[IFNAMSIZ+1];
+			char d[IFNAMSIZ+1] = { 0 };
 
-			memset(d, 0, sizeof(d));
 			argc--;
 			argv++;
 			if (argc < 1) {
diff --git a/tc/f_route.c b/tc/f_route.c
index 4d9f4dcef3b01..5c600b9bddebd 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -36,14 +36,11 @@ static void explain(void)
 
 static int route_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_police tp;
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	__u32 fh = 0xFFFF8000;
 	__u32 order = 0;
 
-	memset(&tp, 0, sizeof(tp));
-
 	if (handle) {
 		if (get_u32(&t->tcm_handle, handle, 0)) {
 			fprintf(stderr, "Illegal \"handle\"\n");
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index e7dcc774cd3f3..c03e73eadf36d 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -173,15 +173,11 @@ done:
 static int rsvp_parse_opt(struct filter_util *qu, char *handle, int argc, char **argv, struct nlmsghdr *n)
 {
 	int family = strcmp(qu->id, "rsvp") == 0 ? AF_INET : AF_INET6;
-	struct tc_rsvp_pinfo pinfo;
-	struct tc_police tp;
+	struct tc_rsvp_pinfo pinfo = { 0 };
 	struct tcmsg *t = NLMSG_DATA(n);
 	int pinfo_ok = 0;
 	struct rtattr *tail;
 
-	memset(&pinfo, 0, sizeof(pinfo));
-	memset(&tp, 0, sizeof(tp));
-
 	if (handle) {
 		if (get_u32(&t->tcm_handle, handle, 0)) {
 			fprintf(stderr, "Illegal \"handle\"\n");
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 0926461dc9285..e8fde52f9788f 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -988,7 +988,7 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 	struct {
 		struct tc_u32_sel sel;
 		struct tc_u32_key keys[128];
-	} sel;
+	} sel = { 0 };
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	int sel_ok = 0, terminal_ok = 0;
@@ -997,8 +997,6 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 	__u32 order = 0;
 	__u32 flags = 0;
 
-	memset(&sel, 0, sizeof(sel));
-
 	if (handle && get_u32_handle(&t->tcm_handle, handle)) {
 		fprintf(stderr, "Illegal filter ID\n");
 		return -1;
@@ -1093,12 +1091,11 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 		} else if (strcmp(*argv, "sample") == 0) {
 			__u32 hash;
 			unsigned int divisor = 0x100;
-
 			struct {
 				struct tc_u32_sel sel;
 				struct tc_u32_key keys[4];
-			} sel2;
-			memset(&sel2, 0, sizeof(sel2));
+			} sel2 = { 0 };
+
 			NEXT_ARG();
 			if (parse_selector(&argc, &argv, &sel2.sel, n)) {
 				fprintf(stderr, "Illegal \"sample\"\n");
@@ -1125,9 +1122,8 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			sample_ok = 1;
 			continue;
 		} else if (strcmp(*argv, "indev") == 0) {
-			char ind[IFNAMSIZ + 1];
+			char ind[IFNAMSIZ + 1] = { 0 };
 
-			memset(ind, 0, sizeof(ind));
 			argc--;
 			argv++;
 			if (argc < 1) {
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 37cd0d80b02f3..20da11d07adae 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -63,7 +63,7 @@ static int bpf_parse_opt(struct action_util *a, int *ptr_argc, char ***ptr_argv,
 			 int tca_id, struct nlmsghdr *n)
 {
 	const char *bpf_obj = NULL, *bpf_uds_name = NULL;
-	struct tc_act_bpf parm;
+	struct tc_act_bpf parm = { .action = TC_ACT_PIPE };
 	bool seen_run = false;
 	struct rtattr *tail;
 	int argc, ret = 0;
@@ -104,9 +104,6 @@ opt_bpf:
 		NEXT_ARG_FWD();
 	}
 
-	memset(&parm, 0, sizeof(parm));
-	parm.action = TC_ACT_PIPE;
-
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			parm.action = TC_ACT_RECLASSIFY;
diff --git a/tc/m_csum.c b/tc/m_csum.c
index fb1183a983c39..b38d494752116 100644
--- a/tc/m_csum.c
+++ b/tc/m_csum.c
@@ -85,15 +85,13 @@ static int
 parse_csum(struct action_util *a, int *argc_p,
 	   char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
-	struct tc_csum sel;
+	struct tc_csum sel = { 0 };
 
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0;
 	struct rtattr *tail;
 
-	memset(&sel, 0, sizeof(sel));
-
 	while (argc > 0) {
 		if (matches(*argv, "csum") == 0) {
 			NEXT_ARG();
diff --git a/tc/m_ematch.c b/tc/m_ematch.c
index 251f5aa19f627..e18a395b048e6 100644
--- a/tc/m_ematch.c
+++ b/tc/m_ematch.c
@@ -177,9 +177,7 @@ static int parse_tree(struct nlmsghdr *n, struct ematch *tree)
 
 	for (t = tree; t; t = t->next) {
 		struct rtattr *tail = NLMSG_TAIL(n);
-		struct tcf_ematch_hdr hdr = {
-			.flags = t->relation
-		};
+		struct tcf_ematch_hdr hdr = { .flags = t->relation };
 
 		if (t->inverted)
 			hdr.flags |= TCF_EM_INVERT;
diff --git a/tc/m_gact.c b/tc/m_gact.c
index b22ce19156f3c..ea2c9ec825146 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -97,16 +97,13 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 	char **argv = *argv_p;
 	int ok = 0;
 	int action = TC_POLICE_RECLASSIFY;
-	struct tc_gact p;
+	struct tc_gact p = { .action = TC_POLICE_RECLASSIFY };
 #ifdef CONFIG_GACT_PROB
 	int rd = 0;
 	struct tc_gact_p pp;
 #endif
 	struct rtattr *tail;
 
-	memset(&p, 0, sizeof(p));
-	p.action = TC_POLICE_RECLASSIFY;
-
 	if (argc < 0)
 		return -1;
 
diff --git a/tc/m_ife.c b/tc/m_ife.c
index c8ae04d30e16c..eaab1cc85513d 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -56,7 +56,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0;
-	struct tc_ife p;
+	struct tc_ife p = { .action = TC_ACT_PIPE };	/* good default */
 	struct rtattr *tail;
 	struct rtattr *tail2;
 	char dbuf[ETH_ALEN];
@@ -69,9 +69,6 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	char *daddr = NULL;
 	char *saddr = NULL;
 
-	memset(&p, 0, sizeof(p));
-	p.action = TC_ACT_PIPE;	/* good default */
-
 	if (argc <= 0)
 		return -1;
 
diff --git a/tc/m_mirred.c b/tc/m_mirred.c
index 64aad4d22ac90..267034a76b54e 100644
--- a/tc/m_mirred.c
+++ b/tc/m_mirred.c
@@ -69,12 +69,9 @@ parse_egress(struct action_util *a, int *argc_p, char ***argv_p,
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0, iok = 0, mirror = 0, redir = 0;
-	struct tc_mirred p;
+	struct tc_mirred p = { 0 };
 	struct rtattr *tail;
-	char d[16];
-
-	memset(d, 0, sizeof(d)-1);
-	memset(&p, 0, sizeof(struct tc_mirred));
+	char d[16] = { 0 };
 
 	while (argc > 0) {
 
diff --git a/tc/m_nat.c b/tc/m_nat.c
index 4d1b1edfeeec3..7f8c4dffb4d43 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -84,15 +84,13 @@ bad_val:
 static int
 parse_nat(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
 {
-	struct tc_nat sel;
+	struct tc_nat sel = { 0 };
 
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0;
 	struct rtattr *tail;
 
-	memset(&sel, 0, sizeof(sel));
-
 	while (argc > 0) {
 		if (matches(*argv, "nat") == 0) {
 			NEXT_ARG();
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 64533060cc47b..c8f6d7c8e5ad7 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -392,7 +392,7 @@ done:
 
 static int parse_munge(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel)
 {
-	struct tc_pedit_key tkey;
+	struct tc_pedit_key tkey = { 0 };
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int res = -1;
@@ -400,8 +400,6 @@ static int parse_munge(int *argc_p, char ***argv_p, struct tc_pedit_sel *sel)
 	if (argc <= 0)
 		return -1;
 
-	memset(&tkey, 0, sizeof(tkey));
-
 	if (matches(*argv, "offset") == 0) {
 		NEXT_ARG();
 		res = parse_offset(&argc, &argv, sel, &tkey);
@@ -442,15 +440,13 @@ int parse_pedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	struct {
 		struct tc_pedit_sel sel;
 		struct tc_pedit_key keys[MAX_OFFS];
-	} sel;
+	} sel = { 0 };
 
 	int argc = *argc_p;
 	char **argv = *argv_p;
 	int ok = 0, iok = 0;
 	struct rtattr *tail;
 
-	memset(&sel, 0, sizeof(sel));
-
 	while (argc > 0) {
 		if (pedit_debug > 1)
 			fprintf(stderr, "while pedit (%d:%s)\n", argc, *argv);
diff --git a/tc/m_police.c b/tc/m_police.c
index a8b65dd9cd429..9ae25f2888202 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -127,7 +127,7 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
 	char **argv = *argv_p;
 	int res = -1;
 	int ok = 0;
-	struct tc_police p;
+	struct tc_police p = { .action = TC_POLICE_RECLASSIFY };
 	__u32 rtab[256];
 	__u32 ptab[256];
 	__u32 avrate = 0;
@@ -138,9 +138,6 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
 	int Rcell_log =  -1, Pcell_log = -1;
 	struct rtattr *tail;
 
-	memset(&p, 0, sizeof(p));
-	p.action = TC_POLICE_RECLASSIFY;
-
 	if (a) /* new way of doing things */
 		NEXT_ARG();
 
diff --git a/tc/q_atm.c b/tc/q_atm.c
index a5b716fc5ed9a..a83d1ba7fb3a6 100644
--- a/tc/q_atm.c
+++ b/tc/q_atm.c
@@ -47,7 +47,7 @@ static void explain(void)
 static int atm_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
    struct nlmsghdr *n)
 {
-	struct sockaddr_atmsvc addr;
+	struct sockaddr_atmsvc addr = { 0 };
 	struct atm_qos qos;
 	struct atm_sap sap;
 	unsigned char hdr[MAX_HDR_LEN];
@@ -58,7 +58,6 @@ static int atm_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 	int set_clip = 0;
 	int s;
 
-	memset(&addr, 0, sizeof(addr));
 	(void) text2qos("aal5,ubr:sdu=9180,rx:none", &qos, 0);
 	(void) text2sap("blli:l2=iso8802", &sap, 0);
 	while (argc > 0) {
diff --git a/tc/q_cbq.c b/tc/q_cbq.c
index faad735045aa8..72fcfbce66903 100644
--- a/tc/q_cbq.c
+++ b/tc/q_cbq.c
@@ -49,8 +49,8 @@ static void explain1(char *arg)
 
 static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_ratespec r;
-	struct tc_cbq_lssopt lss;
+	struct tc_ratespec r = { 0 };
+	struct tc_cbq_lssopt lss = { 0 };
 	__u32 rtab[256];
 	unsigned mpu = 0, avpkt = 0, allot = 0;
 	unsigned short overhead = 0;
@@ -59,9 +59,6 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	int ewma_log =  -1;
 	struct rtattr *tail;
 
-	memset(&lss, 0, sizeof(lss));
-	memset(&r, 0, sizeof(r));
-
 	while (argc > 0) {
 		if (matches(*argv, "bandwidth") == 0 ||
 		    matches(*argv, "rate") == 0) {
@@ -183,11 +180,10 @@ static int cbq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int wrr_ok = 0, fopt_ok = 0;
-	struct tc_ratespec r;
-	struct tc_cbq_lssopt lss;
-	struct tc_cbq_wrropt wrr;
-	struct tc_cbq_fopt fopt;
-	struct tc_cbq_ovl ovl;
+	struct tc_ratespec r = { 0 };
+	struct tc_cbq_lssopt lss = { 0 };
+	struct tc_cbq_wrropt wrr = { 0 };
+	struct tc_cbq_fopt fopt = { 0 };
 	__u32 rtab[256];
 	unsigned mpu = 0;
 	int cell_log =  -1;
@@ -198,12 +194,6 @@ static int cbq_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, str
 	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
 
-	memset(&r, 0, sizeof(r));
-	memset(&lss, 0, sizeof(lss));
-	memset(&wrr, 0, sizeof(wrr));
-	memset(&fopt, 0, sizeof(fopt));
-	memset(&ovl, 0, sizeof(ovl));
-
 	while (argc > 0) {
 		if (matches(*argv, "rate") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_choke.c b/tc/q_choke.c
index e983bb50e739c..9ae8b588e40db 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -34,7 +34,7 @@ static void explain(void)
 static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			   struct nlmsghdr *n)
 {
-	struct tc_red_qopt opt;
+	struct tc_red_qopt opt = { 0 };
 	unsigned int burst = 0;
 	unsigned int avpkt = 1000;
 	double probability = 0.02;
@@ -45,8 +45,6 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	__u32 max_P;
 	struct rtattr *tail;
 
-	memset(&opt, 0, sizeof(opt));
-
 	while (argc > 0) {
 		if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_codel.c b/tc/q_codel.c
index 9221b48b6e01b..323e88d80e4c9 100644
--- a/tc/q_codel.c
+++ b/tc/q_codel.c
@@ -175,7 +175,7 @@ static int codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 static int codel_print_xstats(struct qdisc_util *qu, FILE *f,
 			      struct rtattr *xstats)
 {
-	struct tc_codel_xstats _st, *st;
+	struct tc_codel_xstats _st = { 0 }, *st;
 
 	SPRINT_BUF(b1);
 
@@ -184,7 +184,6 @@ static int codel_print_xstats(struct qdisc_util *qu, FILE *f,
 
 	st = RTA_DATA(xstats);
 	if (RTA_PAYLOAD(xstats) < sizeof(*st)) {
-		memset(&_st, 0, sizeof(_st));
 		memcpy(&_st, st, RTA_PAYLOAD(xstats));
 		st = &_st;
 	}
diff --git a/tc/q_dsmark.c b/tc/q_dsmark.c
index ab7b4d43903e6..79dfd9a27e343 100644
--- a/tc/q_dsmark.c
+++ b/tc/q_dsmark.c
@@ -128,7 +128,6 @@ static int dsmark_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct rtattr *tb[TCA_DSMARK_MAX+1];
 
 	if (!opt) return 0;
-	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, TCA_DSMARK_MAX, RTA_DATA(opt), RTA_PAYLOAD(opt));
 	if (tb[TCA_DSMARK_MASK]) {
 		if (!RTA_PAYLOAD(tb[TCA_DSMARK_MASK]))
diff --git a/tc/q_fifo.c b/tc/q_fifo.c
index f7fc88b38818f..e36802eb362a4 100644
--- a/tc/q_fifo.c
+++ b/tc/q_fifo.c
@@ -31,9 +31,7 @@ static void explain(void)
 static int fifo_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok = 0;
-	struct tc_fifo_qopt opt;
-
-	memset(&opt, 0, sizeof(opt));
+	struct tc_fifo_qopt opt = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "limit") == 0) {
diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
index f813badaa3070..9959affab1d7d 100644
--- a/tc/q_fq_codel.c
+++ b/tc/q_fq_codel.c
@@ -220,7 +220,7 @@ static int fq_codel_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt
 static int fq_codel_print_xstats(struct qdisc_util *qu, FILE *f,
 				 struct rtattr *xstats)
 {
-	struct tc_fq_codel_xstats _st, *st;
+	struct tc_fq_codel_xstats _st = { 0 }, *st;
 
 	SPRINT_BUF(b1);
 
@@ -229,7 +229,6 @@ static int fq_codel_print_xstats(struct qdisc_util *qu, FILE *f,
 
 	st = RTA_DATA(xstats);
 	if (RTA_PAYLOAD(xstats) < sizeof(*st)) {
-		memset(&_st, 0, sizeof(_st));
 		memcpy(&_st, st, RTA_PAYLOAD(xstats));
 		st = &_st;
 	}
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index 9ebe323ed4f8d..9ea971361762b 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -73,9 +73,7 @@ explain1(char *arg)
 static int
 hfsc_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_hfsc_qopt qopt;
-
-	memset(&qopt, 0, sizeof(qopt));
+	struct tc_hfsc_qopt qopt = { 0 };
 
 	while (argc > 0) {
 		if (matches(*argv, "default") == 0) {
@@ -146,15 +144,10 @@ static int
 hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 		     struct nlmsghdr *n)
 {
-	struct tc_service_curve rsc, fsc, usc;
-	int rsc_ok, fsc_ok, usc_ok;
+	struct tc_service_curve rsc = { 0 }, fsc = { 0 }, usc = { 0 };
+	int rsc_ok = 0, fsc_ok = 0, usc_ok = 0;
 	struct rtattr *tail;
 
-	memset(&rsc, 0, sizeof(rsc));
-	memset(&fsc, 0, sizeof(fsc));
-	memset(&usc, 0, sizeof(usc));
-	rsc_ok = fsc_ok = usc_ok = 0;
-
 	while (argc > 0) {
 		if (matches(*argv, "rt") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_htb.c b/tc/q_htb.c
index 9c1a4f86f7c08..d06f030d31493 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -63,14 +63,13 @@ static void explain1(char *arg)
 static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	unsigned int direct_qlen = ~0U;
-	struct tc_htb_glob opt;
+	struct tc_htb_glob opt = {
+		.rate2quantum = 10,
+		.version = 3
+	};
 	struct rtattr *tail;
 	unsigned int i; char *p;
 
-	memset(&opt, 0, sizeof(opt));
-	opt.rate2quantum = 10;
-	opt.version = 3;
-
 	while (argc > 0) {
 		if (matches(*argv, "r2q") == 0) {
 			NEXT_ARG();
@@ -113,19 +112,17 @@ static int htb_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 static int htb_parse_class_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok = 0;
-	struct tc_htb_opt opt;
+	struct tc_htb_opt opt = { 0 };
 	__u32 rtab[256], ctab[256];
 	unsigned buffer = 0, cbuffer = 0;
 	int cell_log =  -1, ccell_log = -1;
-	unsigned int mtu;
+	unsigned int mtu = 1600; /* eth packet len */
 	unsigned short mpu = 0;
 	unsigned short overhead = 0;
 	unsigned int linklayer  = LINKLAYER_ETHERNET; /* Assume ethernet */
 	struct rtattr *tail;
 	__u64 ceil64 = 0, rate64 = 0;
 
-	memset(&opt, 0, sizeof(opt)); mtu = 1600; /* eth packet len */
-
 	while (argc > 0) {
 		if (matches(*argv, "prio") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_netem.c b/tc/q_netem.c
index 8fe220416225c..583eb6ee51a49 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -175,23 +175,17 @@ static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	int dist_size = 0;
 	struct rtattr *tail;
 	struct tc_netem_qopt opt = { .limit = 1000 };
-	struct tc_netem_corr cor;
-	struct tc_netem_reorder reorder;
-	struct tc_netem_corrupt corrupt;
+	struct tc_netem_corr cor = { 0 };
+	struct tc_netem_reorder reorder = { 0 };
+	struct tc_netem_corrupt corrupt = { 0 };
 	struct tc_netem_gimodel gimodel;
 	struct tc_netem_gemodel gemodel;
-	struct tc_netem_rate rate;
+	struct tc_netem_rate rate = { 0 };
 	__s16 *dist_data = NULL;
 	__u16 loss_type = NETEM_LOSS_UNSPEC;
-	int present[__TCA_NETEM_MAX];
+	int present[__TCA_NETEM_MAX] = { 0 };
 	__u64 rate64 = 0;
 
-	memset(&cor, 0, sizeof(cor));
-	memset(&reorder, 0, sizeof(reorder));
-	memset(&corrupt, 0, sizeof(corrupt));
-	memset(&rate, 0, sizeof(rate));
-	memset(present, 0, sizeof(present));
-
 	for ( ; argc > 0; --argc, ++argv) {
 		if (matches(*argv, "limit") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_red.c b/tc/q_red.c
index e015cbdaf2e80..a1a2a6f4fbdaf 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -35,7 +35,7 @@ static void explain(void)
 
 static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-	struct tc_red_qopt opt;
+	struct tc_red_qopt opt = { 0 };
 	unsigned int burst = 0;
 	unsigned int avpkt = 0;
 	double probability = 0.02;
@@ -45,8 +45,6 @@ static int red_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	__u32 max_P;
 	struct rtattr *tail;
 
-	memset(&opt, 0, sizeof(opt));
-
 	while (argc > 0) {
 		if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_sfb.c b/tc/q_sfb.c
index 3b6d45269a27e..4158c0966dcfd 100644
--- a/tc/q_sfb.c
+++ b/tc/q_sfb.c
@@ -51,17 +51,16 @@ static int get_prob(__u32 *val, const char *arg)
 static int sfb_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
-	struct tc_sfb_qopt opt;
+	struct tc_sfb_qopt opt = {
+		.rehash_interval = 600*1000,
+		.warmup_time = 60*1000,
+		.penalty_rate = 10,
+		.penalty_burst = 20,
+		.increment = (SFB_MAX_PROB + 1000) / 2000,
+		.decrement = (SFB_MAX_PROB + 10000) / 20000
+	};
 	struct rtattr *tail;
 
-	memset(&opt, 0, sizeof(opt));
-	opt.rehash_interval = 600*1000;
-	opt.warmup_time = 60*1000;
-	opt.penalty_rate = 10;
-	opt.penalty_burst = 20;
-	opt.increment = (SFB_MAX_PROB + 1000) / 2000;
-	opt.decrement = (SFB_MAX_PROB + 10000) / 20000;
-
 	while (argc > 0) {
 	    if (strcmp(*argv, "rehash") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_sfq.c b/tc/q_sfq.c
index 7d21652266ace..76da43da05b8e 100644
--- a/tc/q_sfq.c
+++ b/tc/q_sfq.c
@@ -38,14 +38,12 @@ static void explain(void)
 static int sfq_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok = 0, red = 0;
-	struct tc_sfq_qopt_v1 opt;
+	struct tc_sfq_qopt_v1 opt = { 0 };
 	unsigned int burst = 0;
 	int wlog;
 	unsigned int avpkt = 1000;
 	double probability = 0.02;
 
-	memset(&opt, 0, sizeof(opt));
-
 	while (argc > 0) {
 		if (strcmp(*argv, "quantum") == 0) {
 			NEXT_ARG();
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 4a0c5ac75232f..7a2346afdfa7e 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -39,7 +39,7 @@ static void explain1(const char *arg, const char *val)
 static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok = 0;
-	struct tc_tbf_qopt opt;
+	struct tc_tbf_qopt opt = { 0 };
 	__u32 rtab[256];
 	__u32 ptab[256];
 	unsigned buffer = 0, mtu = 0, mpu = 0, latency = 0;
@@ -49,8 +49,6 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	struct rtattr *tail;
 	__u64 rate64 = 0, prate64 = 0;
 
-	memset(&opt, 0, sizeof(opt));
-
 	while (argc > 0) {
 		if (matches(*argv, "limit") == 0) {
 			NEXT_ARG();
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 86c6069b68ec4..172adb2fed372 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -243,7 +243,7 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 				    int length)
 {
 	char file[PATH_MAX], buff[4096];
-	struct bpf_elf_map tmp, zero;
+	struct bpf_elf_map tmp = { 0 }, zero = { 0 };
 	unsigned int val;
 	FILE *fp;
 
@@ -255,7 +255,6 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 		return -EIO;
 	}
 
-	memset(&tmp, 0, sizeof(tmp));
 	while (fgets(buff, sizeof(buff), fp)) {
 		if (sscanf(buff, "map_type:\t%u", &val) == 1)
 			tmp.type = val;
@@ -274,7 +273,6 @@ static int bpf_map_selfcheck_pinned(int fd, const struct bpf_elf_map *map,
 	if (!memcmp(&tmp, map, length)) {
 		return 0;
 	} else {
-		memset(&zero, 0, sizeof(zero));
 		/* If kernel doesn't have eBPF-related fdinfo, we cannot do much,
 		 * so just accept it. We know we do have an eBPF fd and in this
 		 * case, everything is 0. It is guaranteed that no such map exists
@@ -468,6 +466,9 @@ static int bpf_obj_get(const char *pathname)
 	union bpf_attr attr;
 	char tmp[PATH_MAX];
 
+	memset(&attr, 0, sizeof(attr));
+	attr.pathname = bpf_ptr_to_u64(pathname);
+
 	if (strlen(pathname) > 2 && pathname[0] == 'm' &&
 	    pathname[1] == ':' && bpf_get_tc_dir()) {
 		snprintf(tmp, sizeof(tmp), "%s/%s",
@@ -475,9 +476,6 @@ static int bpf_obj_get(const char *pathname)
 		pathname = tmp;
 	}
 
-	memset(&attr, 0, sizeof(attr));
-	attr.pathname = bpf_ptr_to_u64(pathname);
-
 	return bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
 
@@ -1628,7 +1626,7 @@ static bool bpf_pinning_reserved(uint32_t pinning)
 static void bpf_hash_init(struct bpf_elf_ctx *ctx, const char *db_file)
 {
 	struct bpf_hash_entry *entry;
-	char subpath[PATH_MAX];
+	char subpath[PATH_MAX] = { 0 };
 	uint32_t pinning;
 	FILE *fp;
 	int ret;
@@ -1637,7 +1635,6 @@ static void bpf_hash_init(struct bpf_elf_ctx *ctx, const char *db_file)
 	if (!fp)
 		return;
 
-	memset(subpath, 0, sizeof(subpath));
 	while ((ret = bpf_read_pin_mapping(fp, &pinning, subpath))) {
 		if (ret == -1) {
 			fprintf(stderr, "Database %s is corrupted at: %s\n",
@@ -1864,16 +1861,16 @@ static int
 bpf_map_set_send(int fd, struct sockaddr_un *addr, unsigned int addr_len,
 		 const struct bpf_map_data *aux, unsigned int entries)
 {
-	struct bpf_map_set_msg msg;
+	struct bpf_map_set_msg msg = {
+		.aux = {
+			.uds_ver = BPF_SCM_AUX_VER,
+			.num_ent = entries
+		}
+	};
 	int *cmsg_buf, min_fd;
 	char *amsg_buf;
 	int i;
 
-	memset(&msg, 0, sizeof(msg));
-
-	msg.aux.uds_ver = BPF_SCM_AUX_VER;
-	msg.aux.num_ent = entries;
-
 	strncpy(msg.aux.obj_name, aux->obj, sizeof(msg.aux.obj_name));
 	memcpy(&msg.aux.obj_st, aux->st, sizeof(msg.aux.obj_st));
 
@@ -1947,8 +1944,13 @@ bpf_map_set_recv(int fd, int *fds,  struct bpf_map_aux *aux,
 int bpf_send_map_fds(const char *path, const char *obj)
 {
 	struct bpf_elf_ctx *ctx = &__ctx;
-	struct sockaddr_un addr;
-	struct bpf_map_data bpf_aux;
+	struct sockaddr_un addr = { .sun_family = AF_UNIX };
+	struct bpf_map_data bpf_aux = {
+		.fds = ctx->map_fds,
+		.ent = ctx->maps,
+		.st  = &ctx->stat,
+		.obj = obj
+	};
 	int fd, ret;
 
 	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
@@ -1958,8 +1960,6 @@ int bpf_send_map_fds(const char *path, const char *obj)
 		return -1;
 	}
 
-	memset(&addr, 0, sizeof(addr));
-	addr.sun_family = AF_UNIX;
 	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
 
 	ret = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
@@ -1969,13 +1969,6 @@ int bpf_send_map_fds(const char *path, const char *obj)
 		return -1;
 	}
 
-	memset(&bpf_aux, 0, sizeof(bpf_aux));
-
-	bpf_aux.fds = ctx->map_fds;
-	bpf_aux.ent = ctx->maps;
-	bpf_aux.st  = &ctx->stat;
-	bpf_aux.obj = obj;
-
 	ret = bpf_map_set_send(fd, &addr, sizeof(addr), &bpf_aux,
 			       bpf_maps_count(ctx));
 	if (ret < 0)
@@ -1990,7 +1983,7 @@ int bpf_send_map_fds(const char *path, const char *obj)
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
 		     unsigned int entries)
 {
-	struct sockaddr_un addr;
+	struct sockaddr_un addr = { .sun_family = AF_UNIX };
 	int fd, ret;
 
 	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
@@ -2000,8 +1993,6 @@ int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
 		return -1;
 	}
 
-	memset(&addr, 0, sizeof(addr));
-	addr.sun_family = AF_UNIX;
 	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
 
 	ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 7747c8db39d15..fb932b4e3782e 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -61,21 +61,18 @@ static int tc_class_modify(int cmd, unsigned int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct tcmsg		t;
 		char			buf[4096];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.t.tcm_family = AF_UNSPEC
+	};
 	struct qdisc_util *q = NULL;
-	struct tc_estimator est;
-	char  d[16];
-	char  k[16];
-
-	memset(&req, 0, sizeof(req));
-	memset(&est, 0, sizeof(est));
-	memset(d, 0, sizeof(d));
-	memset(k, 0, sizeof(k));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.t.tcm_family = AF_UNSPEC;
+	struct tc_estimator est = { 0 };
+	char  d[16] = { 0 };
+	char  k[16] = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -395,14 +392,10 @@ int print_class(const struct sockaddr_nl *who,
 
 static int tc_class_list(int argc, char **argv)
 {
-	struct tcmsg t;
-	char d[16];
+	struct tcmsg t = { .tcm_family = AF_UNSPEC };
+	char d[16] = { 0 };
 	char buf[1024] = {0};
 
-	memset(&t, 0, sizeof(t));
-	t.tcm_family = AF_UNSPEC;
-	memset(d, 0, sizeof(d));
-
 	filter_qdisc = 0;
 	filter_classid = 0;
 
diff --git a/tc/tc_exec.c b/tc/tc_exec.c
index 5208016233783..3e5fd392f5916 100644
--- a/tc/tc_exec.c
+++ b/tc/tc_exec.c
@@ -85,7 +85,7 @@ noexist:
 int do_exec(int argc, char **argv)
 {
 	struct exec_util *eu;
-	char kind[16];
+	char kind[16] = { 0 };
 
 	if (argc < 1) {
 		fprintf(stderr, "No command given, try \"tc exec help\".\n");
@@ -97,7 +97,6 @@ int do_exec(int argc, char **argv)
 		return 0;
 	}
 
-	memset(kind, 0, sizeof(kind));
 	strncpy(kind, *argv, sizeof(kind) - 1);
 
 	eu = get_exec_kind(kind);
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 66586634d19a6..cc322064ef049 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -47,26 +47,22 @@ static int tc_filter_modify(int cmd, unsigned int flags, int argc, char **argv)
 		struct nlmsghdr	n;
 		struct tcmsg		t;
 		char			buf[MAX_MSG];
-	} req;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.t.tcm_family = AF_UNSPEC
+	};
 	struct filter_util *q = NULL;
 	__u32 prio = 0;
 	__u32 protocol = 0;
 	int protocol_set = 0;
 	char *fhandle = NULL;
-	char  d[16];
-	char  k[16];
-	struct tc_estimator est;
-
-	memset(&req, 0, sizeof(req));
-	memset(&est, 0, sizeof(est));
-	memset(d, 0, sizeof(d));
-	memset(k, 0, sizeof(k));
-	memset(&req, 0, sizeof(req));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.t.tcm_family = AF_UNSPEC;
+	char  d[16] = { 0 };
+	char  k[16] = { 0 };
+	struct tc_estimator est = { 0 };
 
 	if (cmd == RTM_NEWTFILTER && flags & NLM_F_CREATE)
 		protocol = htons(ETH_P_ALL);
@@ -213,7 +209,6 @@ int print_filter(const struct sockaddr_nl *who,
 		return -1;
 	}
 
-	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, TCA_MAX, TCA_RTA(t), len);
 
 	if (tb[TCA_KIND] == NULL) {
@@ -278,16 +273,12 @@ int print_filter(const struct sockaddr_nl *who,
 
 static int tc_filter_list(int argc, char **argv)
 {
-	struct tcmsg t;
-	char d[16];
+	struct tcmsg t = { .tcm_family = AF_UNSPEC };
+	char d[16] = { 0 };
 	__u32 prio = 0;
 	__u32 protocol = 0;
 	char *fhandle = NULL;
 
-	memset(&t, 0, sizeof(t));
-	t.tcm_family = AF_UNSPEC;
-	memset(d, 0, sizeof(d));
-
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index a63c47625a7b2..a43fadba1cf8c 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -49,25 +49,21 @@ static int tc_qdisc_modify(int cmd, unsigned int flags, int argc, char **argv)
 	struct {
 		struct tc_sizespec	szopts;
 		__u16			*data;
-	} stab;
-	char  d[16];
-	char  k[16];
+	} stab = { 0 };
+	char  d[16] = { 0 };
+	char  k[16] = { 0 };
 	struct {
 		struct nlmsghdr	n;
 		struct tcmsg		t;
 		char			buf[TCA_BUF_MAX];
-	} req;
-
-	memset(&req, 0, sizeof(req));
-	memset(&stab, 0, sizeof(stab));
-	memset(&est, 0, sizeof(est));
-	memset(&d, 0, sizeof(d));
-	memset(&k, 0, sizeof(k));
-
-	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg));
-	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
-	req.n.nlmsg_type = cmd;
-	req.t.tcm_family = AF_UNSPEC;
+	} req = {
+		.n = {
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcmsg)),
+			.nlmsg_flags = NLM_F_REQUEST | flags,
+			.nlmsg_type = cmd
+		},
+		.t.tcm_family = AF_UNSPEC
+	};
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
@@ -227,7 +223,6 @@ int print_qdisc(const struct sockaddr_nl *who,
 	if (filter_ifindex && filter_ifindex != t->tcm_ifindex)
 		return 0;
 
-	memset(tb, 0, sizeof(tb));
 	parse_rtattr(tb, TCA_MAX, TCA_RTA(t), len);
 
 	if (tb[TCA_KIND] == NULL) {
@@ -287,12 +282,8 @@ int print_qdisc(const struct sockaddr_nl *who,
 
 static int tc_qdisc_list(int argc, char **argv)
 {
-	struct tcmsg t;
-	char d[16];
-
-	memset(&t, 0, sizeof(t));
-	t.tcm_family = AF_UNSPEC;
-	memset(&d, 0, sizeof(d));
+	struct tcmsg t = { .tcm_family = AF_UNSPEC };
+	char d[16] = { 0 };
 
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
diff --git a/tc/tc_stab.c b/tc/tc_stab.c
index d7e00025caff2..3e58e926e5c21 100644
--- a/tc/tc_stab.c
+++ b/tc/tc_stab.c
@@ -53,9 +53,7 @@ int parse_size_table(int *argcp, char ***argvp, struct tc_sizespec *sp)
 {
 	char **argv = *argvp;
 	int argc = *argcp;
-	struct tc_sizespec s;
-
-	memset(&s, 0, sizeof(s));
+	struct tc_sizespec s = { 0 };
 
 	NEXT_ARG();
 	if (matches(*argv, "help") == 0) {
diff --git a/tc/tc_util.c b/tc/tc_util.c
index afc4cf5acd8b5..6aa6aaf16499a 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -580,10 +580,9 @@ void print_tcstats_attr(FILE *fp, struct rtattr *tb[], char *prefix, struct rtat
 	}
 	/* backward compatibility */
 	if (tb[TCA_STATS]) {
-		struct tc_stats st;
+		struct tc_stats st = { 0 };
 
 		/* handle case where kernel returns more/less than we know about */
-		memset(&st, 0, sizeof(st));
 		memcpy(&st, RTA_DATA(tb[TCA_STATS]), MIN(RTA_PAYLOAD(tb[TCA_STATS]), sizeof(st)));
 
 		fprintf(fp, "%sSent %llu bytes %u pkts (dropped %u, overlimits %u) ",
-- 
2.8.2
