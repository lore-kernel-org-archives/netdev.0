From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] eexpress: Read buffer overflow
Date: Wed, 29 Jul 2009 14:15:33 +0200
Message-ID: <4A703D65.7010805@gmail.com>
References: <4A6B61FB.4050304@gmail.com> <20090726.184555.56450167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:63083 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384AbZG2MMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 08:12:41 -0400
Received: by ewy26 with SMTP id 26so768241ewy.37
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 05:12:40 -0700 (PDT)
In-Reply-To: <20090726.184555.56450167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

start_code is 69 words, but the code always writes a multiple of 16 words,
so the last 11 words written are outside the array.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Found with Parfait, http://research.sun.com/projects/parfait/

> You've murdered this code, it's even more obfuscated now than it was
> previously. 

Was it really that much worse? I though it was more clean. I did test
it to make sure that the semantics were the same.

> Just add the necessary limit tests, and nothing more, so it's
> possible to actually understand your patch.  If it's more than
> a 3 line patch, I'm not even going to review it.

3 lines it is, although scripts/checkpatch.pl doesn't like it.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Found with Parfait, http://research.sun.com/projects/parfait/

3 lines it is, but scripts/checkpatch.pl doesn't like it.

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 1686dca..7b40014 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1474,13 +1474,13 @@ static void eexp_hw_init586(struct net_device *dev)
 	outw(0x0000, ioaddr + 0x800c);
 	outw(0x0000, ioaddr + 0x800e);
 
-	for (i = 0; i < (sizeof(start_code)); i+=32) {
+	for (i = 0; i < ARRAY_SIZE(start_code); i+=32) {
 		int j;
 		outw(i, ioaddr + SM_PTR);
-		for (j = 0; j < 16; j+=2)
+		for (j = 0; j < 16 && (i+j)/2 < ARRAY_SIZE(start_code); j+=2)
 			outw(start_code[(i+j)/2],
 			     ioaddr+0x4000+j);
-		for (j = 0; j < 16; j+=2)
+		for (j = 0; j < 16 && (i+j+16)/2 < ARRAY_SIZE(start_code); j+=2)
 			outw(start_code[(i+j+16)/2],
 			     ioaddr+0x8000+j);
 	}
