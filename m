From: Joe Perches <joe@perches.com>
Subject: [PATCH] appletalk/ddp.c: Neaten checksum function
Date: Wed, 04 Nov 2009 12:26:13 -0800
Message-ID: <1257366373.18982.25.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1233 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932297AbZKDU0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 15:26:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atalk_sum_partial can now use the rol16 function in bitops.h

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index abe3801..e6903db 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -922,13 +922,8 @@ static unsigned long atalk_sum_partial(const unsigned char *data,
 {
 	/* This ought to be unwrapped neatly. I'll trust gcc for now */
 	while (len--) {
-		sum += *data;
-		sum <<= 1;
-		if (sum & 0x10000) {
-			sum++;
-			sum &= 0xffff;
-		}
-		data++;
+		sum += *data++;
+		sum = rol16(sum, 1);
 	}
 	return sum;
 }


