From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ambassador,firestream: "-1 >>" is implementation defined
Date: Mon, 13 Nov 2006 23:22:00 +0300
Message-ID: <20061113202200.GA4971@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:40478 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1755259AbWKMUWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 15:22:09 -0500
Received: by ug-out-1314.google.com with SMTP id m3so1197266ugc
        for <netdev@vger.kernel.org>; Mon, 13 Nov 2006 12:22:07 -0800 (PST)
To: Chas Williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

6.5.7(5): The result of E1 >> E2 is E1 right-shifted E2 bit positions.
		...
	If E1 has a signed type and a negative value, the resulting value
	is implementation defined.

So, cast -1 to unsigned type to make result well-defined.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/atm/ambassador.c |    2 +-
 drivers/atm/firestream.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -972,7 +972,7 @@ static int make_rate (unsigned int rate,
       }
       case round_up: {
 	// check all bits that we are discarding
-	if (man & (-1>>9)) {
+	if (man & ((unsigned int)-1>>9)) {
 	  man = (man>>(32-9)) + 1;
 	  if (man == (1<<9)) {
 	    // no need to check for round up outside of range
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -512,7 +512,7 @@ static unsigned int make_rate (unsigned 
 		}
 		case ROUND_UP: {
 			/* check all bits that we are discarding */
-			if (man & (-1>>9)) {
+			if (man & ((unsigned int)-1>>9)) {
 				man = (man>>(32-9)) + 1;
 				if (man == (1<<9)) {
 					/* no need to check for round up outside of range */

