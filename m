From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2 net-next] nstat: add sctp snmp support
Date: Fri,  2 Sep 2016 15:12:38 +0800
Message-ID: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35603 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbcIBHMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 03:12:52 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so5427596pfg.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 00:12:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP module was not load by default. But this should be OK since we will not
load table if fdopen() failed.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 misc/nstat.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/misc/nstat.c b/misc/nstat.c
index 6143719..8035be4 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -76,6 +76,11 @@ static int net_snmp6_open(void)
 	return generic_proc_open("PROC_NET_SNMP6", "net/snmp6");
 }
 
+static int net_sctp_snmp_open(void)
+{
+	return generic_proc_open("PROC_NET_SCTP_SNMP", "net/sctp/snmp");
+}
+
 struct nstat_ent {
 	struct nstat_ent *next;
 	char		 *id;
@@ -247,6 +252,16 @@ static void load_ugly_table(FILE *fp)
 	}
 }
 
+static void load_sctp_snmp(void)
+{
+	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
+
+	if (fp) {
+		load_good_table(fp);
+		fclose(fp);
+	}
+}
+
 static void load_snmp(void)
 {
 	FILE *fp = fdopen(net_snmp_open(), "r");
@@ -450,6 +465,7 @@ static void server_loop(int fd)
 	load_netstat();
 	load_snmp6();
 	load_snmp();
+	load_sctp_snmp();
 
 	for (;;) {
 		int status;
@@ -706,6 +722,7 @@ int main(int argc, char *argv[])
 		load_netstat();
 		load_snmp6();
 		load_snmp();
+		load_sctp_snmp();
 		if (info_source[0] == 0)
 			strcpy(info_source, "kernel");
 	}
-- 
2.5.5
