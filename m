From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: kisskb: FAILED linux-next/s390-defconfig/s390x Thu Jun 08,
 18:28
Date: Thu, 8 Jun 2017 19:11:43 +1000
Message-ID: <20170608191143.0d54c17e@canb.auug.org.au>
References: <20170608082932.1.78356@6b879c743ee1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:45425 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750725AbdFHJLq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 05:11:46 -0400
In-Reply-To: <20170608082932.1.78356@6b879c743ee1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Thu, 08 Jun 2017 08:29:32 -0000 noreply@ellerman.id.au wrote:
>
> FAILED linux-next/s390-defconfig/s390x Thu Jun 08, 18:28
> 
> http://kisskb.ellerman.id.au/kisskb/buildresult/13055728/
> 
> Commit:   Add linux-next specific files for 20170608
>           e4689b9aad2ded9ed83e3c5f61e84388762295c4
> Compiler: s390x-linux-gcc (GCC) 4.6.3
> 
> Possible errors
> ---------------
> 
> drivers/s390/net/netiucv.c:1975:5: error: 'struct net_device' has no member named 'destructor'
> make[3]: *** [drivers/s390/net/netiucv.o] Error 1
> make[2]: *** [drivers/s390/net] Error 2
> make[1]: *** [drivers/s390] Error 2
> make: *** [sub-make] Error 2

Another one for the net tree ...

I haven't actually even build tested this, but it seems obvious ...

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Jun 2017 19:06:29 +1000
Subject: [PATCH] net: s390: fix up for "Fix inconsistent teardown and release
 of private netdev state"

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/s390/net/netiucv.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index dba94b486f05..fa732bd86729 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1954,7 +1954,6 @@ static void netiucv_free_netdevice(struct net_device *dev)
 		privptr->conn = NULL; privptr->fsm = NULL;
 		/* privptr gets freed by free_netdev() */
 	}
-	free_netdev(dev);
 }
 
 /**
@@ -1972,7 +1971,8 @@ static void netiucv_setup_netdevice(struct net_device *dev)
 	dev->mtu	         = NETIUCV_MTU_DEFAULT;
 	dev->min_mtu		 = 576;
 	dev->max_mtu		 = NETIUCV_MTU_MAX;
-	dev->destructor          = netiucv_free_netdevice;
+	dev->needs_free_netdev   = true;
+	dev->priv_destructor     = netiucv_free_netdevice;
 	dev->hard_header_len     = NETIUCV_HDRLEN;
 	dev->addr_len            = 0;
 	dev->type                = ARPHRD_SLIP;
-- 
2.11.0

-- 
Cheers,
Stephen Rothwell
