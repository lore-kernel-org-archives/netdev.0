From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 28/51] nstat: Avoid passing negative fd to fdopen()
Date: Sat, 12 Aug 2017 14:04:47 +0200
Message-ID: <20170812120510.28750-29-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:42763 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752225AbdHLMIG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:08:06 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a wrapper which does the sanity checking and returns NULL
in case fd is invalid.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/nstat.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/misc/nstat.c b/misc/nstat.c
index 23e1569d7872b..c1e7ddec271e2 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -252,9 +252,16 @@ static void load_ugly_table(FILE *fp)
 	}
 }
 
+static FILE *fdopen_null(int fd, const char *mode)
+{
+	if (fd < 0)
+		return NULL;
+	return fdopen(fd, mode);
+}
+
 static void load_sctp_snmp(void)
 {
-	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
+	FILE *fp = fdopen_null(net_sctp_snmp_open(), "r");
 
 	if (fp) {
 		load_good_table(fp);
@@ -264,7 +271,7 @@ static void load_sctp_snmp(void)
 
 static void load_snmp(void)
 {
-	FILE *fp = fdopen(net_snmp_open(), "r");
+	FILE *fp = fdopen_null(net_snmp_open(), "r");
 
 	if (fp) {
 		load_ugly_table(fp);
@@ -274,7 +281,7 @@ static void load_snmp(void)
 
 static void load_snmp6(void)
 {
-	FILE *fp = fdopen(net_snmp6_open(), "r");
+	FILE *fp = fdopen_null(net_snmp6_open(), "r");
 
 	if (fp) {
 		load_good_table(fp);
@@ -284,7 +291,7 @@ static void load_snmp6(void)
 
 static void load_netstat(void)
 {
-	FILE *fp = fdopen(net_netstat_open(), "r");
+	FILE *fp = fdopen_null(net_netstat_open(), "r");
 
 	if (fp) {
 		load_ugly_table(fp);
-- 
2.13.1
