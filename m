From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
	(was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Thu, 24 May 2007 11:29:21 +1000
Message-ID: <20070524012921.GA2943@gondor.apana.org.au>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
	<46522E6F.9060600@garzik.org>
	<20070522010137.GC8130@gondor.apana.org.au>
	<465320A6.80706@redhat.com> <4653223D.2010108@intel.com>
	<20070523104711.GA24332@gondor.apana.org.au>
	<20070523233418.GA3391@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	Greg KH <greg@kroah.com>, Chuck Ebbert <cebbert@redhat.com>,
	netdev@vger.kernel.org, davej@redhat.com, stable@kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070523233418.GA3391@sequoia.sous-sol.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, May 23, 2007 at 04:34:18PM -0700, Chris Wright wrote:
> 
> Mind adding an updated changelog and signed-off-by please?

Sure.

[E1000]: Fix netif_poll_enable crash in e1000_open

e1000_open calls e1000_up which will always call netif_poll_enable.
However, it's illegal to call netif_poll_enable without calling
netif_poll_disable at some prior time.  This constraint is violated
in e1000_open.

This patch fixes it by simply calling netif_poll_disable in e1000_open.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

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

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
