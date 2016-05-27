From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] atm: firestream: add more reserved strings
Date: Fri, 27 May 2016 13:33:50 +0300
Message-ID: <20160527103350.GA3255@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Chas Williams <3chas3@gmail.com>,
	Patrick van de Lageweg <patrick@bitwizard.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34179 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbcE0KeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 06:34:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This bug was there when the driver was first added in back in year 2000.
It causes a Smatch warning:

    drivers/atm/firestream.c:849 process_incoming()
    error: buffer overflow 'res_strings' 60 <= 63

There are supposed to be 64 entries in this array and the missing
strings are clearly in the 30 40 range.  I added them as reserved 37 to
reserved 40.  It's possible that strings are really supposed to be added
in the middle instead of at the end, but this approach is safe, in that
it fixes the bug and doesn't break anything that wasn't already broken.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index a969a7e..4777064 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -181,13 +181,17 @@ static char *res_strings[] = {
 	"reserved 27", 
 	"reserved 28", 
 	"reserved 29", 
-	"reserved 30", 
+	"reserved 30", /* FIXME: The strings between 30-40 might be wrong. */
 	"reassembly abort: no buffers", 
 	"receive buffer overflow", 
 	"change in GFC", 
 	"receive buffer full", 
 	"low priority discard - no receive descriptor", 
 	"low priority discard - missing end of packet", 
+	"reserved 37",
+	"reserved 38",
+	"reserved 39",
+	"reseverd 40",
 	"reserved 41", 
 	"reserved 42", 
 	"reserved 43", 
