From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] ethtool: additional 10Gig niceness
Date: Wed, 04 Apr 2007 17:33:08 -0700
Message-ID: <461443C4.2090702@hp.com>
References: <460968FD.4020202@hp.com> <460973A0.8020803@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050503010908070409080909"
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:35342 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932398AbXDEAdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 20:33:10 -0400
In-Reply-To: <460973A0.8020803@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050503010908070409080909
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

teach ethtool to print "10000Mb/s" for a 10G NIC and prepare
for 10G NICs where it is possible to run something other than 10G
update the ethtool.8 manpage with info re same and some grammar fixes

Signed-off-by: Rick Jones <rick.jones2@hp.com>

the likely required asbestos at the ready :)

rick jones

--------------050503010908070409080909
Content-Type: text/plain;
 name="0001-ethtool-additional-10Gig-niceness.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="0001-ethtool-additional-10Gig-niceness.patch"

>From c58b73af0744a3d5dbc4fbf23c7b4d6f9092d21a Mon Sep 17 00:00:00 2001
From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 2 Apr 2007 13:45:53 -0700
Subject: [PATCH] ethtool: additional 10Gig niceness

teach ethtool to print "10000Mb/s" for a 10G NIC and prepare
for 10G NICs where it is possible to run something other than 10G
update the ethtool.8 manpage with info re same and some grammar fixes

Signed-off-by: Rick Jones <rick.jones2@hp.com>
---
 ethtool.8 |  107 +++++++++++++++++++++++++++++++-----------------------------
 ethtool.c |   20 ++++++++++-
 2 files changed, 73 insertions(+), 54 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index d247d51..d6561bf 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -175,7 +175,7 @@ ethtool \- Display or change ethernet card settings
 
 .B ethtool \-s
 .I ethX
-.B3 speed 10 100 1000
+.B4 speed 10 100 1000 10000
 .B2 duplex half full
 .B4 port tp aui bnc mii fibre
 .B2 autoneg on off
@@ -193,65 +193,65 @@ ethtool \- Display or change ethernet card settings
 is used for querying settings of an ethernet device and changing them.
 
 .I ethX
-is the name of the ethernet device to work on.
+is the name of the ethernet device on which ethtool should operate.
 
 .SH OPTIONS
 .B ethtool
 with a single argument specifying the device name prints current
-setting of the specified device.
+settings of the specified device.
 .TP
 .B \-h \-\-help
-shows a short help message.
+Shows a short help message.
 .TP
 .B \-a \-\-show\-pause
-queries the specified ethernet device for pause parameter information.
+Queries the specified ethernet device for pause parameter information.
 .TP
 .B \-A \-\-pause
-change the pause parameters of the specified ethernet device.
+Changes the pause parameters of the specified ethernet device.
 .TP
 .A2 autoneg on off
-Specify if pause autonegotiation is enabled.
+Specifies whether pause autonegotiation should be enabled.
 .TP
 .A2 rx on off
-Specify if RX pause is enabled.
+Specifies whether RX pause should be enabled.
 .TP
 .A2 tx on off
-Specify if TX pause is enabled.
+Specifies whether TX pause should be enabled.
 .TP
 .B \-c \-\-show\-coalesce
-queries the specified ethernet device for coalescing information.
+Queries the specified ethernet device for coalescing information.
 .TP
 .B \-C \-\-coalesce
-change the coalescing settings of the specified ethernet device.
+Changes the coalescing settings of the specified ethernet device.
 .TP
 .B \-g \-\-show\-ring
-queries the specified ethernet device for rx/tx ring parameter information.
+Queries the specified ethernet device for rx/tx ring parameter information.
 .TP
 .B \-G \-\-set\-ring
-change the rx/tx ring parameters of the specified ethernet device.
+Changes the rx/tx ring parameters of the specified ethernet device.
 .TP
 .BI rx \ N
-Change number of ring entries for the Rx ring.
+Changes the number of ring entries for the Rx ring.
 .TP
 .BI rx-mini \ N
-Change number of ring entries for the Rx Mini ring.
+Changes the number of ring entries for the Rx Mini ring.
 .TP
 .BI rx-jumbo \ N
-Change number of ring entries for the Rx Jumbo ring.
+Changes the number of ring entries for the Rx Jumbo ring.
 .TP
 .BI tx \ N
-Change number of ring entries for the Tx ring.
+Changes the number of ring entries for the Tx ring.
 .TP
 .B \-i \-\-driver
-queries the specified ethernet device for associated driver information.
+Queries the specified ethernet device for associated driver information.
 .TP
 .B \-d \-\-register\-dump
-retrieves and prints a register dump for the specified ethernet device.
+Retrieves and prints a register dump for the specified ethernet device.
 The register format for some devices is known and decoded others
 are printed in hex.
 When 
 .I raw 
-is enabled, then it dumps the raw register data to stdout.
+is enabled, then ethtool dumps the raw register data to stdout.
 If
 .I file
 is specified, then use contents of previous raw register dump, rather
@@ -259,7 +259,7 @@ than reading from the device.
 
 .TP
 .B \-e \-\-eeprom\-dump
-retrieves and prints an EEPROM dump for the specified ethernet device.
+Retrieves and prints an EEPROM dump for the specified ethernet device.
 When raw is enabled, then it dumps the raw EEPROM data to stdout. The
 length and offset parameters allow dumping certain portions of the EEPROM.
 Default is to dump the entire EEPROM.
@@ -271,31 +271,31 @@ of writing to the EEPROM, a device-specific magic key must be specified
 to prevent the accidental writing to the EEPROM.
 .TP
 .B \-k \-\-show\-offload
-queries the specified ethernet device for offload information.
+Queries the specified ethernet device for offload information.
 .TP
 .B \-K \-\-offload
-change the offload parameters of the specified ethernet device.
+Changes the offload parameters of the specified ethernet device.
 .TP
 .A2 rx on off
-Specify if RX checksumming is enabled.
+Specifies whether RX checksumming should be enabled.
 .TP
 .A2 tx on off
-Specify if TX checksumming is enabled.
+Specifies whether TX checksumming should be enabled.
 .TP
 .A2 sg on off
-Specify if scatter-gather is enabled.
+Specifies whether scatter-gather should be enabled.
 .TP
 .A2 tso on off
-Specify if tcp segmentation offload is enabled.
+Specifies whether TCP segmentation offload should be enabled.
 .TP
 .A2 ufo on off
-Specify if UDP fragmentation offload is enabled 
+Specifies whether UDP fragmentation offload should be enabled 
 .TP
 .A2 gso on off
-Specify if generic segmentation offload is enabled 
+Specifies whether generic segmentation offload should be enabled 
 .TP
 .B \-p \-\-identify
-initiates adapter-specific action intended to enable an operator to
+Initiates adapter-specific action intended to enable an operator to
 easily identify the adapter by sight.  Typically this involves
 blinking one or more LEDs on the specific ethernet port.
 .TP
@@ -303,15 +303,15 @@ blinking one or more LEDs on the specific ethernet port.
 Length of time to perform phys-id, in seconds.
 .TP
 .B \-r \-\-negotiate
-restarts auto-negotiation on the specified ethernet device, if
+Restarts auto-negotiation on the specified ethernet device, if
 auto-negotiation is enabled.
 .TP
 .B \-S \-\-statistics
-queries the specified ethernet device for NIC- and driver-specific
+Queries the specified ethernet device for NIC- and driver-specific
 statistics.
 .TP
 .B \-t \-\-test
-executes adapter selftest on the specified ethernet device. Possible test modes are:
+Executes adapter selftest on the specified ethernet device. Possible test modes are:
 .TP
 .A1 offline online
 defines test type: 
@@ -321,45 +321,48 @@ defines test type:
 means to perform limited set of tests do not interrupting normal adapter operation.
 .TP
 .B \-s \-\-change
-option allows changing some or all settings of the specified ethernet device.
+Allows changing some or all settings of the specified ethernet device.
 All following options only apply if
 .B \-s
 was specified.
 .TP
-.A3 speed 10 100 1000
+.A4 speed 10 100 1000 10000
 Set speed in Mb/s.
 .B ethtool
-with single argument will show you the supported device speeds.
+with just the device name as an argument will show you the supported device speeds.
 .TP
 .A2 duplex half full
-Set full or half duplex mode.
+Sets full or half duplex mode.
 .TP
 .A4 port tp aui bnc mii fibre
-Select device port.
+Selects device port.
 .TP
 .A2 autoneg on off
-Specify if autonegotiation is enabled. In the usual case it is, but might
-cause some problems with some network devices, so you can turn it off.
+Specifies whether autonegotiation should be enabled. Autonegotiation 
+is enabled by deafult, but in some network devices may have trouble
+with it, so you can disable it if really necessary. 
 .TP
 .BI advertise \ N
-Set the speed and duplex advertised by autonegotiation.  The argument is
+Sets the speed and duplex advertised by autonegotiation.  The argument is
 a hexidecimal value using one or a combination of the following values:
 .RS
 .PD 0
 .TP 3
-.BR "0x01" "    10 Half"
+.BR "0x001" "    10 Half"
 .TP 3
-.BR "0x02" "    10 Full"
+.BR "0x002" "    10 Full"
 .TP 3
-.BR "0x04" "    100 Half"
+.BR "0x004" "    100 Half"
 .TP 3
-.BR "0x08" "    100 Full"
+.BR "0x008" "    100 Full"
 .TP 3
-.BR "0x10" "    1000 Half" "(not supported by IEEE standards)"
+.BR "0x010" "    1000 Half" "(not supported by IEEE standards)"
 .TP 3
-.BR "0x20" "    1000 Full"
+.BR "0x020" "    1000 Full"
 .TP 3
-.BR "0x3F" "    Auto"
+.BR "0x800" "    10000 Full"
+.TP 3
+.BR "0x03F" "    Auto"
 .PD
 .RE
 .TP
@@ -367,11 +370,11 @@ a hexidecimal value using one or a combination of the following values:
 PHY address.
 .TP
 .A2 xcvr internal external
-Select transceiver type. Currently only internal and external can be
+Selects transceiver type. Currently only internal and external can be
 specified, in the future further types might be added.
 .TP
 .BR wol \ \*(WO
-Set Wake-on-LAN options.  Not all devices support this.  The argument to 
+Sets Wake-on-LAN options.  Not all devices support this.  The argument to 
 this option is a string of characters specifying which options to enable.
 .RS
 .PD 0
@@ -403,11 +406,11 @@ Disable (wake on nothing).  This option clears all previous options.
 .RE
 .TP
 .B sopass \*(MA\c
-Set the SecureOn(tm) password.  The argument to this option must be 6
+Sets the SecureOn(tm) password.  The argument to this option must be 6
 bytes in ethernet MAC hex format (\*(MA).
 .TP
 .BI msglvl \ N
-Set the driver message level. Meanings differ per driver.
+Sets the driver message level. Meanings differ per driver.
 .SH BUGS
 Not supported (in part or whole) on all ethernet drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index 0fc8d6b..1fbad09 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -98,7 +98,7 @@ static struct option {
     char *opthelp;
 } args[] = {
     { "-s", "--change", MODE_SSET, "Change generic options",
-		"		[ speed 10|100|1000 ]\n"
+		"		[ speed 10|100|1000|10000 ]\n"
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
 		"		[ autoneg on|off ]\n"
@@ -521,6 +521,8 @@ static void parse_cmdline(int argc, char **argp)
 					speed_wanted = SPEED_100;
 				else if (!strcmp(argp[i], "1000"))
 					speed_wanted = SPEED_1000;
+				else if (!strcmp(argp[1], "10000"))
+					speed_wanted = SPEED_10000;
 				else
 					show_usage(1);
 				break;
@@ -647,6 +649,9 @@ static void parse_cmdline(int argc, char **argp)
 		else if (speed_wanted == SPEED_1000 &&
 			 duplex_wanted == DUPLEX_FULL)
 			advertising_wanted = ADVERTISED_1000baseT_Full;
+		else if (speed_wanted == SPEED_10000 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_10000baseT_Full;
 		else
 			/* auto negotiate without forcing,
 			 * all supported speed will be assigned in do_sset()
@@ -749,6 +754,13 @@ static void dump_advertised(struct ethtool_cmd *ep)
 	if (mask & ADVERTISED_1000baseT_Full) {
 		did1++; fprintf(stdout, "1000baseT/Full ");
 	}
+	if (did1 && (mask & ADVERTISED_10000baseT_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	                        ");
+	}
+	if (mask & ADVERTISED_10000baseT_Full) {
+		did1++; fprintf(stdout, "10000baseT/Full ");
+	}
 	if (did1 == 0)
 		 fprintf(stdout, "Not reported");
 	fprintf(stdout, "\n");
@@ -776,6 +788,9 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case SPEED_1000:
 		fprintf(stdout, "1000Mb/s\n");
 		break;
+	case SPEED_10000:
+		fprintf(stdout, "10000Mb/s\n");
+		break;
 	default:
 		fprintf(stdout, "Unknown! (%i)\n", ep->speed);
 		break;
@@ -1696,7 +1711,8 @@ static int do_sset(int fd, struct ifreq *ifr)
 						 ADVERTISED_100baseT_Half |
 						 ADVERTISED_100baseT_Full |
 						 ADVERTISED_1000baseT_Half |
-						 ADVERTISED_1000baseT_Full);
+						 ADVERTISED_1000baseT_Full |
+						 ADVERTISED_10000baseT_Full);
 				else
 					ecmd.advertising = advertising_wanted;
 			}
-- 
1.5.0


--------------050503010908070409080909--
