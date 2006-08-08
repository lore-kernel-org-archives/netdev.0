From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [Fwd: Fwd: [PATCH] ethtool v4: add full autoneg specify feature]
Date: Tue, 08 Aug 2006 10:36:21 -0700
Message-ID: <44D8CB95.1060203@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, auke@foo-projects.org,
	tarbal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52303 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030200AbWHHRho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 13:37:44 -0400
To: NetDev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I figured that the word "ad" "ver" "tise" must throw off the spam filter,
so I hope this gets through now that I've removed it from the subject.

Note this is an ethtool patch, not a kernel one :)

Cheers,

Auke

---------- Forwarded message ----------
From: Jeff Kirsher <tarbal@gmail.com>
Date: Aug 7, 2006 9:53 PM
Subject: [PATCH] ethtool v4: add autoneg --------- feature
To: netdev@vger.kernel.org


adds the ability to change the advertised speed and duplex for a network
interfce.  Previously, a network interface was only able to advertise all
supported speed's and duplex's, or one individual speed and duplex.  This
feature allows the user to choose which supported speed's and duplex's to
advertise by using the hex value.
--
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

ethtool.c |   30 +++++++++++-------------------
1 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 7d408be..2ad2f99 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,7 @@ static struct option {
                "               [ duplex half|full ]\n"
                "               [ port tp|aui|bnc|mii|fibre ]\n"
                "               [ autoneg on|off ]\n"
+               "               [ advertise %%x ]\n"
                "               [ phyad %%d ]\n"
                "               [ xcvr internal|external ]\n"
                "               [ wol p|u|m|b|a|g|s|d... ]\n"
@@ -546,6 +547,15 @@ static void parse_cmdline(int argc, char
                                        show_usage(1);
                                }
                                break;
+                       } else if (!strcmp(argp[i], "advertise")) {
+                               gset_changed = 1;
+                               i += 1;
+                               if (i >= argc)
+                                       show_usage(1);
+                               advertising_wanted = strtol(argp[i], NULL, 6);
+                               if (advertising_wanted < 0)
+                                       show_usage(1);
+                               break;
                        } else if (!strcmp(argp[i], "phyad")) {
                                gset_changed = 1;
                                i += 1;
@@ -598,25 +608,7 @@ static void parse_cmdline(int argc, char
                }
        }

-       if (autoneg_wanted == AUTONEG_ENABLE){
-               if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
-                       advertising_wanted = ADVERTISED_10baseT_Half;
-               else if (speed_wanted == SPEED_10 &&
-                        duplex_wanted == DUPLEX_FULL)
-                       advertising_wanted = ADVERTISED_10baseT_Full;
-               else if (speed_wanted == SPEED_100 &&
-                        duplex_wanted == DUPLEX_HALF)
-                       advertising_wanted = ADVERTISED_100baseT_Half;
-               else if (speed_wanted == SPEED_100 &&
-                        duplex_wanted == DUPLEX_FULL)
-                       advertising_wanted = ADVERTISED_100baseT_Full;
-               else if (speed_wanted == SPEED_1000 &&
-                        duplex_wanted == DUPLEX_HALF)
-                       advertising_wanted = ADVERTISED_1000baseT_Half;
-               else if (speed_wanted == SPEED_1000 &&
-                        duplex_wanted == DUPLEX_FULL)
-                       advertising_wanted = ADVERTISED_1000baseT_Full;
-               else
+       if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {
                        /* auto negotiate without forcing,
                         * all supported speed will be assigned in do_sset()
                         */


-- 
Cheers,
Jeff
