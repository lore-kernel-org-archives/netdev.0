From: Joe Perches <joe@perches.com>
Subject: [PATCH] - trivial - Improve appletalk checksum calculation
Date: Mon, 22 Oct 2007 12:36:19 -0700
Message-ID: <1193081779.5132.24.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2022 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbXJVTgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 15:36:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It's a bit after 2.6.1 now...

Removes unnecessary if, uses 16 bit rotate left.
Performance improves ~30%

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 7c0b515..1c50f4c 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -925,15 +925,9 @@ static int atrtr_ioctl(unsigned int cmd, void __user *arg)
 static unsigned long atalk_sum_partial(const unsigned char *data,
 				       int len, unsigned long sum)
 {
-	/* This ought to be unwrapped neatly. I'll trust gcc for now */
 	while (len--) {
-		sum += *data;
-		sum <<= 1;
-		if (sum & 0x10000) {
-			sum++;
-			sum &= 0xffff;
-		}
-		data++;
+		sum += *data++;
+		sum = ((sum & 0x8000)>>15) | ((sum & 0x7fff)<<1);
 	}
 	return sum;
 }


