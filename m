From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: validate policer configuration TLVs
Date: Tue, 7 Dec 2004 18:23:49 +0100
Message-ID: <20041207172349.GG1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adds TLV size sanity checks for policer configuration. 

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc2-bk13.orig/net/sched/police.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/sched/police.c	2004-12-07 17:24:01.000000000 +0100
@@ -180,7 +180,8 @@
 	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return -1;
 
-	if (tb[TCA_POLICE_TBF-1] == NULL)
+	if (tb[TCA_POLICE_TBF-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]) != sizeof(*parm))
 		return -1;
 
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
@@ -220,11 +221,17 @@
 			goto failure;
 		}
 	}
-	if (tb[TCA_POLICE_RESULT-1])
+	if (tb[TCA_POLICE_RESULT-1]) {
+		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+			goto failure;
 		p->result = *(int*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+	}
 #ifdef CONFIG_NET_ESTIMATOR
-	if (tb[TCA_POLICE_AVRATE-1])
+	if (tb[TCA_POLICE_AVRATE-1]) {
+		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
+			goto failure;
 		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+	}
 #endif
 	p->toks = p->burst = parm->burst;
 	p->mtu = parm->mtu;
@@ -424,7 +431,8 @@
 	if (rtattr_parse(tb, TCA_POLICE_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
 		return NULL;
 
-	if (tb[TCA_POLICE_TBF-1] == NULL)
+	if (tb[TCA_POLICE_TBF-1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_POLICE_TBF-1]) != sizeof(*parm))
 		return NULL;
 
 	parm = RTA_DATA(tb[TCA_POLICE_TBF-1]);
@@ -449,11 +457,17 @@
 		    (p->P_tab = qdisc_get_rtab(&parm->peakrate, tb[TCA_POLICE_PEAKRATE-1])) == NULL)
 			goto failure;
 	}
-	if (tb[TCA_POLICE_RESULT-1])
+	if (tb[TCA_POLICE_RESULT-1]) {
+		if (RTA_PAYLOAD(tb[TCA_POLICE_RESULT-1]) != sizeof(u32))
+			goto failure;
 		p->result = *(int*)RTA_DATA(tb[TCA_POLICE_RESULT-1]);
+	}
 #ifdef CONFIG_NET_ESTIMATOR
-	if (tb[TCA_POLICE_AVRATE-1])
+	if (tb[TCA_POLICE_AVRATE-1]) {
+		if (RTA_PAYLOAD(tb[TCA_POLICE_AVRATE-1]) != sizeof(u32))
+			goto failure;
 		p->ewma_rate = *(u32*)RTA_DATA(tb[TCA_POLICE_AVRATE-1]);
+	}
 #endif
 	p->toks = p->burst = parm->burst;
 	p->mtu = parm->mtu;
