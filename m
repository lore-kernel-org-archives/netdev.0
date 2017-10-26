From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool] ethtool: Fix coding style warnings and errors reported by checkpatch
Date: Thu, 26 Oct 2017 17:44:43 +0300
Message-ID: <1509029084-18788-1-git-send-email-galp@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41606 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932291AbdJZOpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 10:45:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch had a lot to say about ethtool.c, this will handle a lot of
the reported issues.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 ethtool.c | 189 +++++++++++++++++++++++++++++---------------------------------
 1 file changed, 89 insertions(+), 100 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index ad18704..2d53c29 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -235,7 +235,7 @@ get_uint_range(char *str, int base, unsigned long long max)
 		exit_bad_args();
 	errno = 0;
 	v = strtoull(str, &endp, base);
-	if ( errno || *endp || v > max)
+	if (errno || *endp || v > max)
 		exit_bad_args();
 	return v;
 }
@@ -261,9 +261,8 @@ static void get_mac_addr(char *src, unsigned char *dest)
 	if (count != ETH_ALEN)
 		exit_bad_args();
 
-	for (i = 0; i < count; i++) {
+	for (i = 0; i < count; i++)
 		dest[i] = buf[i];
-	}
 }
 
 static int parse_hex_u32_bitmap(const char *s,
@@ -408,7 +407,7 @@ static void parse_generic_cmdline(struct cmd_context *ctx,
 				break;
 			}
 		}
-		if( !found)
+		if (!found)
 			exit_bad_args();
 	}
 }
@@ -683,10 +682,10 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 		  "10000baseLRM/Full" },
 		{ 0, ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
 		  "10000baseER/Full" },
-                { 0, ETHTOOL_LINK_MODE_2500baseT_Full_BIT,
-                  "2500baseT/Full" },
-                { 0, ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
-                  "5000baseT/Full" },
+		{ 0, ETHTOOL_LINK_MODE_2500baseT_Full_BIT,
+		  "2500baseT/Full" },
+		{ 0, ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
+		  "5000baseT/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
@@ -715,7 +714,7 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 		}
 	}
 	if (did1 == 0)
-		 fprintf(stdout, "Not reported");
+		fprintf(stdout, "Not reported");
 	fprintf(stdout, "\n");
 
 	if (!link_mode_only) {
@@ -887,32 +886,32 @@ static int parse_wolopts(char *optstr, u32 *data)
 	*data = 0;
 	while (*optstr) {
 		switch (*optstr) {
-			case 'p':
-				*data |= WAKE_PHY;
-				break;
-			case 'u':
-				*data |= WAKE_UCAST;
-				break;
-			case 'm':
-				*data |= WAKE_MCAST;
-				break;
-			case 'b':
-				*data |= WAKE_BCAST;
-				break;
-			case 'a':
-				*data |= WAKE_ARP;
-				break;
-			case 'g':
-				*data |= WAKE_MAGIC;
-				break;
-			case 's':
-				*data |= WAKE_MAGICSECURE;
-				break;
-			case 'd':
-				*data = 0;
-				break;
-			default:
-				return -1;
+		case 'p':
+			*data |= WAKE_PHY;
+			break;
+		case 'u':
+			*data |= WAKE_UCAST;
+			break;
+		case 'm':
+			*data |= WAKE_MCAST;
+			break;
+		case 'b':
+			*data |= WAKE_BCAST;
+			break;
+		case 'a':
+			*data |= WAKE_ARP;
+			break;
+		case 'g':
+			*data |= WAKE_MAGIC;
+			break;
+		case 's':
+			*data |= WAKE_MAGICSECURE;
+			break;
+		case 'd':
+			*data = 0;
+			break;
+		default:
+			return -1;
 		}
 		optstr++;
 	}
@@ -957,10 +956,11 @@ static int dump_wol(struct ethtool_wolinfo *wol)
 	if (wol->supported & WAKE_MAGICSECURE) {
 		int i;
 		int delim = 0;
+
 		fprintf(stdout, "        SecureOn password: ");
 		for (i = 0; i < SOPASS_MAX; i++) {
 			fprintf(stdout, "%s%02x", delim?":":"", wol->sopass[i]);
-			delim=1;
+			delim = 1;
 		}
 		fprintf(stdout, "\n");
 	}
@@ -973,32 +973,32 @@ static int parse_rxfhashopts(char *optstr, u32 *data)
 	*data = 0;
 	while (*optstr) {
 		switch (*optstr) {
-			case 'm':
-				*data |= RXH_L2DA;
-				break;
-			case 'v':
-				*data |= RXH_VLAN;
-				break;
-			case 't':
-				*data |= RXH_L3_PROTO;
-				break;
-			case 's':
-				*data |= RXH_IP_SRC;
-				break;
-			case 'd':
-				*data |= RXH_IP_DST;
-				break;
-			case 'f':
-				*data |= RXH_L4_B_0_1;
-				break;
-			case 'n':
-				*data |= RXH_L4_B_2_3;
-				break;
-			case 'r':
-				*data |= RXH_DISCARD;
-				break;
-			default:
-				return -1;
+		case 'm':
+			*data |= RXH_L2DA;
+			break;
+		case 'v':
+			*data |= RXH_VLAN;
+			break;
+		case 't':
+			*data |= RXH_L3_PROTO;
+			break;
+		case 's':
+			*data |= RXH_IP_SRC;
+			break;
+		case 'd':
+			*data |= RXH_IP_DST;
+			break;
+		case 'f':
+			*data |= RXH_L4_B_0_1;
+			break;
+		case 'n':
+			*data |= RXH_L4_B_2_3;
+			break;
+		case 'r':
+			*data |= RXH_DISCARD;
+			break;
+		default:
+			return -1;
 		}
 		optstr++;
 	}
@@ -1012,27 +1012,20 @@ static char *unparse_rxfhashopts(u64 opts)
 	memset(buf, 0, sizeof(buf));
 
 	if (opts) {
-		if (opts & RXH_L2DA) {
+		if (opts & RXH_L2DA)
 			strcat(buf, "L2DA\n");
-		}
-		if (opts & RXH_VLAN) {
+		if (opts & RXH_VLAN)
 			strcat(buf, "VLAN tag\n");
-		}
-		if (opts & RXH_L3_PROTO) {
+		if (opts & RXH_L3_PROTO)
 			strcat(buf, "L3 proto\n");
-		}
-		if (opts & RXH_IP_SRC) {
+		if (opts & RXH_IP_SRC)
 			strcat(buf, "IP SA\n");
-		}
-		if (opts & RXH_IP_DST) {
+		if (opts & RXH_IP_DST)
 			strcat(buf, "IP DA\n");
-		}
-		if (opts & RXH_L4_B_0_1) {
+		if (opts & RXH_L4_B_0_1)
 			strcat(buf, "L4 bytes 0 & 1 [TCP/UDP src port]\n");
-		}
-		if (opts & RXH_L4_B_2_3) {
+		if (opts & RXH_L4_B_2_3)
 			strcat(buf, "L4 bytes 2 & 3 [TCP/UDP dst port]\n");
-		}
 	} else {
 		sprintf(buf, "None");
 	}
@@ -1133,10 +1126,10 @@ static const struct {
 	{ "tg3", tg3_dump_regs },
 	{ "skge", skge_dump_regs },
 	{ "sky2", sky2_dump_regs },
-        { "vioc", vioc_dump_regs },
-        { "smsc911x", smsc911x_dump_regs },
-        { "at76c50x-usb", at76c50x_usb_dump_regs },
-        { "sfc", sfc_dump_regs },
+	{ "vioc", vioc_dump_regs },
+	{ "smsc911x", smsc911x_dump_regs },
+	{ "at76c50x-usb", at76c50x_usb_dump_regs },
+	{ "sfc", sfc_dump_regs },
 	{ "st_mac100", st_mac100_dump_regs },
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
@@ -2762,7 +2755,7 @@ static int do_sset(struct cmd_context *ctx)
 			i += 1;
 			if (i >= argc)
 				exit_bad_args();
-			speed_wanted = get_int(argp[i],10);
+			speed_wanted = get_int(argp[i], 10);
 		} else if (!strcmp(argp[i], "duplex")) {
 			gset_changed = 1;
 			i += 1;
@@ -2973,7 +2966,7 @@ static int do_sset(struct cmd_context *ctx)
 						speed_wanted);
 				if (duplex_wanted >= 0)
 					fprintf(stderr, " duplex %s",
-						duplex_wanted ? 
+						duplex_wanted ?
 						"full" : "half");
 				fprintf(stderr,	"\n");
 			}
@@ -3058,14 +3051,12 @@ static int do_sset(struct cmd_context *ctx)
 			perror("Cannot get current wake-on-lan settings");
 		} else {
 			/* Change everything the user specified. */
-			if (wol_change) {
+			if (wol_change)
 				wol.wolopts = wol_wanted;
-			}
 			if (sopass_change) {
 				int i;
-				for (i = 0; i < SOPASS_MAX; i++) {
+				for (i = 0; i < SOPASS_MAX; i++)
 					wol.sopass[i] = sopass_wanted[i];
-				}
 			}
 
 			/* Try to perform the update. */
@@ -3162,7 +3153,7 @@ static int do_gregs(struct cmd_context *ctx)
 			free(regs);
 			return 75;
 		}
-        }
+	}
 
 	if (dump_regs(gregs_dump_raw, gregs_dump_hex,
 		      &drvinfo, regs) < 0) {
@@ -3321,7 +3312,7 @@ static int do_seeprom(struct cmd_context *ctx)
 static int do_test(struct cmd_context *ctx)
 {
 	enum {
-		ONLINE=0,
+		ONLINE = 0,
 		OFFLINE,
 		EXTERNAL_LB,
 	} test_type;
@@ -3332,15 +3323,14 @@ static int do_test(struct cmd_context *ctx)
 	if (ctx->argc > 1)
 		exit_bad_args();
 	if (ctx->argc == 1) {
-		if (!strcmp(ctx->argp[0], "online")) {
+		if (!strcmp(ctx->argp[0], "online"))
 			test_type = ONLINE;
-	 	} else if (!strcmp(*ctx->argp, "offline")) {
+		else if (!strcmp(*ctx->argp, "offline"))
 			test_type = OFFLINE;
-		} else if (!strcmp(*ctx->argp, "external_lb")) {
+		else if (!strcmp(*ctx->argp, "external_lb"))
 			test_type = EXTERNAL_LB;
-		} else {
+		else
 			exit_bad_args();
-		}
 	} else {
 		test_type = OFFLINE;
 	}
@@ -3371,7 +3361,7 @@ static int do_test(struct cmd_context *ctx)
 	err = send_ioctl(ctx, test);
 	if (err < 0) {
 		perror("Cannot test");
-		free (test);
+		free(test);
 		free(strings);
 		return 74;
 	}
@@ -3502,7 +3492,7 @@ static int do_srxclass(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &nfccmd);
 		if (err < 0)
 			perror("Cannot change RX network flow hashing options");
-	} else if (!strcmp(ctx->argp[0], "flow-type")) {	
+	} else if (!strcmp(ctx->argp[0], "flow-type")) {
 		struct ethtool_rx_flow_spec rx_rule_fs;
 
 		ctx->argc--;
@@ -4183,8 +4173,8 @@ static int do_srxntuple(struct cmd_context *ctx,
 	/*
 	 * Display error only if response is something other than op not
 	 * supported.  It is possible that the interface uses the network
-	 * flow classifier interface instead of N-tuple. 
-	 */ 
+	 * flow classifier interface instead of N-tuple.
+	 */
 	if (err < 0) {
 		if (errno != EOPNOTSUPP)
 			perror("Cannot add new rule via N-tuple");
@@ -4326,7 +4316,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 
 	/* Find longest string and align all strings accordingly */
 	for (i = 0; i < strings->len; i++) {
-		cur_len = strlen((const char*)strings->data +
+		cur_len = strlen((const char *)strings->data +
 				 i * ETH_GSTRING_LEN);
 		if (cur_len > max_len)
 			max_len = cur_len;
@@ -4576,7 +4566,6 @@ static int do_seee(struct cmd_context *ctx)
 	do_generic_set(cmdline_eee, ARRAY_SIZE(cmdline_eee), &change2);
 
 	if (change2) {
-
 		eeecmd.cmd = ETHTOOL_SEEE;
 		if (send_ioctl(ctx, &eeecmd)) {
 			perror("Cannot set EEE settings");
@@ -4874,7 +4863,7 @@ static const struct option {
 	  "               [ tx N ]\n"
 	  "               [ other N ]\n"
 	  "               [ combined N ]\n" },
-	{ "--show-priv-flags" , 1, do_gprivflags, "Query private flags" },
+	{ "--show-priv-flags", 1, do_gprivflags, "Query private flags" },
 	{ "--set-priv-flags", 1, do_sprivflags, "Set private flags",
 	  "		FLAG on|off ...\n" },
 	{ "-m|--dump-module-eeprom|--module-info", 1, do_getmodule,
-- 
2.7.4
