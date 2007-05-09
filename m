From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 9 May 2007 15:31:55 +1000
Message-ID: <20070509053154.GA850@gondor.apana.org.au>
References: <20070508222033.4e57a580.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4741 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965337AbXEIFcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:32:02 -0400
Content-Disposition: inline
In-Reply-To: <20070508222033.4e57a580.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 10:20:33PM -0700, Andrew Morton wrote:
> 
> My Vaio is taking 5-10x longer to boot when git-net as of five minutes ago
> is applied.
> 
> It's not very clear what's gone wrong.  A few linkwatch things are showing
> up in profiles, but it's not burning excessive CPU afaict.

Hmm, I don't see it here (probably because we use different NICs).
But does this help?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/core/link_watch.c b/net/core/link_watch.c
index b5f4579..4674ae5 100644
--- a/net/core/link_watch.c
+++ b/net/core/link_watch.c
@@ -101,8 +101,10 @@ static void linkwatch_schedule_work(unsigned long delay)
 		return;
 
 	/* If we wrap around we'll delay it by at most HZ. */
-	if (delay > HZ)
+	if (delay > HZ) {
+		linkwatch_nextevent = jiffies;
 		delay = 0;
+	}
 
 	schedule_delayed_work(&linkwatch_work, delay);
 }
