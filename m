From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] lnstat: fix header displaying mechanism
Date: Wed, 18 Nov 2015 16:57:47 +0100
Message-ID: <1447862267-13603-3-git-send-email-phil@nwl.cc>
References: <1447862267-13603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60666 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755854AbbKRP6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 10:58:12 -0500
In-Reply-To: <1447862267-13603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The algorithm depends on the loop counter ('i') to increment by one in
each iteration. Though if running endlessly (count==0), the counter was
not incremented at all.

Also change formatting of the header printing conditional a bit so it's
hopefully easier to read.

Fixes: e7e2913 ("lnstat: run indefinitely by default")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/lnstat.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/misc/lnstat.c b/misc/lnstat.c
index 529bc33..264c953 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -359,21 +359,19 @@ int main(int argc, char **argv)
 		if (interval < 1 )
 			interval = 1;
 
-		for (i = 0; i < count || !count; ) {
+		for (i = 0; i < count || !count; i++) {
 			lnstat_update(lnstat_files);
 			if (mode == MODE_JSON)
 				print_json(stdout, lnstat_files, &fp);
 			else {
-				if  ((hdr > 1 &&
-				      (! (i % 20))) || (hdr == 1 && i == 0))
+				if  ((hdr > 1 && !(i % 20)) ||
+				     (hdr == 1 && i == 0))
 					print_hdr(stdout, header);
 				print_line(stdout, lnstat_files, &fp);
 			}
 			fflush(stdout);
 			if (i < count - 1 || !count)
 				sleep(interval);
-			if (count)
-				++i;
 		}
 		break;
 	}
-- 
2.5.0
