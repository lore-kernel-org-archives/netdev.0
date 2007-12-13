From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice
Date: Thu, 13 Dec 2007 11:13:44 +0800
Message-ID: <E1J2eW8-0000GQ-00@gondolin.me.apana.org.au>
References: <20071212.104614.208083873.davem@davemloft.net>
Cc: wangchen@cn.fujitsu.com, jgarzik@pobox.com, khc@pm.waw.pl,
	netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1853 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751561AbXLMDOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 22:14:08 -0500
In-Reply-To: <20071212.104614.208083873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 12 Dec 2007 10:35:56 +0800
> 
>> [PATCH] HDLC driver: use unregister_netdev instead of unregister_netdevice
> 
> Applied, thanks for finding and fixing this bug.

Let's see who else is doing this:

[NET]: Check RTNL status in unregister_netdevice

The caller must hold the RTNL so let's check it in unregister_netdevice.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 06615df..b254e52 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3967,6 +3967,8 @@ void synchronize_net(void)
 
 void unregister_netdevice(struct net_device *dev)
 {
+	ASSERT_RTNL();
+
 	rollback_registered(dev);
 	/* Finish processing unregister after unlock */
 	net_set_todo(dev);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
