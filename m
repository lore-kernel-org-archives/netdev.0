From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC] Disable addrconf on ~multicast interfaces?
Date: Thu, 5 Oct 2006 15:35:31 +1000
Message-ID: <20061005053531.GA19482@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12562 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751488AbWJEFfl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 01:35:41 -0400
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji-san:

Are there any non-multicast interfaces that require addrconf?
In other words, what does the following patch break :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2130,6 +2130,9 @@ static void addrconf_dev_config(struct n
 		return;
 	}
 
+	if (!(dev->flags & IFF_MULTICAST))
+		return;
+
 	idev = addrconf_add_dev(dev);
 	if (idev == NULL)
 		return;
