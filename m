From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] net: Move destructor from neigh->ops
	to neigh_params
Date: Mon, 06 Mar 2006 21:50:30 -0800
Message-ID: <ada3bhu247t.fsf@cisco.com>
References: <adazmlmmy7v.fsf@cisco.com> <20060306211630.0df79464.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060306211630.0df79464.akpm@osdl.org> (Andrew Morton's message
	of "Mon, 6 Mar 2006 21:16:30 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Andrew> I'm also wondering why a combination of the net and
    Andrew> infiniband trees does this:

    Andrew> drivers/infiniband/ulp/ipoib/ipoib_multicast.c: In
    Andrew> function `ipoib_mcast_free':
    Andrew> drivers/infiniband/ulp/ipoib/ipoib_multicast.c:118: error:
    Andrew> structure has no member named `destructor'

A cock-up on my part.  I think I fixed this when testing the patch,
and promptly forgot about doing it.  Then when I reposted the patch to
netdev, I decided to be very careful about things, so I went back to
pristine sources from Michael's message, which of course is missing
the following chunk:

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index fde442a..93c462e 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -115,7 +115,6 @@ static void ipoib_mcast_free(struct ipoi
 		if (neigh->ah)
 			ipoib_put_ah(neigh->ah);
 		*to_ipoib_neigh(neigh->neighbour) = NULL;
-		neigh->neighbour->ops->destructor = NULL;
 		kfree(neigh);
 	}
 
