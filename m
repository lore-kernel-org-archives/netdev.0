From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 20/27] ip: link_gre.c: add json output support
Date: Thu, 17 Aug 2017 10:36:07 -0700
Message-ID: <20170817173614.54987-21-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:33701 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753620AbdHQRls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:48 -0400
Received: by mail-wr0-f182.google.com with SMTP id b65so50137834wrd.0
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:47 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "external": {
        "type": "bool",
        "comment": "!tb[IFLA_GRE_COLLECT_METADATA]"
    },
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
    "tos": {
        "type": "string",
        "attr": "IFLA_GRE_TOS"
    },
    "pmtudisc": {
        "type": "bool",
        "attr": "IFLA_GRE_PMTUDISC"
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
    "ignore_df": {
        "type": "bool",
        "attr": "IFLA_GRE_IGNORE_DF"
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
$ ip tunnel add tun42 mode gre local 192.0.2.42 remote 203.0.113.42 key 42
$ ip link show
10: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN mode DEFAULT group
default
    link/gre 0.0.0.0 brd 0.0.0.0
11: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN
mode DEFAULT group default qlen 1000
    link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
12: tun42@NONE: <POINTOPOINT,NOARP> mtu 1472 qdisc noop state DOWN mode
DEFAULT group default
    link/gre 192.0.2.42 peer 203.0.113.42
$ ip -details -json link show
[{
        "ifindex": 10,
        "ifname": "gre0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1476,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "gre",
        "address": "0.0.0.0",
        "broadcast": "0.0.0.0",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "gre",
            "info_data": {
                "remote": "any",
                "local": "any",
                "ttl": 0,
                "pmtudisc": false
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "gretap0",
        "link": null,
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1462,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "00:00:00:00:00:00",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "gretap",
            "info_data": {
                "remote": "any",
                "local": "any",
                "ttl": 0,
                "pmtudisc": false
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 12,
        "ifname": "tun42",
        "link": null,
        "flags": ["POINTOPOINT","NOARP"],
        "mtu": 1472,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "gre",
        "address": "192.0.2.42",
        "link_pointtopoint": true,
        "broadcast": "203.0.113.42",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "gre",
            "info_data": {
                "remote": "203.0.113.42",
                "local": "192.0.2.42",
                "ttl": 0,
                "pmtudisc": true,
                "ikey": "0.0.0.42",
                "okey": "0.0.0.42"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/link_gre.c | 147 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 98 insertions(+), 49 deletions(-)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index c2ec5f26..3c9f8194 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -389,7 +389,7 @@ static void gre_print_direct_opt(FILE *f, struct rtattr *tb[])
 			remote = format_host(AF_INET, 4, &addr);
 	}
 
-	fprintf(f, "remote %s ", remote);
+	print_string(PRINT_ANY, "remote", "remote %s ", remote);
 
 	if (tb[IFLA_GRE_LOCAL]) {
 		unsigned int addr = rta_getattr_u32(tb[IFLA_GRE_LOCAL]);
@@ -398,36 +398,52 @@ static void gre_print_direct_opt(FILE *f, struct rtattr *tb[])
 			local = format_host(AF_INET, 4, &addr);
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
-		fprintf(f, "ttl %d ", rta_getattr_u8(tb[IFLA_GRE_TTL]));
-	else
-		fprintf(f, "ttl inherit ");
+	if (tb[IFLA_GRE_TTL]) {
+		__u8 ttl = rta_getattr_u8(tb[IFLA_GRE_TTL]);
+
+		if (ttl)
+			print_int(PRINT_ANY, "ttl", "ttl %d ", ttl);
+		else
+			print_int(PRINT_JSON, "ttl", NULL, ttl);
+	} else {
+		print_string(PRINT_FP, NULL, "ttl %s ", "inherit");
+	}
 
 	if (tb[IFLA_GRE_TOS] && rta_getattr_u8(tb[IFLA_GRE_TOS])) {
 		int tos = rta_getattr_u8(tb[IFLA_GRE_TOS]);
 
-		fputs("tos ", f);
-		if (tos == 1)
-			fputs("inherit ", f);
-		else
-			fprintf(f, "0x%x ", tos);
+		if (is_json_context()) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1), "0x%x", tos);
+			print_string(PRINT_JSON, "tos", NULL, b1);
+		} else {
+			fputs("tos ", f);
+			if (tos == 1)
+				fputs("inherit ", f);
+			else
+				fprintf(f, "0x%x ", tos);
+		}
 	}
 
-	if (tb[IFLA_GRE_PMTUDISC] &&
-	    !rta_getattr_u8(tb[IFLA_GRE_PMTUDISC]))
-		fputs("nopmtudisc ", f);
+	if (tb[IFLA_GRE_PMTUDISC]) {
+		if (!rta_getattr_u8(tb[IFLA_GRE_PMTUDISC]))
+			print_bool(PRINT_ANY, "pmtudisc", "nopmtudisc ", false);
+		else
+			print_bool(PRINT_JSON, "pmtudisc", NULL, true);
+	}
 
 	if (tb[IFLA_GRE_IFLAGS])
 		iflags = rta_getattr_u16(tb[IFLA_GRE_IFLAGS]);
@@ -437,26 +453,31 @@ static void gre_print_direct_opt(FILE *f, struct rtattr *tb[])
 
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
+
+	if (tb[IFLA_GRE_FWMARK]) {
+		__u32 fwmark = rta_getattr_u32(tb[IFLA_GRE_FWMARK]);
+
+		if (fwmark) {
+			snprintf(s2, sizeof(s2), "0x%x", fwmark);
 
-	if (tb[IFLA_GRE_FWMARK] && rta_getattr_u32(tb[IFLA_GRE_FWMARK])) {
-		fprintf(f, "fwmark 0x%x ",
-			rta_getattr_u32(tb[IFLA_GRE_FWMARK]));
+			print_string(PRINT_ANY, "fwmark", "fwmark %s ", s2);
+		}
 	}
 }
 
@@ -468,10 +489,10 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (!tb[IFLA_GRE_COLLECT_METADATA])
 		gre_print_direct_opt(f, tb);
 	else
-		fputs("external ", f);
+		print_bool(PRINT_ANY, "external", "external ", true);
 
 	if (tb[IFLA_GRE_IGNORE_DF] && rta_getattr_u8(tb[IFLA_GRE_IGNORE_DF]))
-		fputs("ignore-df ", f);
+		print_bool(PRINT_ANY, "ignore_df", "ignore-df ", true);
 
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
@@ -480,45 +501,73 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		__u16 sport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_SPORT]);
 		__u16 dport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_DPORT]);
 
-		fputs("encap ", f);
+
+		open_json_object("encap");
+		print_string(PRINT_FP, NULL, "encap ", NULL);
+
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
+			print_null(PRINT_ANY, "type", "%s ", "unknown");
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
+
+			print_bool(PRINT_JSON,
+				   "csum",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM);
+
+			print_bool(PRINT_JSON,
+				   "csum6",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM6);
+
+			print_bool(PRINT_JSON,
+				   "remcsum",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_REMCSUM);
+
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
 
 static void gre_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			   FILE *f)
 {
 	print_usage(f);
 }
-- 
2.14.1
