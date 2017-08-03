From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 21/27] ip: link_gre6.c: add json output support
Date: Thu,  3 Aug 2017 17:55:09 +0200
Message-ID: <20170803155515.99226-22-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35585 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdHCP4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:00 -0400
Received: by mail-wm0-f51.google.com with SMTP id m85so19153735wma.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:00 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "remote": {
        "type": "string",
        "attr": "IFLA_GRE_REMOTE"
    },
    "local": {
        "type": "string",
        "attr": "IFLA_GRE_LOCAL"
    },
    "link": {
        "type": "string",
        "attr": "IFLA_GRE_LINK",
        "mutually_exclusive": {
            "link_index": {
                "type": "uint",
            }
        }
    },
    "ttl": {
        "type": "int",
        "attr": "IFLA_GRE_TTL"
    },
    "ip6_tnl_f_ign_encap_limit": {
        "type": "bool",
        "attr": "IP6_TNL_F_IGN_ENCAP_LIMIT"
    },
    "encap_limit": {
        "type": "int",
        "attr": "IFLA_GRE_ENCAP_LIMIT"
    },
    "ip6_tnl_f_use_orig_flowlabel": {
        "type": "bool",
        "attr": "IP6_TNL_F_USE_ORIG_FLOWLABEL"
    },
    "flowlabel": {
        "type": "string",
        "attr": "IP6_FLOWINFO_FLOWLABEL"
    },
    "ip6_tnl_f_rcv_dscp_copy": {
        "type": "bool",
        "attr": "IP6_TNL_F_RCV_DSCP_COPY"
    },
    "ikey": {
        "type": "string",
        "attr": "IFLA_GRE_IKEY"
    },
    "okey": {
        "type": "string",
        "attr": "IFLA_GRE_OKEY"
    },
    "iseq": {
        "type": "bool",
        "attr": "IFLA_GRE_IFLAGS & GRE_SEQ"
    },
    "oseq": {
        "type": "bool",
        "attr": "IFLA_GRE_OFLAGS & GRE_SEQ"
    },
    "icsum": {
        "type": "bool",
        "attr": "IFLA_GRE_IFLAGS & GRE_CSUM"
    },
    "ocsum": {
        "type": "bool",
        "attr": "IFLA_GRE_OFLAGS & GRE_CSUM"
    },
    "encap": {
        "type": "dict",
        "attr": "IFLA_GRE_ENCAP_TYPE != TUNNEL_ENCAP_NONE",
        "dict": {
            "type": {
                "type": "string",
                "attr": "IFLA_GRE_ENCAP_TYPE"
            },
            "sport": {
                "type": "uint",
                "attr": "IFLA_GRE_ENCAP_SPORT"
            },
            "dport": {
                "type": "uint",
                "attr": "IFLA_GRE_ENCAP_DPORT"
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
10: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN mode DEFAULT
group default
    link/tunnel6 :: brd ::
11: ip6gre0@NONE: <NOARP> mtu 1448 qdisc noop state DOWN mode DEFAULT
group default
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
 ip/link_gre6.c | 142 ++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 99 insertions(+), 43 deletions(-)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 4d3d4b54..957853d6 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -423,7 +423,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			remote = format_host(AF_INET6, sizeof(addr), &addr);
 	}
 
-	fprintf(f, "remote %s ", remote);
+	print_string(PRINT_ANY, "remote", "remote %s ", remote);
 
 	if (tb[IFLA_GRE_LOCAL]) {
 		struct in6_addr addr;
@@ -434,36 +434,65 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			local = format_host(AF_INET6, sizeof(addr), &addr);
 	}
 
-	fprintf(f, "local %s ", local);
+	print_string(PRINT_ANY, "local", "local %s ", local);
 
 	if (tb[IFLA_GRE_LINK] && rta_getattr_u32(tb[IFLA_GRE_LINK])) {
 		unsigned int link = rta_getattr_u32(tb[IFLA_GRE_LINK]);
 		const char *n = if_indextoname(link, s2);
 
 		if (n)
-			fprintf(f, "dev %s ", n);
+			print_string(PRINT_ANY, "link", "dev %s ", n);
 		else
-			fprintf(f, "dev %u ", link);
+			print_uint(PRINT_ANY, "link_index", "dev %u ", link);
 	}
 
-	if (tb[IFLA_GRE_TTL] && rta_getattr_u8(tb[IFLA_GRE_TTL]))
-		fprintf(f, "hoplimit %d ", rta_getattr_u8(tb[IFLA_GRE_TTL]));
+	if (tb[IFLA_GRE_TTL]) {
+		__u8 ttl = rta_getattr_u8(tb[IFLA_GRE_TTL]);
+
+		if (ttl)
+			print_int(PRINT_ANY, "ttl", "hoplimit %d ", ttl);
+		else
+			print_int(PRINT_JSON, "ttl", NULL, ttl);
+	}
 
 	if (flags & IP6_TNL_F_IGN_ENCAP_LIMIT)
-		fprintf(f, "encaplimit none ");
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_ign_encap_limit",
+			   "encaplimit none ",
+			   true);
 	else if (tb[IFLA_GRE_ENCAP_LIMIT]) {
 		int encap_limit = rta_getattr_u8(tb[IFLA_GRE_ENCAP_LIMIT]);
 
-		fprintf(f, "encaplimit %d ", encap_limit);
+		print_int(PRINT_ANY,
+			  "encap_limit",
+			  "encaplimit %d ",
+			  encap_limit);
 	}
 
-	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
-		fprintf(f, "flowlabel inherit ");
-	else
-		fprintf(f, "flowlabel 0x%05x ", ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
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
+
+		} else {
+			fprintf(f, "flowlabel 0x%05x ",
+				ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+		}
+	}
 
 	if (flags & IP6_TNL_F_RCV_DSCP_COPY)
-		fprintf(f, "dscp inherit ");
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_rcv_dscp_copy",
+			   "dscp inherit ",
+			   true);
 
 	if (tb[IFLA_GRE_IFLAGS])
 		iflags = rta_getattr_u16(tb[IFLA_GRE_IFLAGS]);
@@ -473,27 +502,37 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if ((iflags & GRE_KEY) && tb[IFLA_GRE_IKEY]) {
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_IKEY]), s2, sizeof(s2));
-		fprintf(f, "ikey %s ", s2);
+		print_string(PRINT_ANY, "ikey", "ikey %s ", s2);
 	}
 
 	if ((oflags & GRE_KEY) && tb[IFLA_GRE_OKEY]) {
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_OKEY]), s2, sizeof(s2));
-		fprintf(f, "okey %s ", s2);
+		print_string(PRINT_ANY, "okey", "okey %s ", s2);
 	}
 
 	if (iflags & GRE_SEQ)
-		fputs("iseq ", f);
+		print_bool(PRINT_ANY, "iseq", "iseq ", true);
 	if (oflags & GRE_SEQ)
-		fputs("oseq ", f);
+		print_bool(PRINT_ANY, "oseq", "oseq ", true);
 	if (iflags & GRE_CSUM)
-		fputs("icsum ", f);
+		print_bool(PRINT_ANY, "icsum", "icsum ", true);
 	if (oflags & GRE_CSUM)
-		fputs("ocsum ", f);
+		print_bool(PRINT_ANY, "ocsum", "ocsum ", true);
 
 	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
-		fprintf(f, "fwmark inherit ");
-	else if (tb[IFLA_GRE_FWMARK] && rta_getattr_u32(tb[IFLA_GRE_FWMARK]))
-		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_GRE_FWMARK]));
+		print_bool(PRINT_ANY,
+			   "ip6_tnl_f_use_orig_fwmark",
+			   "fwmark inherit ",
+			   true);
+	else if (tb[IFLA_GRE_FWMARK]) {
+		__u32 fwmark = rta_getattr_u32(tb[IFLA_GRE_FWMARK]);
+
+		if (fwmark) {
+			snprintf(s2, sizeof(s2), "0x%x", fwmark);
+
+			print_string(PRINT_ANY, "fwmark", "fwmark %s ", s2);
+		}
+	}
 
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
@@ -502,40 +541,57 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		__u16 sport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_SPORT]);
 		__u16 dport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_DPORT]);
 
-		fputs("encap ", f);
+		open_json_object("encap");
+
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
+					   flags & TUNNEL_ENCAP_FLAG_CSUM);
+			print_bool(PRINT_JSON, "csum6", NULL,
+					   flags & TUNNEL_ENCAP_FLAG_CSUM6);
+			print_bool(PRINT_JSON, "remcsum", NULL,
+					   flags & TUNNEL_ENCAP_FLAG_REMCSUM);
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
 
-- 
2.13.3
