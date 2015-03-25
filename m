From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH 2/2] IB/Verbs: Use helpers to check IBoE technology
Date: Wed, 25 Mar 2015 12:16:09 +0100
Message-ID: <551298F9.8030306@profitbricks.com>
References: <55129832.2070707@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>, Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Tom Gundersen <
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <55129832.2070707-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


This patch will introduce rdma_tech_is_iboe() and use it to save some code.

Cc: Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
---
  drivers/infiniband/core/cma.c | 6 ++----
  include/rdma/ib_verbs.h       | 6 ++++++
  2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 668e955..d354857 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -375,8 +375,7 @@ static int cma_acquire_dev(struct rdma_id_private 
*id_priv,
                       listen_id_priv->id.port_num) == dev_ll) {
          cma_dev = listen_id_priv->cma_dev;
          port = listen_id_priv->id.port_num;
-        if (rdma_transport_is_ib(cma_dev->device) &&
-            rdma_port_ll_is_eth(cma_dev->device, port))
+        if (rdma_tech_is_iboe(cma_dev->device, port))
              ret = ib_find_cached_gid(cma_dev->device, &iboe_gid,
                           &found_port, NULL);
          else
@@ -395,8 +394,7 @@ static int cma_acquire_dev(struct rdma_id_private 
*id_priv,
                  listen_id_priv->id.port_num == port)
                  continue;
              if (rdma_port_get_link_layer(cma_dev->device, port) == 
dev_ll) {
-                if (rdma_transport_is_ib(cma_dev->device) &&
-                    rdma_port_ll_is_eth(cma_dev->device, port))
+                if (rdma_tech_is_iboe(cma_dev->device, port))
                      ret = ib_find_cached_gid(cma_dev->device, 
&iboe_gid, &found_port, NULL);
                  else
                      ret = ib_find_cached_gid(cma_dev->device, &gid, 
&found_port, NULL);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 2bf9094..9a811f8 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1767,6 +1767,12 @@ static inline int rdma_port_ll_is_eth(struct 
ib_device *device, u8 port_num)
              == IB_LINK_LAYER_ETHERNET;
  }

+static inline int rdma_tech_is_iboe(struct ib_device *device, u8 port_num)
+{
+    return rdma_transport_is_ib(device) &&
+            rdma_port_ll_is_eth(device, port_num);
+}
+
  int ib_query_gid(struct ib_device *device,
           u8 port_num, int index, union ib_gid *gid);

-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
