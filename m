From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 1/7] nstat: Avoid passing negative fd to fdopen()
Date: Mon, 21 Aug 2017 19:08:07 +0200
Message-ID: <20170821170813.29697-2-phil@nwl.cc>
References: <20170821170813.29697-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56515 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753407AbdHURIi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 13:08:38 -0400
In-Reply-To: <20170821170813.29697-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a wrapper which does the sanity checking and returns NULL
in case fd is invalid.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/nstat.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/misc/nstat.c b/misc/nstat.c
index 1212b1f2c8128..7cdde75a56e4e 100644
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
