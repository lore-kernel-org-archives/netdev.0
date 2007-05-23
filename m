From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] e1000: Don't enable polling in open() (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Wed, 23 May 2007 20:47:11 +1000
Message-ID: <20070523104711.GA24332@gondor.apana.org.au>
References: <20070521215134.14885.84952.stgit@localhost.localdomain> <46522E6F.9060600@garzik.org> <20070522010137.GC8130@gondor.apana.org.au> <465320A6.80706@redhat.com> <4653223D.2010108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	stable@kernel.org, Greg KH <greg@kroah.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davej@redhat.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3356 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757643AbXEWKrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 06:47:45 -0400
Content-Disposition: inline
In-Reply-To: <4653223D.2010108@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 22, 2007 at 10:02:53AM -0700, Kok, Auke wrote:
> 
> I've posted that before and it's up to the stable team. I think that it's a 
> seriously toolarge change unless Herbert posts his short version of the fix 
> for 2.6.21.1. I would be OK with that.

This patch should work for 2.6.21.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b28a915..1e4e722 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1423,6 +1423,7 @@ e1000_open(struct net_device *netdev)
 
 	e1000_power_up_phy(adapter);
 
+	netif_poll_disable(netdev);
 	if ((err = e1000_up(adapter)))
 		goto err_up;
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
