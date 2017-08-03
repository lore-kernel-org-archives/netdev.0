From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 22/27] ip: link_ip6tnl.c: add json output support
Date: Thu,  3 Aug 2017 17:55:10 +0200
Message-ID: <20170803155515.99226-23-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37703 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751964AbdHCP4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:02 -0400
Received: by mail-wm0-f48.google.com with SMTP id t201so19245788wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:01 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "proto": {
        "type": "string",
        "attr": "IFLA_IPTUN_PROTO"
    },
    "remote": {
        "type": "string",
        "attr": "IFLA_IPTUN_REMOTE"
    },
    "local": {
        "type": "string",
        "attr": "IFLA_IPTUN_LOCAL"
    },
    "link": {
        "type": "string",
        "attr": "IFLA_IPTUN_LINK",
        "mutually_exclusive": {
            "link_index": {
                "type": "uint",
            }
        }
    },
    "ip6_tnl_f_ign_encap_limit": {
        "type": "bool",
        "attr": "IP6_TNL_F_IGN_ENCAP_LIMIT"
    },
    "encap_limit": {
        "type": "uint",
        "attr": "IFLA_IPTUN_ENCAP_LIMIT"
    },
    "ttl": {
        "type": "uint",
        "attr": "IFLA_IPTUN_TTL"
    },
    "ip6_tnl_f_use_orig_tclass": {
        "type": "",
        "attr": "IP6_TNL_F_USE_ORIG_TCLASS"
    },
    "flowinfo_tclass": {
        "type": "string",
        "attr": "IP6_FLOWINFO_TCLASS"
    },
    "ip6_tnl_f_use_orig_flowlabel": {
        "type": "bool",
        "attr": "IP6_TNL_F_USE_ORIG_FLOWLABEL"
    },
    "flowlabel": {
        "type": "string",
        "attr": "IP6_FLOWINFO_FLOWLABEL"
    },
    "flowinfo": {
        "type": "string"
    },
    "ip6_tnl_f_rcv_dscp_copy": {
        "type": "bool",
        "attr": "IP6_TNL_F_RCV_DSCP_COPY"
    },
    "ip6_tnl_f_mip6_dev": {
        "type": "bool",
        "attr": "IP6_TNL_F_MIP6_DEV"
    },
    "ip6_tnl_f_use_orig_fwmark": {
        "type": "bool",
        "attr": "IP6_TNL_F_USE_ORIG_FWMARK"
    },
    "encap": {
        "type": "dict",
        "attr": "IFLA_IPTUN_ENCAP_TYPE",
        "dict": {
            "type": {
                "type": "string",
                "attr": "IFLA_IPTUN_ENCAP_TYPE"
            },
            "sport": {
                "type": "uint",
                "attr": "IFLA_IPTUN_ENCAP_SPORT"
            },
            "dport": {
                "type": "uint",
                "attr": "IFLA_IPTUN_ENCAP_DPORT"
            },
            "csum": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_CSUM"
            },
            "csum6": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_CSUM6"
            },
            "remcsum": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_REMCSUM"
            }
        }
    }
}

$ ip link show
$ ip -6 tunnel add name tun6 mode ip6gre local 2001:db8:1::1/64 remote
2001:0db8:85a3:0000:0000:8a2e:0370:7334
$ ip link show
10: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN mode DEFAULT group
default
    link/tunnel6 :: brd ::
11: ip6gre0@NONE: <NOARP> mtu 1448 qdisc noop state DOWN mode DEFAULT group
default
    link/gre6 00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00 brd
00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00
12: tun6@NONE: <POINTOPOINT,NOARP> mtu 1448 qdisc noop state DOWN mode
DEFAULT group default
    link/gre6 20:01:0d:b8:00:01:00:00:00:00:00:00:00:00:00:01 peer
20:01:0d:b8:85:a3:00:00:00:00:8a:2e:03:70:73:34
➜  ~ ./ip -details -json link show
[{
        "ifindex": 10,
        "ifname": "ip6tnl0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1452,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "tunnel6",
        "address": "::",
        "broadcast": "::",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "ip6tnl",
            "info_data": {
                "proto": "ip6ip6",
                "remote": "::",
                "local": "::",
                "encap_limit": 0,
                "ttl": 0,
                "flowinfo_tclass": "0x00",
                "flowlabel": "0x00000",
                "flowinfo": "0x00000000"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "ip6gre0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1448,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "gre6",
        "address": "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00",
        "broadcast": "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "ip6gre",
            "info_data": {
                "remote": "any",
                "local": "any",
                "ttl": 0,
                "encap_limit": 0,
                "flowlabel": "0x00000"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 12,
        "ifname": "tun6",
        "link": null,
        "flags": ["POINTOPOINT","NOARP"],
        "mtu": 1448,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "gre6",
        "address": "20:01:0d:b8:00:01:00:00:00:00:00:00:00:00:00:01",
        "link_pointtopoint": true,
        "broadcast": "20:01:0d:b8:85:a3:00:00:00:00:8a:2e:03:70:73:34",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "ip6gre",
            "info_data": {
                "remote": "2001:db8:85a3::8a2e:370:7334",
                "local": "2001:db8:1::1",
                "ttl": 64,
                "encap_limit": 4,
                "flowlabel": "0x00000"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]
$

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/link_ip6tnl.c | 172 +++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 122 insertions(+), 50 deletions(-)

diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 505fb476..a4199006 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -346,25 +346,29 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 	if (tb[IFLA_IPTUN_PROTO]) {
 		switch (rta_getattr_u8(tb[IFLA_IPTUN_PROTO])) {
 		case IPPROTO_IPIP:
-			fprintf(f, "ipip6 ");
+			print_string(PRINT_ANY, "proto", "%s ", "ipip6");
 			break;
 		case IPPROTO_IPV6:
-			fprintf(f, "ip6ip6 ");
+			print_string(PRINT_ANY, "proto", "%s ", "ip6ip6");
 			break;
 		case 0:
-			fprintf(f, "any ");
+			print_string(PRINT_ANY, "proto", "%s ", "any");
 			break;
 		}
 	}
 
 	if (tb[IFLA_IPTUN_REMOTE]) {
-		fprintf(f, "remote %s ",
-			rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_REMOTE]));
+		print_string(PRINT_ANY,
+			     "remote",
+			     "remote %s ",
+			     rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_REMOTE]));
 	}
 
 	if (tb[IFLA_IPTUN_LOCAL]) {
-		fprintf(f, "local %s ",
-			rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_LOCAL]));
+		print_string(PRINT_ANY,
+			     "local",
+			     "local %s ",
+			     rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_LOCAL]));
 	}
 
 	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
@@ -372,93 +376,161 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 		const char *n = if_indextoname(link, s2);
 
 		if (n)
-			fprintf(f, "dev %s ", n);
+			print_string(PRINT_ANY, "link", "dev %s ", n);
 		else
-			fprintf(f, "dev %u ", link);
+			print_uint(PRINT_ANY, "link_index", "dev %u ", link);
 	}
 
 	if (flags & IP6_TNL_F_IGN_ENCAP_LIMIT)
-		printf("encaplimit none ");
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_ign_encap_limit",
+			   "encaplimit none ",
+			   true);
 	else if (tb[IFLA_IPTUN_ENCAP_LIMIT])
-		fprintf(f, "encaplimit %u ",
-			rta_getattr_u8(tb[IFLA_IPTUN_ENCAP_LIMIT]));
+		print_uint(PRINT_ANY,
+			   "encap_limit",
+			   "encaplimit %u ",
+			   rta_getattr_u8(tb[IFLA_IPTUN_ENCAP_LIMIT]));
 
 	if (tb[IFLA_IPTUN_TTL])
-		fprintf(f, "hoplimit %u ", rta_getattr_u8(tb[IFLA_IPTUN_TTL]));
+		print_uint(PRINT_ANY,
+			   "ttl",
+			   "hoplimit %u ",
+			   rta_getattr_u8(tb[IFLA_IPTUN_TTL]));
 
 	if (flags & IP6_TNL_F_USE_ORIG_TCLASS)
-		printf("tclass inherit ");
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_use_orig_tclass",
+			   "tclass inherit ",
+			   true);
 	else if (tb[IFLA_IPTUN_FLOWINFO]) {
 		__u32 val = ntohl(flowinfo & IP6_FLOWINFO_TCLASS);
 
-		printf("tclass 0x%02x ", (__u8)(val >> 20));
+		if (is_json_context()) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1), "0x%02x", (__u8)(val >> 20));
+			print_string(PRINT_JSON, "flowinfo_tclass", NULL, b1);
+		} else {
+			printf("tclass 0x%02x ", (__u8)(val >> 20));
+		}
+	}
+
+	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL) {
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_use_orig_flowlabel",
+			   "flowlabel inherit ",
+			   true);
+	} else {
+		if (is_json_context()) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1), "0x%05x",
+				 ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+			print_string(PRINT_JSON, "flowlabel", NULL, b1);
+		} else {
+			printf("flowlabel 0x%05x ",
+			       ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+		}
 	}
 
-	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		printf("flowlabel inherit ");
-	else
-		printf("flowlabel 0x%05x ", ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+	if (is_json_context()) {
+		SPRINT_BUF(flwinfo);
 
-	printf("(flowinfo 0x%08x) ", ntohl(flowinfo));
+		snprintf(flwinfo, sizeof(flwinfo), "0x%08x", ntohl(flowinfo));
+		print_string(PRINT_JSON, "flowinfo", NULL, flwinfo);
+	} else {
+		printf("(flowinfo 0x%08x) ", ntohl(flowinfo));
+
+	}
 
 	if (flags & IP6_TNL_F_RCV_DSCP_COPY)
-		printf("dscp inherit ");
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_rcv_dscp_copy",
+			   "dscp inherit ",
+			   true);
 
 	if (flags & IP6_TNL_F_MIP6_DEV)
-		fprintf(f, "mip6 ");
+		print_bool(PRINT_ANY, "ip6_tnl_f_mip6_dev", "mip6 ", true);
+
+	if (flags & IP6_TNL_F_USE_ORIG_FWMARK) {
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_use_orig_fwmark",
+			   "fwmark inherit ",
+			   true);
+	} else if (tb[IFLA_IPTUN_FWMARK]) {
+		__u32 fwmark = rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]);
 
-	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
-		fprintf(f, "fwmark inherit ");
-	else if (tb[IFLA_IPTUN_FWMARK] && rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]))
-		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]));
+		if (fwmark) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1), "0x%x", fwmark);
+			print_string(PRINT_ANY, "fwmark", "fwmark %s ", b1);
+		}
+	}
 
 	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
-	    rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]) !=
-	    TUNNEL_ENCAP_NONE) {
+	    rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]);
 		__u16 flags = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_FLAGS]);
 		__u16 sport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_SPORT]);
 		__u16 dport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_DPORT]);
 
-		fputs("encap ", f);
+		open_json_object("encap");
+		print_string(PRINT_FP, NULL, "encap ", NULL);
 		switch (type) {
 		case TUNNEL_ENCAP_FOU:
-			fputs("fou ", f);
+			print_string(PRINT_ANY, "type", "%s ", "fou");
 			break;
 		case TUNNEL_ENCAP_GUE:
-			fputs("gue ", f);
+			print_string(PRINT_ANY, "type", "%s ", "gue");
 			break;
 		default:
-			fputs("unknown ", f);
+			print_null(PRINT_ANY, "type", "unknown ", NULL);
 			break;
 		}
 
-		if (sport == 0)
-			fputs("encap-sport auto ", f);
-		else
-			fprintf(f, "encap-sport %u", ntohs(sport));
+		if (is_json_context()) {
+			print_uint(PRINT_JSON,
+				   "sport",
+				   NULL,
+				   sport ? ntohs(sport) : 0);
+			print_uint(PRINT_JSON, "dport", NULL, ntohs(dport));
+			print_bool(PRINT_JSON, "csum", NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM);
+			print_bool(PRINT_JSON, "csum6", NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM6);
+			print_bool(PRINT_JSON, "remcsum", NULL,
+				   flags & TUNNEL_ENCAP_FLAG_REMCSUM);
+			close_json_object();
+		} else {
+			if (sport == 0)
+				fputs("encap-sport auto ", f);
+			else
+				fprintf(f, "encap-sport %u", ntohs(sport));
 
-		fprintf(f, "encap-dport %u ", ntohs(dport));
+			fprintf(f, "encap-dport %u ", ntohs(dport));
 
-		if (flags & TUNNEL_ENCAP_FLAG_CSUM)
-			fputs("encap-csum ", f);
-		else
-			fputs("noencap-csum ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_CSUM)
+				fputs("encap-csum ", f);
+			else
+				fputs("noencap-csum ", f);
 
-		if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
-			fputs("encap-csum6 ", f);
-		else
-			fputs("noencap-csum6 ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
+				fputs("encap-csum6 ", f);
+			else
+				fputs("noencap-csum6 ", f);
 
-		if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
-			fputs("encap-remcsum ", f);
-		else
-			fputs("noencap-remcsum ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
+				fputs("encap-remcsum ", f);
+			else
+				fputs("noencap-remcsum ", f);
+		}
 	}
 }
 
 static void ip6tunnel_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+				 FILE *f)
 {
 	print_usage(f);
 }
-- 
2.13.3
