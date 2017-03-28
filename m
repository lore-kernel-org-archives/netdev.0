From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/4] ip: link: Unify link type help functions a bit
Date: Tue, 28 Mar 2017 23:19:38 +0200
Message-ID: <20170328211939.17922-4-phil@nwl.cc>
References: <20170328211939.17922-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59799 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752363AbdC1VT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 17:19:57 -0400
In-Reply-To: <20170328211939.17922-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take help function in iplink_bridge.c as an example and make other link
types' help functions similar:

* Use a single fprintf() call (if possible).
* Don't state a full command line, just "... type OPTIONS".
* Put every option in it's own line, align options by column.
* List mandatory options first.

link_veth.c is intentionally left untouched because it's 'peer' option
eats all kinds of generic link options and the help text points this out
without duplicating all the options there again.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_geneve.c | 28 ++++++++++++++++++----------
 ip/iplink_ipoib.c  |  4 +++-
 ip/iplink_vlan.c   | 15 +++++++++------
 ip/iplink_vxlan.c  | 44 +++++++++++++++++++++++++++++---------------
 ip/link_gre.c      | 36 +++++++++++++++++++++++-------------
 ip/link_gre6.c     | 47 ++++++++++++++++++++++++++++-------------------
 ip/link_ip6tnl.c   | 46 +++++++++++++++++++++++++++-------------------
 ip/link_iptnl.c    | 38 ++++++++++++++++++++++++++------------
 ip/link_vti.c      | 17 +++++++++--------
 9 files changed, 172 insertions(+), 103 deletions(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 1e6669d07d603..2c510fceb3c97 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -17,16 +17,24 @@
 
 static void print_explain(FILE *f)
 {
-	fprintf(f, "Usage: ... geneve id VNI remote ADDR\n");
-	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ flowlabel LABEL ]\n");
-	fprintf(f, "                 [ dstport PORT ] [ [no]external ]\n");
-	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: VNI   := 0-16777215\n");
-	fprintf(f, "       ADDR  := IP_ADDRESS\n");
-	fprintf(f, "       TOS   := { NUMBER | inherit }\n");
-	fprintf(f, "       TTL   := { 1..255 | inherit }\n");
-	fprintf(f, "       LABEL := 0-1048575\n");
+	fprintf(f,
+		"Usage: ... geneve id VNI\n"
+		"                  remote ADDR\n"
+		"                  [ ttl TTL ]\n"
+		"                  [ tos TOS ]\n"
+		"                  [ flowlabel LABEL ]\n"
+		"                  [ dstport PORT ]\n"
+		"                  [ [no]external ]\n"
+		"                  [ [no]udpcsum ]\n"
+		"                  [ [no]udp6zerocsumtx ]\n"
+		"                  [ [no]udp6zerocsumrx ]\n"
+		"\n"
+		"Where: VNI   := 0-16777215\n"
+		"       ADDR  := IP_ADDRESS\n"
+		"       TOS   := { NUMBER | inherit }\n"
+		"       TTL   := { 1..255 | inherit }\n"
+		"       LABEL := 0-1048575\n"
+	);
 }
 
 static void explain(void)
diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
index cb204af4a25b5..86dc65caa5e01 100644
--- a/ip/iplink_ipoib.c
+++ b/ip/iplink_ipoib.c
@@ -22,7 +22,9 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... ipoib [pkey PKEY] [mode {datagram | connected}][umcast {0|1}]\n"
+		"Usage: ... ipoib [ pkey PKEY ]\n"
+		"                 [ mode {datagram | connected} ]\n"
+		"                 [ umcast {0|1} ]\n"
 		"\n"
 		"PKEY  := 0x8001-0xffff\n"
 	);
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 144c83cbf1f37..b47236d8054de 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -21,14 +21,17 @@
 static void print_explain(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... vlan [ protocol VLANPROTO ] id VLANID                [ FLAG-LIST ]\n"
-		"                [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
+		"Usage: ... vlan id VLANID\n"
+		"                [ protocol VLANPROTO ]\n"
+		"                [ reorder_hdr { on | off } ]\n"
+		"                [ gvrp { on | off } ]\n"
+		"                [ mvrp { on | off } ]\n"
+		"                [ loose_binding { on | off } ]\n"
+		"                [ ingress-qos-map QOS-MAP ]\n"
+		"                [ egress-qos-map QOS-MAP ]\n"
 		"\n"
-		"VLANPROTO: [ 802.1Q / 802.1ad ]\n"
 		"VLANID := 0-4095\n"
-		"FLAG-LIST := [ FLAG-LIST ] FLAG\n"
-		"FLAG := [ reorder_hdr { on | off } ] [ gvrp { on | off } ] [ mvrp { on | off } ]\n"
-		"        [ loose_binding { on | off } ]\n"
+		"VLANPROTO: [ 802.1Q / 802.1ad ]\n"
 		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
 		"QOS-MAPPING := FROM:TO\n"
 	);
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index fef7d3af4990f..b4ebb1394e702 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -23,21 +23,35 @@
 
 static void print_explain(FILE *f)
 {
-	fprintf(f, "Usage: ... vxlan id VNI [ { group | remote } IP_ADDRESS ] [ local ADDR ]\n");
-	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ flowlabel LABEL ] [ dev PHYS_DEV ]\n");
-	fprintf(f, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
-	fprintf(f, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
-	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
-	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
-	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
-	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
-	fprintf(f, "                 [ [no]external ] [ gbp ] [ gpe ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: VNI   := 0-16777215\n");
-	fprintf(f, "       ADDR  := { IP_ADDRESS | any }\n");
-	fprintf(f, "       TOS   := { NUMBER | inherit }\n");
-	fprintf(f, "       TTL   := { 1..255 | inherit }\n");
-	fprintf(f, "       LABEL := 0-1048575\n");
+	fprintf(f,
+		"Usage: ... vxlan id VNI\n"
+		"                 [ { group | remote } IP_ADDRESS ]\n"
+		"                 [ local ADDR ]\n"
+		"                 [ ttl TTL ]\n"
+		"                 [ tos TOS ]\n"
+		"                 [ flowlabel LABEL ]\n"
+		"                 [ dev PHYS_DEV ]\n"
+		"                 [ dstport PORT ]\n"
+		"                 [ srcport MIN MAX ]\n"
+		"                 [ [no]learning ]\n"
+		"                 [ [no]proxy ]\n"
+		"                 [ [no]rsc ]\n"
+		"                 [ [no]l2miss ]\n"
+		"                 [ [no]l3miss ]\n"
+		"                 [ ageing SECONDS ]\n"
+		"                 [ maxaddress NUMBER ]\n"
+		"                 [ [no]udpcsum ]\n"
+		"                 [ [no]udp6zerocsumtx ]\n"
+		"                 [ [no]udp6zerocsumrx ]\n"
+		"                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n"
+		"                 [ [no]external ] [ gbp ] [ gpe ]\n"
+		"\n"
+		"Where: VNI   := 0-16777215\n"
+		"       ADDR  := { IP_ADDRESS | any }\n"
+		"       TOS   := { NUMBER | inherit }\n"
+		"       TTL   := { 1..255 | inherit }\n"
+		"       LABEL := 0-1048575\n"
+	);
 }
 
 static void explain(void)
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 3b99e56f40748..35d437a15562c 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -25,19 +25,29 @@
 
 static void print_usage(FILE *f)
 {
-	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(f, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
-	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
-	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: NAME := STRING\n");
-	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
-	fprintf(f, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	fprintf(f,
+		"Usage: ... { gre | gretap } [ remote ADDR ]\n"
+		"                            [ local ADDR ]\n"
+		"                            [ [i|o]seq ]\n"
+		"                            [ [i|o]key KEY ]\n"
+		"                            [ [i|o]csum ]\n"
+		"                            [ ttl TTL ]\n"
+		"                            [ tos TOS ]\n"
+		"                            [ [no]pmtudisc ]\n"
+		"                            [ dev PHYS_DEV ]\n"
+		"                            [ noencap ]\n"
+		"                            [ encap { fou | gue | none } ]\n"
+		"                            [ encap-sport PORT ]\n"
+		"                            [ encap-dport PORT ]\n"
+		"                            [ [no]encap-csum ]\n"
+		"                            [ [no]encap-csum6 ]\n"
+		"                            [ [no]encap-remcsum ]\n"
+		"\n"
+		"Where: ADDR := { IP_ADDRESS | any }\n"
+		"       TOS  := { NUMBER | inherit }\n"
+		"       TTL  := { 1..255 | inherit }\n"
+		"       KEY  := { DOTTED_QUAD | NUMBER }\n"
+	);
 }
 
 static void usage(void) __attribute__((noreturn));
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index d00db1f8919db..a91f635760faa 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -32,25 +32,34 @@
 
 static void print_usage(FILE *f)
 {
-	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(f, "          type { ip6gre | ip6gretap } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(f, "          [ hoplimit TTL ] [ encaplimit ELIM ]\n");
-	fprintf(f, "          [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
-	fprintf(f, "          [ dscp inherit ] [ dev PHYS_DEV ]\n");
-	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
-	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: NAME      := STRING\n");
-	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
-	fprintf(f, "       TTL       := { 0..255 } (default=%d)\n",
-		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(f, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
-	fprintf(f, "       ELIM      := { none | 0..255 }(default=%d)\n",
-		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
-	fprintf(f, "       TCLASS    := { 0x0..0xff | inherit }\n");
-	fprintf(f, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(f,
+		"Usage: ... { ip6gre | ip6gretap } [ remote ADDR ]\n"
+		"                                  [ local ADDR ]\n"
+		"                                  [ [i|o]seq ]\n"
+		"                                  [ [i|o]key KEY ]\n"
+		"                                  [ [i|o]csum ]\n"
+		"                                  [ hoplimit TTL ]\n"
+		"                                  [ encaplimit ELIM ]\n"
+		"                                  [ tclass TCLASS ]\n"
+		"                                  [ flowlabel FLOWLABEL ]\n"
+		"                                  [ dscp inherit ]\n"
+		"                                  [ dev PHYS_DEV ]\n"
+		"                                  [ noencap ]\n"
+		"                                  [ encap { fou | gue | none } ]\n"
+		"                                  [ encap-sport PORT ]\n"
+		"                                  [ encap-dport PORT ]\n"
+		"                                  [ [no]encap-csum ]\n"
+		"                                  [ [no]encap-csum6 ]\n"
+		"                                  [ [no]encap-remcsum ]\n"
+		"\n"
+		"Where: ADDR      := IPV6_ADDRESS\n"
+		"       TTL       := { 0..255 } (default=%d)\n"
+		"       KEY       := { DOTTED_QUAD | NUMBER }\n"
+		"       ELIM      := { none | 0..255 }(default=%d)\n"
+		"       TCLASS    := { 0x0..0xff | inherit }\n"
+		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n",
+		DEFAULT_TNL_HOP_LIMIT, IPV6_DEFAULT_TNL_ENCAP_LIMIT
+	);
 }
 
 static void usage(void) __attribute__((noreturn));
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 051c89f4fe57c..6bb968d3c9189 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -31,25 +31,33 @@
 
 static void print_usage(FILE *f)
 {
-	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(f, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
-	fprintf(f, "          type ip6tnl [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(f, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
-	fprintf(f, "          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
-	fprintf(f, "          [ dscp inherit ] [ fwmark inherit ]\n");
-	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
-	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
-	fprintf(f, "          [ external ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: NAME      := STRING\n");
-	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
-	fprintf(f, "       ELIM      := { none | 0..255 }(default=%d)\n",
-		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
-	fprintf(f, "       HLIM      := 0..255 (default=%d)\n",
-		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(f, "       TCLASS    := { 0x0..0xff | inherit }\n");
-	fprintf(f, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(f,
+		"Usage: ... ip6tnl [ mode { ip6ip6 | ipip6 | any } ]\n"
+		"                  [ remote ADDR ]\n"
+		"                  [ local ADDR ]\n"
+		"                  [ dev PHYS_DEV ]\n"
+		"                  [ encaplimit ELIM ]\n"
+		"                  [ hoplimit HLIM ]\n"
+		"                  [ tclass TCLASS ]\n"
+		"                  [ flowlabel FLOWLABEL ]\n"
+		"                  [ dscp inherit ]\n"
+		"                  [ fwmark inherit ]\n"
+		"                  [ noencap ]\n"
+		"                  [ encap { fou | gue | none } ]\n"
+		"                  [ encap-sport PORT ]\n"
+		"                  [ encap-dport PORT ]\n"
+		"                  [ [no]encap-csum ]\n"
+		"                  [ [no]encap-csum6 ]\n"
+		"                  [ [no]encap-remcsum ]\n"
+		"                  [ external ]\n"
+		"\n"
+		"Where: ADDR      := IPV6_ADDRESS\n"
+		"       ELIM      := { none | 0..255 }(default=%d)\n"
+		"       HLIM      := 0..255 (default=%d)\n"
+		"       TCLASS    := { 0x0..0xff | inherit }\n"
+		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n",
+		IPV6_DEFAULT_TNL_ENCAP_LIMIT, DEFAULT_TNL_HOP_LIMIT
+	);
 }
 
 static void usage(void) __attribute__((noreturn));
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index a96b1eb4c94ce..f180b921e4710 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -25,21 +25,35 @@
 
 static void print_usage(FILE *f, int sit)
 {
-	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(f, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
-	fprintf(f, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
-	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
-	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
-	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
+	const char *type = sit ? "sit " : "ipip";
+
+	fprintf(f,
+		"Usage: ... %s [ remote ADDR ]\n"
+		"                [ local ADDR ]\n"
+		"                [ ttl TTL ]\n"
+		"                [ tos TOS ]\n"
+		"                [ [no]pmtudisc ]\n"
+		"                [ dev PHYS_DEV ]\n"
+		"                [ 6rd-prefix ADDR ]\n"
+		"                [ 6rd-relay_prefix ADDR ]\n"
+		"                [ 6rd-reset ]\n"
+		"                [ noencap ]\n"
+		"                [ encap { fou | gue | none } ]\n"
+		"                [ encap-sport PORT ]\n"
+		"                [ encap-dport PORT ]\n"
+		"                [ [no]encap-csum ]\n"
+		"                [ [no]encap-csum6 ]\n"
+		"                [ [no]encap-remcsum ]\n",
+		type
+	);
 	if (sit) {
-		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
-		fprintf(f, "          [ isatap ]\n");
+		fprintf(f,
+			"                [ mode { ip6ip | ipip | any } ]\n"
+			"                [ isatap ]\n");
 	}
-	fprintf(f, "          [ external ]\n");
+	fprintf(f, "                [ external ]\n");
 	fprintf(f, "\n");
-	fprintf(f, "Where: NAME := STRING\n");
-	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(f, "Where: ADDR := { IP_ADDRESS | any }\n");
 	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
 	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
 }
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 93bbce44423da..95bc23e928972 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -26,14 +26,15 @@
 
 static void print_usage(FILE *f)
 {
-	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(f, "          type { vti } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(f, "          [ [i|o]key KEY ]\n");
-	fprintf(f, "          [ dev PHYS_DEV ]\n");
-	fprintf(f, "\n");
-	fprintf(f, "Where: NAME := STRING\n");
-	fprintf(f, "       ADDR := { IP_ADDRESS }\n");
-	fprintf(f, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	fprintf(f,
+		"Usage: ... vti [ remote ADDR ]\n"
+		"               [ local ADDR ]\n"
+		"               [ [i|o]key KEY ]\n"
+		"               [ dev PHYS_DEV ]\n"
+		"\n"
+		"Where: ADDR := { IP_ADDRESS }\n"
+		"       KEY  := { DOTTED_QUAD | NUMBER }\n"
+	);
 }
 
 static void usage(void) __attribute__((noreturn));
-- 
2.11.0
