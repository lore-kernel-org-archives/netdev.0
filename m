From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [UDP]: Restore missing inDatagrams increments
Date: Wed, 5 Dec 2007 21:04:52 +1100
Message-ID: <20071205100452.GA18026@gondor.apana.org.au>
References: <20071205021559.GA27707@gondor.apana.org.au> <47567128.2060008@cosmosbay.com> <20071205095159.GA16860@gondor.apana.org.au> <20071205.020248.50886654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, wangchen@cn.fujitsu.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1396 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751116AbXLEKFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 05:05:05 -0500
Content-Disposition: inline
In-Reply-To: <20071205.020248.50886654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 02:02:48AM -0800, David Miller wrote:
>
> Herbert, I applied the buggered patch and pushed it out
> already, can you send me this fix relative?
> 
> I'll combine them on my next rebase, thanks.

Sure, here it is.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/udp.h b/include/net/udp.h
index 87170bb..98cb09c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -162,6 +162,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 	if (is_udplite) SNMP_INC_STATS_USER(udplite_stats_in6, field);         \
 	else		SNMP_INC_STATS_USER(udp_stats_in6, field);    } while(0)
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define UDPX_INC_STATS_BH(sk, field) \
 	do { \
 		if ((sk)->sk_family == AF_INET) \
@@ -169,6 +170,9 @@ DECLARE_SNMP_STAT(struct udp_mib, udplite_stats_in6);
 		else \
 			UDP6_INC_STATS_BH(field, 0); \
 	} while (0);
+#else
+#define UDPX_INC_STATS_BH(sk, field) UDP_INC_STATS_BH(field, 0)
+#endif
 
 /* /proc */
 struct udp_seq_afinfo {
