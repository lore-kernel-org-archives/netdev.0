From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 21/21] Rearrange definitions and remove unnecessary
 forward declarations
Date: Tue, 1 Nov 2011 23:24:14 +0000
Message-ID: <1320189854.2758.53.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38874 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056Ab1KAXYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:24:18 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most functions in ethtool.c are defined before use.  The major
exception is that the args array refers to a large number of functions
defined after it.  Move the args array and show_usage() functions down,
and move a few other functions up.

This leaves just one forward declaration in ethtool.c, which is
unavoidable because show_usage() and args refer to each other.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |  447 ++++++++++++++++++++++++++++---------------------------------
 1 files changed, 204 insertions(+), 243 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f192376..d59ca31 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -64,194 +64,6 @@ enum {
 };
 #endif
 
-static int show_usage(struct cmd_context *ctx);
-static int do_version(struct cmd_context *ctx);
-static int parse_wolopts(char *optstr, u32 *data);
-static char *unparse_wolopts(int wolopts);
-static void get_mac_addr(char *src, unsigned char *dest);
-static int do_gdrv(struct cmd_context *ctx);
-static int do_gset(struct cmd_context *ctx);
-static int do_sset(struct cmd_context *ctx);
-static int do_gregs(struct cmd_context *ctx);
-static int do_nway_rst(struct cmd_context *ctx);
-static int do_geeprom(struct cmd_context *ctx);
-static int do_seeprom(struct cmd_context *ctx);
-static int do_test(struct cmd_context *ctx);
-static int do_phys_id(struct cmd_context *ctx);
-static int do_gpause(struct cmd_context *ctx);
-static int do_spause(struct cmd_context *ctx);
-static int do_gring(struct cmd_context *ctx);
-static int do_sring(struct cmd_context *ctx);
-static int do_schannels(struct cmd_context *ctx);
-static int do_gchannels(struct cmd_context *ctx);
-static int do_gcoalesce(struct cmd_context *ctx);
-static int do_scoalesce(struct cmd_context *ctx);
-static int do_goffload(struct cmd_context *ctx);
-static int do_soffload(struct cmd_context *ctx);
-static int do_gstats(struct cmd_context *ctx);
-static int rxflow_str_to_type(const char *str);
-static int parse_rxfhashopts(char *optstr, u32 *data);
-static char *unparse_rxfhashopts(u64 opts);
-static int dump_rxfhash(int fhash, u64 val);
-static int do_srxclass(struct cmd_context *ctx);
-static int do_grxclass(struct cmd_context *ctx);
-static int do_grxfhindir(struct cmd_context *ctx);
-static int do_srxfhindir(struct cmd_context *ctx);
-static int do_srxclsrule(struct cmd_context *ctx);
-static int do_grxclsrule(struct cmd_context *ctx);
-static int do_flash(struct cmd_context *ctx);
-static int do_permaddr(struct cmd_context *ctx);
-static int do_getfwdump(struct cmd_context *ctx);
-static int do_setfwdump(struct cmd_context *ctx);
-
-static const struct option {
-	const char *opts;
-	int want_device;
-	int (*func)(struct cmd_context *);
-	char *help;
-	char *opthelp;
-} args[] = {
-	{ "-s|--change", 1, do_sset, "Change generic options",
-	  "		[ speed %d ]\n"
-	  "		[ duplex half|full ]\n"
-	  "		[ port tp|aui|bnc|mii|fibre ]\n"
-	  "		[ autoneg on|off ]\n"
-	  "		[ advertise %x ]\n"
-	  "		[ phyad %d ]\n"
-	  "		[ xcvr internal|external ]\n"
-	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
-	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
-	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
-	{ "-a|--show-pause", 1, do_gpause, "Show pause options" },
-	{ "-A|--pause", 1, do_spause, "Set pause options",
-	  "		[ autoneg on|off ]\n"
-	  "		[ rx on|off ]\n"
-	  "		[ tx on|off ]\n" },
-	{ "-c|--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
-	{ "-C|--coalesce", 1, do_scoalesce, "Set coalesce options",
-	  "		[adaptive-rx on|off]\n"
-	  "		[adaptive-tx on|off]\n"
-	  "		[rx-usecs N]\n"
-	  "		[rx-frames N]\n"
-	  "		[rx-usecs-irq N]\n"
-	  "		[rx-frames-irq N]\n"
-	  "		[tx-usecs N]\n"
-	  "		[tx-frames N]\n"
-	  "		[tx-usecs-irq N]\n"
-	  "		[tx-frames-irq N]\n"
-	  "		[stats-block-usecs N]\n"
-	  "		[pkt-rate-low N]\n"
-	  "		[rx-usecs-low N]\n"
-	  "		[rx-frames-low N]\n"
-	  "		[tx-usecs-low N]\n"
-	  "		[tx-frames-low N]\n"
-	  "		[pkt-rate-high N]\n"
-	  "		[rx-usecs-high N]\n"
-	  "		[rx-frames-high N]\n"
-	  "		[tx-usecs-high N]\n"
-	  "		[tx-frames-high N]\n"
-	  "		[sample-interval N]\n" },
-	{ "-g|--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
-	{ "-G|--set-ring", 1, do_sring, "Set RX/TX ring parameters",
-	  "		[ rx N ]\n"
-	  "		[ rx-mini N ]\n"
-	  "		[ rx-jumbo N ]\n"
-	  "		[ tx N ]\n" },
-	{ "-k|--show-offload", 1, do_goffload,
-	  "Get protocol offload information" },
-	{ "-K|--offload", 1, do_soffload, "Set protocol offload",
-	  "		[ rx on|off ]\n"
-	  "		[ tx on|off ]\n"
-	  "		[ sg on|off ]\n"
-	  "		[ tso on|off ]\n"
-	  "		[ ufo on|off ]\n"
-	  "		[ gso on|off ]\n"
-	  "		[ gro on|off ]\n"
-	  "		[ lro on|off ]\n"
-	  "		[ rxvlan on|off ]\n"
-	  "		[ txvlan on|off ]\n"
-	  "		[ ntuple on|off ]\n"
-	  "		[ rxhash on|off ]\n"
-	},
-	{ "-i|--driver", 1, do_gdrv, "Show driver information" },
-	{ "-d|--register-dump", 1, do_gregs, "Do a register dump",
-	  "		[ raw on|off ]\n"
-	  "		[ file FILENAME ]\n" },
-	{ "-e|--eeprom-dump", 1, do_geeprom, "Do a EEPROM dump",
-	  "		[ raw on|off ]\n"
-	  "		[ offset N ]\n"
-	  "		[ length N ]\n" },
-	{ "-E|--change-eeprom", 1, do_seeprom,
-	  "Change bytes in device EEPROM",
-	  "		[ magic N ]\n"
-	  "		[ offset N ]\n"
-	  "		[ length N ]\n"
-	  "		[ value N ]\n" },
-	{ "-r|--negotiate", 1, do_nway_rst, "Restart N-WAY negotiation" },
-	{ "-p|--identify", 1, do_phys_id,
-	  "Show visible port identification (e.g. blinking)",
-	  "               [ TIME-IN-SECONDS ]\n" },
-	{ "-t|--test", 1, do_test, "Execute adapter self test",
-	  "               [ online | offline | external_lb ]\n" },
-	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
-	{ "-n|--show-nfc", 1, do_grxclass,
-	  "Show Rx network flow classification options",
-	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
-	{ "-f|--flash", 1, do_flash,
-	  "Flash firmware image from the specified file to a region on the device",
-	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-	{ "-N|--config-nfc", 1, do_srxclass,
-	  "Configure Rx network flow classification options",
-	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
-	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
-	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
-	  "Show Rx flow hash indirection" },
-	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
-	  "Set Rx flow hash indirection",
-	  "		equal N | weight W0 W1 ...\n" },
-	{ "-U|--config-ntuple", 1, do_srxclsrule,
-	  "Configure Rx ntuple filters and actions",
-	  "		[ delete %d ] |\n"
-	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
-	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
-	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
-	  "			[ proto %d [m %x] ]\n"
-	  "			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
-	  "			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
-	  "			[ tos %d [m %x] ]\n"
-	  "			[ l4proto %d [m %x] ]\n"
-	  "			[ src-port %d [m %x] ]\n"
-	  "			[ dst-port %d [m %x] ]\n"
-	  "			[ spi %d [m %x] ]\n"
-	  "			[ vlan-etype %x [m %x] ]\n"
-	  "			[ vlan %x [m %x] ]\n"
-	  "			[ user-def %x [m %x] ]\n"
-	  "			[ action %d ]\n"
-	  "			[ loc %d]]\n" },
-	{ "-u|--show-ntuple", 1, do_grxclsrule,
-	  "Get Rx ntuple filters and actions",
-	  "		[ rule %d ]\n"},
-	{ "-P|--show-permaddr", 1, do_permaddr,
-	  "Show permanent hardware address" },
-	{ "-w|--get-dump", 1, do_getfwdump,
-	  "Get dump flag, data",
-	  "		[ data FILENAME ]\n" },
-	{ "-W|--set-dump", 1, do_setfwdump,
-	  "Set dump flag of the device",
-	  "		N\n"},
-	{ "-l|--show-channels", 1, do_gchannels, "Query Channels" },
-	{ "-L|--set-channels", 1, do_schannels, "Set Channels",
-	  "               [ rx N ]\n"
-	  "               [ tx N ]\n"
-	  "               [ other N ]\n"
-	  "               [ combined N ]\n" },
-	{ "-h|--help", 0, show_usage, "Show this help" },
-	{ "--version", 0, do_version, "Show version number" },
-	{}
-};
-
-
 static void exit_bad_args(void) __attribute__((noreturn));
 
 static void exit_bad_args(void)
@@ -262,29 +74,6 @@ static void exit_bad_args(void)
 	ethtool_exit(1);
 }
 
-static int show_usage(struct cmd_context *ctx)
-{
-	int i;
-
-	/* ethtool -h */
-	fprintf(stdout, PACKAGE " version " VERSION "\n");
-	fprintf(stdout,
-		"Usage:\n"
-		"        ethtool DEVNAME\t"
-		"Display standard information about device\n");
-	for (i = 0; args[i].opts; i++) {
-		fputs("        ethtool ", stdout);
-		fprintf(stdout, "%s %s\t%s\n",
-			args[i].opts,
-			args[i].want_device ? "DEVNAME" : "\t",
-			args[i].help);
-		if (args[i].opthelp)
-			fputs(args[i].opthelp, stdout);
-	}
-
-	return 0;
-}
-
 typedef enum {
 	CMDL_NONE,
 	CMDL_BOOL,
@@ -379,6 +168,22 @@ static u32 get_u32(char *str, int base)
 	return get_uint_range(str, base, 0xffffffff);
 }
 
+static void get_mac_addr(char *src, unsigned char *dest)
+{
+	int count;
+	int i;
+	int buf[ETH_ALEN];
+
+	count = sscanf(src, "%2x:%2x:%2x:%2x:%2x:%2x",
+		&buf[0], &buf[1], &buf[2], &buf[3], &buf[4], &buf[5]);
+	if (count != ETH_ALEN)
+		exit_bad_args();
+
+	for (i = 0; i < count; i++) {
+		dest[i] = buf[i];
+	}
+}
+
 static void parse_generic_cmdline(struct cmd_context *ctx,
 				  int *changed,
 				  struct cmdline_info *info,
@@ -791,26 +596,6 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 	return 0;
 }
 
-static int dump_wol(struct ethtool_wolinfo *wol)
-{
-	fprintf(stdout, "	Supports Wake-on: %s\n",
-		unparse_wolopts(wol->supported));
-	fprintf(stdout, "	Wake-on: %s\n",
-		unparse_wolopts(wol->wolopts));
-	if (wol->supported & WAKE_MAGICSECURE) {
-		int i;
-		int delim = 0;
-		fprintf(stdout, "        SecureOn password: ");
-		for (i = 0; i < SOPASS_MAX; i++) {
-			fprintf(stdout, "%s%02x", delim?":":"", wol->sopass[i]);
-			delim=1;
-		}
-		fprintf(stdout, "\n");
-	}
-
-	return 0;
-}
-
 static int parse_wolopts(char *optstr, u32 *data)
 {
 	*data = 0;
@@ -877,20 +662,24 @@ static char *unparse_wolopts(int wolopts)
 	return buf;
 }
 
-static void get_mac_addr(char *src, unsigned char *dest)
+static int dump_wol(struct ethtool_wolinfo *wol)
 {
-	int count;
-	int i;
-	int buf[ETH_ALEN];
-
-	count = sscanf(src, "%2x:%2x:%2x:%2x:%2x:%2x",
-		&buf[0], &buf[1], &buf[2], &buf[3], &buf[4], &buf[5]);
-	if (count != ETH_ALEN)
-		exit_bad_args();
-
-	for (i = 0; i < count; i++) {
-		dest[i] = buf[i];
+	fprintf(stdout, "	Supports Wake-on: %s\n",
+		unparse_wolopts(wol->supported));
+	fprintf(stdout, "	Wake-on: %s\n",
+		unparse_wolopts(wol->wolopts));
+	if (wol->supported & WAKE_MAGICSECURE) {
+		int i;
+		int delim = 0;
+		fprintf(stdout, "        SecureOn password: ");
+		for (i = 0; i < SOPASS_MAX; i++) {
+			fprintf(stdout, "%s%02x", delim?":":"", wol->sopass[i]);
+			delim=1;
+		}
+		fprintf(stdout, "\n");
 	}
+
+	return 0;
 }
 
 static int parse_rxfhashopts(char *optstr, u32 *data)
@@ -3213,6 +3002,178 @@ int send_ioctl(struct cmd_context *ctx, void *cmd)
 }
 #endif
 
+static int show_usage(struct cmd_context *ctx);
+
+static const struct option {
+	const char *opts;
+	int want_device;
+	int (*func)(struct cmd_context *);
+	char *help;
+	char *opthelp;
+} args[] = {
+	{ "-s|--change", 1, do_sset, "Change generic options",
+	  "		[ speed %d ]\n"
+	  "		[ duplex half|full ]\n"
+	  "		[ port tp|aui|bnc|mii|fibre ]\n"
+	  "		[ autoneg on|off ]\n"
+	  "		[ advertise %x ]\n"
+	  "		[ phyad %d ]\n"
+	  "		[ xcvr internal|external ]\n"
+	  "		[ wol p|u|m|b|a|g|s|d... ]\n"
+	  "		[ sopass %x:%x:%x:%x:%x:%x ]\n"
+	  "		[ msglvl %d | msglvl type on|off ... ]\n" },
+	{ "-a|--show-pause", 1, do_gpause, "Show pause options" },
+	{ "-A|--pause", 1, do_spause, "Set pause options",
+	  "		[ autoneg on|off ]\n"
+	  "		[ rx on|off ]\n"
+	  "		[ tx on|off ]\n" },
+	{ "-c|--show-coalesce", 1, do_gcoalesce, "Show coalesce options" },
+	{ "-C|--coalesce", 1, do_scoalesce, "Set coalesce options",
+	  "		[adaptive-rx on|off]\n"
+	  "		[adaptive-tx on|off]\n"
+	  "		[rx-usecs N]\n"
+	  "		[rx-frames N]\n"
+	  "		[rx-usecs-irq N]\n"
+	  "		[rx-frames-irq N]\n"
+	  "		[tx-usecs N]\n"
+	  "		[tx-frames N]\n"
+	  "		[tx-usecs-irq N]\n"
+	  "		[tx-frames-irq N]\n"
+	  "		[stats-block-usecs N]\n"
+	  "		[pkt-rate-low N]\n"
+	  "		[rx-usecs-low N]\n"
+	  "		[rx-frames-low N]\n"
+	  "		[tx-usecs-low N]\n"
+	  "		[tx-frames-low N]\n"
+	  "		[pkt-rate-high N]\n"
+	  "		[rx-usecs-high N]\n"
+	  "		[rx-frames-high N]\n"
+	  "		[tx-usecs-high N]\n"
+	  "		[tx-frames-high N]\n"
+	  "		[sample-interval N]\n" },
+	{ "-g|--show-ring", 1, do_gring, "Query RX/TX ring parameters" },
+	{ "-G|--set-ring", 1, do_sring, "Set RX/TX ring parameters",
+	  "		[ rx N ]\n"
+	  "		[ rx-mini N ]\n"
+	  "		[ rx-jumbo N ]\n"
+	  "		[ tx N ]\n" },
+	{ "-k|--show-offload", 1, do_goffload,
+	  "Get protocol offload information" },
+	{ "-K|--offload", 1, do_soffload, "Set protocol offload",
+	  "		[ rx on|off ]\n"
+	  "		[ tx on|off ]\n"
+	  "		[ sg on|off ]\n"
+	  "		[ tso on|off ]\n"
+	  "		[ ufo on|off ]\n"
+	  "		[ gso on|off ]\n"
+	  "		[ gro on|off ]\n"
+	  "		[ lro on|off ]\n"
+	  "		[ rxvlan on|off ]\n"
+	  "		[ txvlan on|off ]\n"
+	  "		[ ntuple on|off ]\n"
+	  "		[ rxhash on|off ]\n"
+	},
+	{ "-i|--driver", 1, do_gdrv, "Show driver information" },
+	{ "-d|--register-dump", 1, do_gregs, "Do a register dump",
+	  "		[ raw on|off ]\n"
+	  "		[ file FILENAME ]\n" },
+	{ "-e|--eeprom-dump", 1, do_geeprom, "Do a EEPROM dump",
+	  "		[ raw on|off ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n" },
+	{ "-E|--change-eeprom", 1, do_seeprom,
+	  "Change bytes in device EEPROM",
+	  "		[ magic N ]\n"
+	  "		[ offset N ]\n"
+	  "		[ length N ]\n"
+	  "		[ value N ]\n" },
+	{ "-r|--negotiate", 1, do_nway_rst, "Restart N-WAY negotiation" },
+	{ "-p|--identify", 1, do_phys_id,
+	  "Show visible port identification (e.g. blinking)",
+	  "               [ TIME-IN-SECONDS ]\n" },
+	{ "-t|--test", 1, do_test, "Execute adapter self test",
+	  "               [ online | offline | external_lb ]\n" },
+	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
+	{ "-n|--show-nfc", 1, do_grxclass,
+	  "Show Rx network flow classification options",
+	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+	  "tcp6|udp6|ah6|esp6|sctp6 ]\n" },
+	{ "-f|--flash", 1, do_flash,
+	  "Flash firmware image from the specified file to a region on the device",
+	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
+	{ "-N|--config-nfc", 1, do_srxclass,
+	  "Configure Rx network flow classification options",
+	  "		[ rx-flow-hash tcp4|udp4|ah4|esp4|sctp4|"
+	  "tcp6|udp6|ah6|esp6|sctp6 m|v|t|s|d|f|n|r... ]\n" },
+	{ "-x|--show-rxfh-indir", 1, do_grxfhindir,
+	  "Show Rx flow hash indirection" },
+	{ "-X|--set-rxfh-indir", 1, do_srxfhindir,
+	  "Set Rx flow hash indirection",
+	  "		equal N | weight W0 W1 ...\n" },
+	{ "-U|--config-ntuple", 1, do_srxclsrule,
+	  "Configure Rx ntuple filters and actions",
+	  "		[ delete %d ] |\n"
+	  "		[ flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
+	  "			[ src %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+	  "			[ dst %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
+	  "			[ proto %d [m %x] ]\n"
+	  "			[ src-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+	  "			[ dst-ip %d.%d.%d.%d [m %d.%d.%d.%d] ]\n"
+	  "			[ tos %d [m %x] ]\n"
+	  "			[ l4proto %d [m %x] ]\n"
+	  "			[ src-port %d [m %x] ]\n"
+	  "			[ dst-port %d [m %x] ]\n"
+	  "			[ spi %d [m %x] ]\n"
+	  "			[ vlan-etype %x [m %x] ]\n"
+	  "			[ vlan %x [m %x] ]\n"
+	  "			[ user-def %x [m %x] ]\n"
+	  "			[ action %d ]\n"
+	  "			[ loc %d]]\n" },
+	{ "-u|--show-ntuple", 1, do_grxclsrule,
+	  "Get Rx ntuple filters and actions",
+	  "		[ rule %d ]\n"},
+	{ "-P|--show-permaddr", 1, do_permaddr,
+	  "Show permanent hardware address" },
+	{ "-w|--get-dump", 1, do_getfwdump,
+	  "Get dump flag, data",
+	  "		[ data FILENAME ]\n" },
+	{ "-W|--set-dump", 1, do_setfwdump,
+	  "Set dump flag of the device",
+	  "		N\n"},
+	{ "-l|--show-channels", 1, do_gchannels, "Query Channels" },
+	{ "-L|--set-channels", 1, do_schannels, "Set Channels",
+	  "               [ rx N ]\n"
+	  "               [ tx N ]\n"
+	  "               [ other N ]\n"
+	  "               [ combined N ]\n" },
+	{ "-h|--help", 0, show_usage, "Show this help" },
+	{ "--version", 0, do_version, "Show version number" },
+	{}
+};
+
+static int show_usage(struct cmd_context *ctx)
+{
+	int i;
+
+	/* ethtool -h */
+	fprintf(stdout, PACKAGE " version " VERSION "\n");
+	fprintf(stdout,
+		"Usage:\n"
+		"        ethtool DEVNAME\t"
+		"Display standard information about device\n");
+	for (i = 0; args[i].opts; i++) {
+		fputs("        ethtool ", stdout);
+		fprintf(stdout, "%s %s\t%s\n",
+			args[i].opts,
+			args[i].want_device ? "DEVNAME" : "\t",
+			args[i].help);
+		if (args[i].opthelp)
+			fputs(args[i].opthelp, stdout);
+	}
+
+	return 0;
+}
+
 int ethtool_main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
