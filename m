From: Thomas Graf <tgraf@suug.ch>
Subject: [RESEND 9/9] PKT_SCHED: Actions are now available for all classifiers & Fix police Kconfig dependencies
Date: Fri, 31 Dec 2004 15:17:21 +0100
Message-ID: <20041231141721.GL32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123617.GV32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041230123617.GV32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removes outdated comment and make action and old compat policer
mutually exclusive to reflect the code. Noted by Jamal Hadi Salim.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk2.orig/net/sched/Kconfig	2004-12-31 14:10:54.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/Kconfig	2004-12-31 15:04:01.000000000 +0100
@@ -381,7 +381,6 @@
 	---help---
 	This option requires you have a new iproute2. It enables
 	tc extensions which can be used with tc classifiers.
-	Only the u32 and fw classifiers are supported at the moment.
 	  You MUST NOT turn this on if you dont have an update iproute2.
 
 config NET_ACT_POLICE
@@ -392,13 +391,6 @@
 	below to select a policer.
 	  You MUST NOT turn this on if you dont have an update iproute2.
 
-config NET_CLS_POLICE
-	bool "Traffic policing (needed for in/egress)"
-	depends on NET_CLS && NET_QOS && NET_ACT_POLICE!=y && NET_ACT_POLICE!=m
-	help
-	  Say Y to support traffic policing (bandwidth limits).  Needed for
-	  ingress and egress rate limiting.
-
 config NET_ACT_GACT
         tristate "generic Actions"
         depends on NET_CLS_ACT
@@ -432,3 +424,11 @@
         ---help---
         requires new iproute2
         This allows for packets to be generically edited
+
+config NET_CLS_POLICE
+	bool "Traffic policing (needed for in/egress)"
+	depends on NET_CLS && NET_QOS && NET_CLS_ACT!=y
+	help
+	  Say Y to support traffic policing (bandwidth limits).  Needed for
+	  ingress and egress rate limiting.
+
