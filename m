From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 4/6] bridge/link: add new offload hwmode swdev
Date: Thu,  4 Dec 2014 09:57:16 +0100
Message-ID: <1417683438-10935-5-git-send-email-jiri@resnulli.us>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:61040 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302AbaLDI51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 03:57:27 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so22085166wgg.0
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 00:57:25 -0800 (PST)
In-Reply-To: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To support full-featured switch devices offloading bridge funtionality,
add new hwmode 'swdev'.  Like 'vepa' and 'veb', 'swdev' indicated bridge
port functionality is being offloaded to hardware.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 bridge/link.c             |  6 ++++--
 include/linux/if_bridge.h |  1 +
 man/man8/bridge.8         | 13 ++++++++-----
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 90d9e7f..efe0b8c 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -65,7 +65,7 @@ static const char *oper_states[] = {
 	"TESTING", "DORMANT",	 "UP"
 };
 
-static const char *hw_mode[] = {"VEB", "VEPA"};
+static const char *hw_mode[] = {"VEB", "VEPA", "swdev"};
 
 static void print_operstate(FILE *f, __u8 state)
 {
@@ -315,10 +315,12 @@ static int brlink_modify(int argc, char **argv)
 				mode = BRIDGE_MODE_VEPA;
 			else if (strcmp(*argv, "veb") == 0)
 				mode = BRIDGE_MODE_VEB;
+			else if (strcmp(*argv, "swdev") == 0)
+				mode = BRIDGE_MODE_SWDEV;
 			else {
 				fprintf(stderr,
 					"Mode argument must be \"vepa\" or "
-					"\"veb\".\n");
+					"\"veb\" or \"swdev\".\n");
 				exit(-1);
 			}
 		} else {
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index ed6868e..6b4eb66 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -105,6 +105,7 @@ struct __fdb_entry {
 
 #define BRIDGE_MODE_VEB		0	/* Default loopback mode */
 #define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
+#define BRIDGE_MODE_SWDEV	2	/* Full switch device offload */
 
 /* Bridge management nested attributes
  * [IFLA_AF_SPEC] = {
diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
index af31d41..d3d64d1 100644
--- a/man/man8/bridge.8
+++ b/man/man8/bridge.8
@@ -38,7 +38,7 @@ bridge \- show / manipulate bridge addresses and devices
 .BR root_block " { " on " | " off " } ] [ "
 .BR learning " { " on " | " off " } ] [ "
 .BR flood " { " on " | " off " } ] [ "
-.BR hwmode " { " vepa " | " veb " } ] "
+.BR hwmode " { " vepa " | " veb " | " swdev " } ] "
 
 .ti -8
 .BR "bridge link" " [ " show " ] [ "
@@ -247,15 +247,18 @@ Controls whether a given port will flood unicast traffic for which there is no F
 
 .TP
 .BI hwmode
-Some network interface cards support HW bridge functionality and they may be
+Some port devices support HW bridge functionality and they may be
 configured in different modes.  Currently support modes are:
 
 .B vepa
-- Data sent between HW ports is sent on the wire to the external
-switch.
+- NIC interface supports VEPA: data sent between HW ports is sent on
+the wire to the external switch.
 
 .B veb
-- bridging happens in hardware.
+- NIC interface supports VEB: bridging happens in hardware.
+
+.B swdev
+- Full Ethernet switch offload device: bridging happens in hardware.
 
 .SS bridge link show - list bridge port configuration.
 
-- 
1.9.3
