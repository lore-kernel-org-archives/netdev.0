From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: remove duplicate NULL check
Date: Thu, 17 May 2012 09:51:02 +0300
Message-ID: <20120517065102.GC14660@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>,
	Phil Carmody <ext-phil.2.carmody@nokia.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31772 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759674Ab2EQGvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 02:51:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We test both "!skb_out" and "skb_out" here which is duplicative and
causes a static checker warning.  I considered that the intent might
have been to test "skb_in" but that's a valid pointer here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index c59e8d2..8837ac5 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -612,7 +612,7 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 		db->n_bits++;
 
 	/* If output length is too large then this is an incompressible frame. */
-	if (!skb_out || (skb_out && skb_out->len >= skb_in->len)) {
+	if (!skb_out || skb_out->len >= skb_in->len) {
 		++db->incomp_count;
 		db->incomp_bytes += isize;
 		return 0;
