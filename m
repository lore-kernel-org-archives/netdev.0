From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Thu, 15 Feb 2007 07:57:53 +1100
Message-ID: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
References: <200702142119.11304.hasso@estpak.ee>
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org
To: hasso@estpak.ee (Hasso Tepper)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1125 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932580AbXBNU7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 15:59:34 -0500
In-Reply-To: <200702142119.11304.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hasso Tepper <hasso@estpak.ee> wrote:
> 
> Many thanks. Now if only IPv4 would be fixed in similar fashion as well.

Here you go.

[IPV4] devinet: Register inetdev earlier.

This patch allocates inetdev at registration for all devices
in line with IPv6.  This allows sysctl configuration on the
devices to occur before they're brought up or addresses are
added.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index ba5e7f4..3a4497c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1055,12 +1055,14 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		if (event == NETDEV_REGISTER && dev == &loopback_dev) {
+		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
 			if (!in_dev)
 				panic("devinet: Failed to create loopback\n");
-			in_dev->cnf.no_xfrm = 1;
-			in_dev->cnf.no_policy = 1;
+			if (dev == &loopback_dev) {
+				in_dev->cnf.no_xfrm = 1;
+				in_dev->cnf.no_policy = 1;
+			}
 		}
 		goto out;
 	}
