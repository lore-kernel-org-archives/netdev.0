From: David Miller <davem@davemloft.net>
Subject: Re: sysfs_format_mac
Date: Tue, 16 Jul 2013 16:25:49 -0700 (PDT)
Message-ID: <20130716.162549.1211987183945448630.davem@davemloft.net>
References: <1374007586.1949.25.camel@joe-AO722>
	<20130716.135857.1132486724952537431.davem@davemloft.net>
	<1374009169.1949.38.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41666 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071Ab3GPXZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 19:25:51 -0400
In-Reply-To: <1374009169.1949.38.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 16 Jul 2013 14:12:49 -0700

> On Tue, 2013-07-16 at 13:58 -0700, David Miller wrote:
>> From: Joe Perches <joe@perches.com>
>> Date: Tue, 16 Jul 2013 13:46:26 -0700
>> > On Tue, 2013-07-16 at 12:56 -0700, David Miller wrote:
> []
>> >> It would make so much more sense to allow specifying a length
>> >> specifier to %pm and friends.
>> > 
>> > scnprintf("%*ph", (int)size, buffer)
>> 
>> Yes, exactly, something like that.
> 
> That works now.

Oh, hehe, indeed.

I'm about to test the following.

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5359560..2307062 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -401,27 +401,8 @@ struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 }
 EXPORT_SYMBOL(alloc_etherdev_mqs);
 
-static size_t _format_mac_addr(char *buf, int buflen,
-			       const unsigned char *addr, int len)
-{
-	int i;
-	char *cp = buf;
-
-	for (i = 0; i < len; i++) {
-		cp += scnprintf(cp, buflen - (cp - buf), "%02x", addr[i]);
-		if (i == len - 1)
-			break;
-		cp += scnprintf(cp, buflen - (cp - buf), ":");
-	}
-	return cp - buf;
-}
-
 ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 {
-	size_t l;
-
-	l = _format_mac_addr(buf, PAGE_SIZE, addr, len);
-	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
-	return (ssize_t)l;
+	return scnprintf(buf, PAGE_SIZE, "%*phC", len, addr);
 }
 EXPORT_SYMBOL(sysfs_format_mac);
