From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 17/27] ip: iplink_vxlan.c: add json output support
Date: Thu, 17 Aug 2017 10:36:04 -0700
Message-ID: <20170817173614.54987-18-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:37982 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753563AbdHQRlf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:35 -0400
Received: by mail-wr0-f172.google.com with SMTP id 5so25428981wrz.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:35 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "id": {
        "type": "uint",
        "attr": "IFLA_VXLAN_ID"
    },
    "group": {
        "type": "string",
        "attr": "IFLA_VXLAN_GROUP"
    },
    "remote": {
        "type": "string",
        "attr": "IFLA_VXLAN_GROUP"
    },
    "group6": {
        "type": "string",
        "attr": "IFLA_VXLAN_GROUP6"
    },
    "remote6": {
        "type": "string",
        "attr": "IFLA_VXLAN_GROUP6"
    },
    "local": {
        "type": "string",
        "attr": "IFLA_VXLAN_LOCAL"
    },
    "local6": {
        "type": "string",
        "attr": "IFLA_VXLAN_LOCAL6"
    },
    "link": {
        "type": "string",
        "attr": "IFLA_VXLAN_LINK",
        "mutually_exclusive": {
            "link_index": {
                "type": "uint",
                "comment": "if not ifname for ifindex"
            }
        }
    },
    "port_range": {
        "type": "dict",
        "attr": "IFLA_VXLAN_PORT_RANGE",
        "dict": {
            "low": {
                "type": "uint"
            },
            "high": {
                "type": "uint"
            }
        }
    },
    "port": {
        "type": "uint",
        "attr": "IFLA_VXLAN_PORT"
    },
    "learning": {
        "type": "bool",
        "attr": "IFLA_VXLAN_LEARNING"
    },
    "proxy": {
        "type": "bool",
        "attr": "IFLA_VXLAN_PROXY"
    },
    "rsc": {
        "type": "bool",
        "attr": "IFLA_VXLAN_RSC"
    },
    "l2miss": {
        "type": "bool",
        "attr": "IFLA_VXLAN_L2MISS"
    },
    "l3miss": {
        "type": "bool",
        "attr": "IFLA_VXLAN_L3MISS"
    },
    "tos": {
        "type": "string",
        "attr": "IFLA_VXLAN_TOS"
    },
    "ttl": {
        "type": "int",
        "attr": "IFLA_VXLAN_TTL"
    },
    "label": {
        "type": "string",
        "attr": "IFLA_VXLAN_LABEL"
    },
    "ageing": {
        "type": "uint",
        "attr": "IFLA_VXLAN_AGEING"
    },
    "limit": {
        "type": "uint",
        "attr": "IFLA_VXLAN_LIMIT"
    },
    "udp_csum": {
        "type": "bool",
        "attr": "IFLA_VXLAN_UDP_CSUM"
    },
    "udp_zero_csum6_tx": {
        "type": "bool",
        "attr": "IFLA_VXLAN_UDP_ZERO_CSUM6_TX"
    },
    "udp_zero_csum6_rx": {
        "type": "bool",
        "attr": "IFLA_VXLAN_UDP_ZERO_CSUM6_RX"
    },
    "remcsum_tx": {
        "type": "bool",
        "attr": "IFLA_VXLAN_REMCSUM_TX"
    },
    "remcsum_rx": {
        "type": "bool",
        "attr": "IFLA_VXLAN_REMCSUM_RX"
    },
    "collect_metadata": {
        "type": "bool",
        "attr": "IFLA_VXLAN_COLLECT_METADATA"
    },
    "gbp": {
        "type": "bool",
        "attr": "IFLA_VXLAN_GBP"
    },
    "gpe": {
        "type": "bool",
        "attr": "IFLA_VXLAN_GPE"
    }
}

$ ip link add name vxlan42 type vxlan id 42 dev eth0 remote 203.0.113.6
local 192.0.2.1 dstport 4789
$ ip link add name vxlan43 type vxlan id 43 dev eth0 group 239.0.0.1
dstport 4789
$ ip -details -json link show
[{
        "ifindex": 17,
        "ifname": "vxlan42",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1450,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "b2:92:0e:1a:c6:42",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vxlan",
            "info_data": {
                "id": 42,
                "remote": "203.0.113.6",
                "local": "192.0.2.1",
                "link": "eth0",
                "port_range": {
                    "low": 0,
                    "high": 0
                },
                "port": 4789,
                "learning": true,
                "ttl": 0,
                "ageing": 300,
                "udp_csum": false,
                "udp_zero_csum6_tx": false,
                "udp_zero_csum6_rx": false
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 18,
        "ifname": "vxlan43",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1450,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "c6:51:4d:7f:f9:2f",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vxlan",
            "info_data": {
                "id": 43,
                "group": "239.0.0.1",
                "link": "eth0",
                "port_range": {
                    "low": 0,
                    "high": 0
                },
                "port": 4789,
                "learning": true,
                "ttl": 0,
                "ageing": 300,
                "udp_csum": false,
                "udp_zero_csum6_tx": false,
                "udp_zero_csum6_rx": false
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
 ip/iplink_vxlan.c | 161 +++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 112 insertions(+), 49 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 2bd619d4..a0530dda 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -406,18 +406,22 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		return;
 
 	vni = rta_getattr_u32(tb[IFLA_VXLAN_ID]);
-	fprintf(f, "id %u ", vni);
+	print_uint(PRINT_ANY, "id", "id %u ", vni);
 
 	if (tb[IFLA_VXLAN_GROUP]) {
 		__be32 addr = rta_getattr_u32(tb[IFLA_VXLAN_GROUP]);
 
 		if (addr) {
 			if (IN_MULTICAST(ntohl(addr)))
-				fprintf(f, "group %s ",
-					format_host(AF_INET, 4, &addr));
+				print_string(PRINT_ANY,
+					     "group",
+					     "group %s ",
+					     format_host(AF_INET, 4, &addr));
 			else
-				fprintf(f, "remote %s ",
-					format_host(AF_INET, 4, &addr));
+				print_string(PRINT_ANY,
+					     "remote",
+					     "remote %s ",
+					     format_host(AF_INET, 4, &addr));
 		}
 	} else if (tb[IFLA_VXLAN_GROUP6]) {
 		struct in6_addr addr;
@@ -425,11 +429,19 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_GROUP6]), sizeof(struct in6_addr));
 		if (!IN6_IS_ADDR_UNSPECIFIED(&addr)) {
 			if (IN6_IS_ADDR_MULTICAST(&addr))
-				fprintf(f, "group %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
+				print_string(PRINT_ANY,
+					     "group6",
+					     "group %s ",
+					     format_host(AF_INET6,
+							 sizeof(struct in6_addr),
+							 &addr));
 			else
-				fprintf(f, "remote %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
+				print_string(PRINT_ANY,
+					     "remote6",
+					     "remote %s ",
+					     format_host(AF_INET6,
+							 sizeof(struct in6_addr),
+							 &addr));
 		}
 	}
 
@@ -437,15 +449,21 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		__be32 addr = rta_getattr_u32(tb[IFLA_VXLAN_LOCAL]);
 
 		if (addr)
-			fprintf(f, "local %s ",
-				format_host(AF_INET, 4, &addr));
+			print_string(PRINT_ANY,
+				     "local",
+				     "local %s ",
+				     format_host(AF_INET, 4, &addr));
 	} else if (tb[IFLA_VXLAN_LOCAL6]) {
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_LOCAL6]), sizeof(struct in6_addr));
 		if (!IN6_IS_ADDR_UNSPECIFIED(&addr))
-			fprintf(f, "local %s ",
-				format_host(AF_INET6, sizeof(struct in6_addr), &addr));
+			print_string(PRINT_ANY,
+				     "local6",
+				     "local %s ",
+				     format_host(AF_INET6,
+						 sizeof(struct in6_addr),
+						 &addr));
 	}
 
 	if (tb[IFLA_VXLAN_LINK] &&
@@ -453,110 +471,155 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		const char *n = if_indextoname(link, s2);
 
 		if (n)
-			fprintf(f, "dev %s ", n);
+			print_string(PRINT_ANY, "link", "dev %s ", n);
 		else
-			fprintf(f, "dev %u ", link);
+			print_uint(PRINT_ANY, "link_index", "dev %u ", link);
 	}
 
 	if (tb[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *r
 			= RTA_DATA(tb[IFLA_VXLAN_PORT_RANGE]);
-		fprintf(f, "srcport %u %u ", ntohs(r->low), ntohs(r->high));
+		if (is_json_context()) {
+			open_json_object("port_range");
+			print_uint(PRINT_JSON, "low", NULL, ntohs(r->low));
+			print_uint(PRINT_JSON, "high", NULL, ntohs(r->high));
+			close_json_object();
+		} else {
+			fprintf(f, "srcport %u %u ",
+				ntohs(r->low), ntohs(r->high));
+		}
 	}
 
 	if (tb[IFLA_VXLAN_PORT])
-		fprintf(f, "dstport %u ",
-			rta_getattr_be16(tb[IFLA_VXLAN_PORT]));
+		print_uint(PRINT_ANY,
+			   "port",
+			   "dstport %u ",
+			   rta_getattr_be16(tb[IFLA_VXLAN_PORT]));
 
-	if (tb[IFLA_VXLAN_LEARNING] &&
-	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
-		fputs("nolearning ", f);
+	if (tb[IFLA_VXLAN_LEARNING]) {
+		__u8 learning = rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]);
+
+		print_bool(PRINT_JSON, "learning", NULL, learning);
+		if (!learning)
+			print_bool(PRINT_FP, NULL, "nolearning ", true);
+	}
 
 	if (tb[IFLA_VXLAN_PROXY] && rta_getattr_u8(tb[IFLA_VXLAN_PROXY]))
-		fputs("proxy ", f);
+		print_bool(PRINT_ANY, "proxy", "proxy ", true);
 
 	if (tb[IFLA_VXLAN_RSC] && rta_getattr_u8(tb[IFLA_VXLAN_RSC]))
-		fputs("rsc ", f);
+		print_bool(PRINT_ANY, "rsc", "rsc ", true);
 
 	if (tb[IFLA_VXLAN_L2MISS] && rta_getattr_u8(tb[IFLA_VXLAN_L2MISS]))
-		fputs("l2miss ", f);
+		print_bool(PRINT_ANY, "l2miss", "l2miss ", true);
 
 	if (tb[IFLA_VXLAN_L3MISS] && rta_getattr_u8(tb[IFLA_VXLAN_L3MISS]))
-		fputs("l3miss ", f);
+		print_bool(PRINT_ANY, "l3miss", "l3miss ", true);
 
 	if (tb[IFLA_VXLAN_TOS] &&
 	    (tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]))) {
-		if (tos == 1)
-			fprintf(f, "tos inherit ");
-		else
-			fprintf(f, "tos %#x ", tos);
+		if (is_json_context()) {
+			print_0xhex(PRINT_JSON, "tos", "%#x", tos);
+		} else {
+			if (tos == 1)
+				fprintf(f, "tos %s ", "inherit");
+			else
+				fprintf(f, "tos %#x ", tos);
+		}
 	}
 
 	if (tb[IFLA_VXLAN_TTL]) {
 		__u8 ttl = rta_getattr_u8(tb[IFLA_VXLAN_TTL]);
 
 		if (ttl)
-			fprintf(f, "ttl %d ", ttl);
+			print_int(PRINT_ANY, "ttl", "ttl %d ", ttl);
+		else
+			print_int(PRINT_JSON, "ttl", NULL, ttl);
 	}
 
 	if (tb[IFLA_VXLAN_LABEL]) {
 		__u32 label = rta_getattr_u32(tb[IFLA_VXLAN_LABEL]);
 
 		if (label)
-			fprintf(f, "flowlabel %#x ", ntohl(label));
+			print_0xhex(PRINT_ANY,
+				    "label",
+				    "flowlabel %#x ",
+				    ntohl(label));
 	}
 
 	if (tb[IFLA_VXLAN_AGEING]) {
 		__u32 age = rta_getattr_u32(tb[IFLA_VXLAN_AGEING]);
 
 		if (age == 0)
-			fprintf(f, "ageing none ");
+			print_uint(PRINT_ANY, "ageing", "ageing none ", 0);
 		else
-			fprintf(f, "ageing %u ", age);
+			print_uint(PRINT_ANY, "ageing", "ageing %u ", age);
 	}
 
 	if (tb[IFLA_VXLAN_LIMIT] &&
 	    ((maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT])) != 0))
-		    fprintf(f, "maxaddr %u ", maxaddr);
+		print_uint(PRINT_ANY, "limit", "maxaddr %u ", maxaddr);
 
 	if (tb[IFLA_VXLAN_UDP_CSUM]) {
-		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_CSUM]))
-			fputs("no", f);
-		fputs("udpcsum ", f);
+		__u8 udp_csum = rta_getattr_u8(tb[IFLA_VXLAN_UDP_CSUM]);
+
+		if (is_json_context()) {
+			print_bool(PRINT_ANY, "udp_csum", NULL, udp_csum);
+		} else {
+			if (!udp_csum)
+				fputs("no", f);
+			fputs("udpcsum ", f);
+		}
 	}
 
 	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]) {
-		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
-			fputs("no", f);
-		fputs("udp6zerocsumtx ", f);
+		__u8 csum6 = rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]);
+
+		if (is_json_context()) {
+			print_bool(PRINT_ANY,
+				   "udp_zero_csum6_tx", NULL, csum6);
+		} else {
+			if (!csum6)
+				fputs("no", f);
+			fputs("udp6zerocsumtx ", f);
+		}
 	}
 
 	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]) {
-		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
-			fputs("no", f);
-		fputs("udp6zerocsumrx ", f);
+		__u8 csum6 = rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]);
+
+		if (is_json_context()) {
+			print_bool(PRINT_ANY,
+				   "udp_zero_csum6_rx",
+				   NULL,
+				   csum6);
+		} else {
+			if (!csum6)
+				fputs("no", f);
+			fputs("udp6zerocsumrx ", f);
+		}
 	}
 
 	if (tb[IFLA_VXLAN_REMCSUM_TX] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_TX]))
-		fputs("remcsumtx ", f);
+		print_bool(PRINT_ANY, "remcsum_tx", "remcsumtx ", true);
 
 	if (tb[IFLA_VXLAN_REMCSUM_RX] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_RX]))
-		fputs("remcsumrx ", f);
+		print_bool(PRINT_ANY, "remcsum_rx", "remcsumrx ", true);
 
 	if (tb[IFLA_VXLAN_COLLECT_METADATA] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_COLLECT_METADATA]))
-		fputs("external ", f);
+		print_bool(PRINT_ANY, "collect_metadata", "external ", true);
 
 	if (tb[IFLA_VXLAN_GBP])
-		fputs("gbp ", f);
+		print_bool(PRINT_ANY, "gbp", "gbp ", true);
 	if (tb[IFLA_VXLAN_GPE])
-		fputs("gpe ", f);
+		print_bool(PRINT_ANY, "gpe", "gpe ", true);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			     FILE *f)
 {
 	print_explain(f);
 }
-- 
2.14.1
