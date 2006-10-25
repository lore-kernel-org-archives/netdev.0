From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH FIXED] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 22:41:27 -0400
Message-ID: <1161744087.29939.11.camel@dv>
References: <1161382815.5803.2.camel@dv> <20061021011943.GC6140@jm.kir.nu>
	 <1161742344.29939.6.camel@dv>  <20061025023119.GB6121@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:45928 "EHLO c60.cesmail.net")
	by vger.kernel.org with ESMTP id S1422898AbWJYCl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 22:41:29 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20061025023119.GB6121@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hostap_plx: fix two related off-by-one errors in CIS parser

From: Pavel Roskin <proski@gnu.org>

The length of the manfid CIS should be at least 4, and it's normally 4.
It's incorrect to require it to be at least 5.  This breaks support for
most (if not all) cards.

The right place to ensure that we don't access beyond the CIS buffer is
to strengthen another check.  Make sure that the next tuple begins at
least at the CIS buffer end (in which case we stop processing) or
before that.

Reported by ph35sm@free.fr

Signed-off-by: Pavel Roskin <proski@gnu.org>
---
I'd like to remind that it's 2.6.x.y material.

 drivers/net/wireless/hostap/hostap_plx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 6dfa041..bc81b13 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -364,7 +364,7 @@ #define CIS_MAX_LEN 256
 
 	pos = 0;
 	while (pos < CIS_MAX_LEN - 1 && cis[pos] != CISTPL_END) {
-		if (pos + cis[pos + 1] >= CIS_MAX_LEN)
+		if (pos + 2 + cis[pos + 1] > CIS_MAX_LEN)
 			goto cis_error;
 
 		switch (cis[pos]) {
@@ -391,7 +391,7 @@ #define CIS_MAX_LEN 256
 			break;
 
 		case CISTPL_MANFID:
-			if (cis[pos + 1] < 5)
+			if (cis[pos + 1] < 4)
 				goto cis_error;
 			manfid1 = cis[pos + 2] + (cis[pos + 3] << 8);
 			manfid2 = cis[pos + 4] + (cis[pos + 5] << 8);

-- 
Regards,
Pavel Roskin

