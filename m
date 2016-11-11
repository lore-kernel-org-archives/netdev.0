From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 14/18] ss: Get rid of single-fielded struct snmpstat
Date: Fri, 11 Nov 2016 14:10:10 +0100
Message-ID: <20161111131014.21865-15-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53996 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756412AbcKKNL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:29 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A struct with only a single field does not make much sense. Besides
that, it was used by print_summary() only.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index b06b9e6fa9884..85fc6096a986f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3472,10 +3472,6 @@ static int handle_follow_request(struct filter *f)
 	return ret;
 }
 
-struct snmpstat {
-	int tcp_estab;
-};
-
 static int get_snmp_int(char *proto, char *key, int *result)
 {
 	char buf[1024];
@@ -3596,11 +3592,11 @@ static int get_sockstat(struct ssummary *s)
 static int print_summary(void)
 {
 	struct ssummary s;
-	struct snmpstat sn;
+	int tcp_estab;
 
 	if (get_sockstat(&s) < 0)
 		perror("ss: get_sockstat");
-	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
+	if (get_snmp_int("Tcp:", "CurrEstab", &tcp_estab) < 0)
 		perror("ss: get_snmpstat");
 
 	get_slabstat(&slabstat);
@@ -3609,7 +3605,7 @@ static int print_summary(void)
 
 	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, timewait %d/%d), ports %d\n",
 	       s.tcp_total + slabstat.tcp_syns + s.tcp_tws,
-	       sn.tcp_estab,
+	       tcp_estab,
 	       s.tcp_total - (s.tcp4_hashed+s.tcp6_hashed-s.tcp_tws),
 	       s.tcp_orphans,
 	       slabstat.tcp_syns,
-- 
2.10.0
