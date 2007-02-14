From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Thu, 15 Feb 2007 08:31:45 +1100
Message-ID: <E1HHRj7-0002HG-00@gondolin.me.apana.org.au>
References: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
Cc: hasso@estpak.ee, yoshfuji@linux-ipv6.org, davem@davemloft.net,
	netdev@vger.kernel.org, aramoto@linux-ipv6.org,
	kozakai@linux-ipv6.org
To: herbert@gondor.apana.org.au (Herbert Xu)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1336 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932645AbXBNVbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 16:31:53 -0500
In-Reply-To: <E1HHRCL-00028w-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> [IPV4] devinet: Register inetdev earlier.

I needed to move the panic call as well.

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
index ba5e7f4..2224f8e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1055,12 +1055,14 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		if (event == NETDEV_REGISTER && dev == &loopback_dev) {
+		if (event == NETDEV_REGISTER) {
 			in_dev = inetdev_init(dev);
-			if (!in_dev)
-				panic("devinet: Failed to create loopback\n");
-			in_dev->cnf.no_xfrm = 1;
-			in_dev->cnf.no_policy = 1;
+			if (dev == &loopback_dev) {
+				if (!in_dev)
+					panic("devinet: Failed to create loopback\n");
+				in_dev->cnf.no_xfrm = 1;
+				in_dev->cnf.no_policy = 1;
+			}
 		}
 		goto out;
 	}
