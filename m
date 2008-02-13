From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] [IPROUTE2] Update various classifiers' help output for
	expected CLASSID syntax
Date: Wed, 13 Feb 2008 03:49:09 -0800
Message-ID: <20080213114909.13171.97451.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jarka02@gmail.com, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3410 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbYBMSog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 13:44:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update: Fix the spelling of "hexidecimal"

This updates the help output to specify that CLASSID should be hexidecimal.
This makes sure that a user entering "flowid 1:10" gets his flow put into
band 15 (0x10) and knows why.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 doc/actions/actions-general |    3 +++
 tc/f_basic.c                |    1 +
 tc/f_fw.c                   |    1 +
 tc/f_route.c                |    1 +
 tc/f_rsvp.c                 |    1 +
 tc/f_u32.c                  |    1 +
 6 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/doc/actions/actions-general b/doc/actions/actions-general
index 6561eda..70f7cd6 100644
--- a/doc/actions/actions-general
+++ b/doc/actions/actions-general
@@ -88,6 +88,9 @@ tc filter add dev lo parent ffff: protocol ip prio 8 u32 \
 match ip dst 127.0.0.8/32 flowid 1:12 \
 action ipt -j mark --set-mark 2
 
+NOTE: flowid 1:12 is parsed flowid 0x1:0x12.  Make sure if you want flowid
+decimal 12, then use flowid 1:c.
+
 3) A feature i call pipe
 The motivation is derived from Unix pipe mechanism but applied to packets.
 Essentially take a matching packet and pass it through 
diff --git a/tc/f_basic.c b/tc/f_basic.c
index 19a7edf..aab946b 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -32,6 +32,7 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
 	fprintf(stderr, "       FILTERID := X:Y:Z\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 static int basic_parse_opt(struct filter_util *qu, char *handle,
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 6d1490b..b511735 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -28,6 +28,7 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... fw [ classid CLASSID ] [ police POLICE_SPEC ]\n");
 	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
 	fprintf(stderr, "       CLASSID := X:Y\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 #define usage() return(-1)
diff --git a/tc/f_route.c b/tc/f_route.c
index a41b9d5..67dd49c 100644
--- a/tc/f_route.c
+++ b/tc/f_route.c
@@ -31,6 +31,7 @@ static void explain(void)
 	fprintf(stderr, "                [ flowid CLASSID ] [ police POLICE_SPEC ]\n");
 	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
 	fprintf(stderr, "       CLASSID := X:Y\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 #define usage() return(-1)
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 13fcf97..7e1e6d9 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -34,6 +34,7 @@ static void explain(void)
 	fprintf(stderr, "                u{8|16|32} NUMBER mask MASK at OFFSET}\n");
 	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
 	fprintf(stderr, "       FILTERID := X:Y\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 #define usage() return(-1)
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 91f2838..d75e76c 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -36,6 +36,7 @@ static void explain(void)
 	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
 	fprintf(stderr, "       SAMPLE := { ip | ip6 | udp | tcp | icmp | u{32|16|8} | mark } SAMPLE_ARGS [divisor DIVISOR]\n");
 	fprintf(stderr, "       FILTERID := X:Y:Z\n");
+	fprintf(stderr, "\nNOTE: CLASSID is parsed at hexadecimal input.\n");
 }
 
 #define usage() return(-1)

