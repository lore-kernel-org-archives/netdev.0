From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] IPoIB: Fix build now that destructor is in
	neigh_params
Date: Tue, 07 Mar 2006 11:21:08 -0800
Message-ID: <adawtf6rrh7.fsf_-_@cisco.com>
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

Dave, here's an incremental patch that fixes the IPoIB build (which is
broken in net-2.6.17 because of my screw-up, which left out the chunk
below).  I'll also send a full patch that can replace the "Move
destructor from neigh->ops to neigh_params" patch if you'd rather
replace it in your tree.

Thanks, and sorry about the screw-up.

---

Get rid of the last place in IPoIB where we clear
neigh->neighbour->ops->destructor.  This is broken now that the
destructor member has moved to neigh_params.

Signed-off-by: Roland Dreier <rolandd@cisco.com>

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index a2408d7..19fd173 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -115,7 +115,6 @@ static void ipoib_mcast_free(struct ipoi
 		if (neigh->ah)
 			ipoib_put_ah(neigh->ah);
 		*to_ipoib_neigh(neigh->neighbour) = NULL;
-		neigh->neighbour->ops->destructor = NULL;
 		kfree(neigh);
 	}
 
