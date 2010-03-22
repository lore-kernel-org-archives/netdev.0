From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next-2.6 PATCH] ipoib: remove addrlen check for mc addresses
Date: Mon, 22 Mar 2010 14:21:39 +0100
Message-ID: <20100322132138.GC2780@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, monis-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Finally this bit can be removed. Currently, after the bonding driver is
changed/fixed (32a806c194ea112cfab00f558482dd97bee5e44e net-next-2.6),
that's not possible for an addr with different length than dev->addr_len
to be present in list. Removing this check as in new mc_list there will be
no addrlen in the record.

Signed-off-by: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
index d41ea27..19eba3c 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_multicast.c
@@ -767,11 +767,8 @@ void ipoib_mcast_dev_flush(struct net_device *dev)
 	}
 }
 
-static int ipoib_mcast_addr_is_valid(const u8 *addr, unsigned int addrlen,
-				     const u8 *broadcast)
+static int ipoib_mcast_addr_is_valid(const u8 *addr, const u8 *broadcast)
 {
-	if (addrlen != INFINIBAND_ALEN)
-		return 0;
 	/* reserved QPN, prefix, scope */
 	if (memcmp(addr, broadcast, 6))
 		return 0;
@@ -815,7 +812,6 @@ void ipoib_mcast_restart_task(struct work_struct *work)
 		union ib_gid mgid;
 
 		if (!ipoib_mcast_addr_is_valid(mclist->dmi_addr,
-					       mclist->dmi_addrlen,
 					       dev->broadcast))
 			continue;
 
-- 
1.6.6.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
