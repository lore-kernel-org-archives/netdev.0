From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [REVISED] [PATCH] ethtool v4: add autoneg advertise feature
Date: Thu, 24 Aug 2006 09:17:21 -0700
Message-ID: <20060824161721.16920.90640.stgit@jtkirshe-sled.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60238 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030344AbWHXQQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 12:16:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


adds the ability to change the advertised speed and duplex for a network interface.  Previously, a network interface was only able to advertise all supported speed's and duplex's, or one individual speed and duplex.  The feature allows the user to choose which supported speed's and duplex's to advertise by using the hex value.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

---

 ethtool.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 87e22ab..b7f189a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,7 @@ static struct option {
 		"		[ duplex half|full ]\n"
 		"		[ port tp|aui|bnc|mii|fibre ]\n"
 		"		[ autoneg on|off ]\n"
+		"		[ advertise %%x ]\n"
 		"		[ phyad %%d ]\n"
 		"		[ xcvr internal|external ]\n"
 		"		[ wol p|u|m|b|a|g|s|d... ]\n"
@@ -549,6 +550,15 @@ static void parse_cmdline(int argc, char
 					show_usage(1);
 				}
 				break;
+			} else if (!strcmp(argp[i], "advertise")) {
+				gset_changed = 1;
+				i += 1;
+				if (i >= argc)
+					show_usage(1);
+				advertising_wanted = strtol(argp[i], NULL, 16);
+				if (advertising_wanted < 0)
+					show_usage(1);
+				break;
 			} else if (!strcmp(argp[i], "phyad")) {
 				gset_changed = 1;
 				i += 1;
@@ -601,7 +611,7 @@ static void parse_cmdline(int argc, char
 		}
 	}
 
-	if (autoneg_wanted == AUTONEG_ENABLE){
+	if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {
 		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
 			advertising_wanted = ADVERTISED_10baseT_Half;
 		else if (speed_wanted == SPEED_10 &&
