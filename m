From: Peter Heise <mail@pheise.de>
Subject: [PATCH iproute2] Added support for selection of new HSR version
Date: Mon, 30 May 2016 15:32:07 +0200
Message-ID: <20160530133207.GA5071@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peter.heise@airbus.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pheise.de ([81.88.24.24]:56853 "EHLO ghost.pheise.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468AbcE3Nkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 09:40:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new HSR version was added in 4.7 that can be enabled
via iproute2. Per default the old version is selected,
however, with "ip link add [..] type hsr [..] version 1"
the newer version can be enabled.

Signed-off-by: Peter Heise <peter.heise@airbus.com>
---
 ip/iplink_hsr.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
index 65fbec8..84d3a65 100644
--- a/ip/iplink_hsr.c
+++ b/ip/iplink_hsr.c
@@ -25,7 +25,7 @@ static void print_usage(FILE *f)
 {
 	fprintf(f,
 "Usage:\tip link add name NAME type hsr slave1 SLAVE1-IF slave2 SLAVE2-IF\n"
-"\t[ supervision ADDR-BYTE ]\n"
+"\t[ supervision ADDR-BYTE ] [version VERSION]\n"
 "\n"
 "NAME\n"
 "	name of new hsr device (e.g. hsr0)\n"
@@ -33,7 +33,9 @@ static void print_usage(FILE *f)
 "	the two slave devices bound to the HSR device\n"
 "ADDR-BYTE\n"
 "	0-255; the last byte of the multicast address used for HSR supervision\n"
-"	frames (default = 0)\n");
+"	frames (default = 0)\n"
+"VERSION\n"
+"	0,1; the protocol version to be used. (default = 0)\n");
 }
 
 static void usage(void)
@@ -46,6 +48,7 @@ static int hsr_parse_opt(struct link_util *lu, int argc, char **argv,
 {
 	int ifindex;
 	unsigned char multicast_spec;
+	unsigned char protocol_version;
 
 	while (argc > 0) {
 		if (matches(*argv, "supervision") == 0) {
@@ -54,6 +57,12 @@ static int hsr_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("ADDR-BYTE is invalid", *argv);
 			addattr_l(n, 1024, IFLA_HSR_MULTICAST_SPEC,
 				  &multicast_spec, 1);
+		} else if (matches(*argv, "version") == 0) {
+				NEXT_ARG();
+				if (!(get_u8(&protocol_version, *argv, 0) == 0 || get_u8(&protocol_version, *argv, 0) == 1))
+					invarg("VERSION is invalid", *argv);
+				addattr_l(n, 1024, IFLA_HSR_VERSION,
+					  &protocol_version, 1);
 		} else if (matches(*argv, "slave1") == 0) {
 			NEXT_ARG();
 			ifindex = ll_name_to_index(*argv);
-- 
2.7.4
