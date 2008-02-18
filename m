From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH v2][IPROUTE] tc filters usage fixes
Date: Tue, 19 Feb 2008 00:26:12 +0100
Message-ID: <20080218232612.GC6373@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:30100 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbYBRXUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 18:20:42 -0500
Received: by ug-out-1314.google.com with SMTP id z38so439381ugc.16
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 15:20:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


CLASSID := X:Y:Z ==> X:Y in f_basic is changed here and no change for
f_u32 (it has both CLASSID and FILTERID mentioned).

-----------------> (take 2)

A few usage description fixes of tc filters for some minimal
consistency (FILTER_KIND because of QDISC_KIND).


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 tc/f_basic.c   |    4 ++--
 tc/f_rsvp.c    |    2 +-
 tc/tc_filter.c |    6 +++---
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tc/f_basic.c b/tc/f_basic.c
index ad41633..d8a42d9 100644
--- a/tc/f_basic.c
+++ b/tc/f_basic.c
@@ -30,8 +30,8 @@ static void explain(void)
 	fprintf(stderr, "Usage: ... basic [ match EMATCH_TREE ] [ police POLICE_SPEC ]\n");
 	fprintf(stderr, "                 [ action ACTION_SPEC ] [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: SELECTOR := SAMPLE SAMPLE ...\n");
-	fprintf(stderr, "       FILTERID := X:Y:Z\n");
+	fprintf(stderr, "Where:\n");
+	fprintf(stderr, "       CLASSID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
diff --git a/tc/f_rsvp.c b/tc/f_rsvp.c
index 7e1e6d9..8f92e8f 100644
--- a/tc/f_rsvp.c
+++ b/tc/f_rsvp.c
@@ -33,7 +33,7 @@ static void explain(void)
 	fprintf(stderr, "Where: GPI := { flowlabel NUMBER | spi/ah SPI | spi/esp SPI |\n");
 	fprintf(stderr, "                u{8|16|32} NUMBER mask MASK at OFFSET}\n");
 	fprintf(stderr, "       POLICE_SPEC := ... look at TBF\n");
-	fprintf(stderr, "       FILTERID := X:Y\n");
+	fprintf(stderr, "       CLASSID := X:Y\n");
 	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index d70c656..eb74f89 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -33,12 +33,12 @@ static void usage(void)
 	fprintf(stderr, "Usage: tc filter [ add | del | change | replace | show ] dev STRING\n");
 	fprintf(stderr, "       [ pref PRIO ] protocol PROTO\n");
 	fprintf(stderr, "       [ estimator INTERVAL TIME_CONSTANT ]\n");
-	fprintf(stderr, "       [ root | classid CLASSID ] [ handle FILTERID ]\n");
-	fprintf(stderr, "       [ [ FILTER_TYPE ] [ help | OPTIONS ] ]\n");
+	fprintf(stderr, "       [ root | parent CLASSID ] [ handle FILTERID ]\n");
+	fprintf(stderr, "       [ [ FILTER_KIND ] [ help | OPTIONS ] ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "       tc filter show [ dev STRING ] [ root | parent CLASSID ]\n");
 	fprintf(stderr, "Where:\n");
-	fprintf(stderr, "FILTER_TYPE := { rsvp | u32 | fw | route | etc. }\n");
+	fprintf(stderr, "FILTER_KIND := { rsvp | u32 | fw | route | etc. }\n");
 	fprintf(stderr, "FILTERID := ... format depends on classifier, see there\n");
 	fprintf(stderr, "OPTIONS := ... try tc filter add <desired FILTER_KIND> help\n");
 	return;
