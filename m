From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [PATCH 1/2] IB/Verbs: Use helpers to refine the checking on transport
 and link layer
Date: Wed, 25 Mar 2015 12:12:50 +0100
Message-ID: <55129832.2070707@profitbricks.com>
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
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


There are too many lengthy code to check the transport type of IB device,
or the link layer type of it's port, this patch set try to use some 
helper to
refine and save us some code.

TODO:
     Currently we inferred from the transport type and link layer type 
to identify
     the way of management, it will be better if we can directly get the 
indicator
     from vendor.

     Sean proposed one suggestion:
  https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23339.html

     It may need a big work to adapt current implementation to utilize
     these flags elegantly.

     Also the performance concern on query_port() need to be addressed, 
may be
     some new callback like query_mgmt() could works.

Michael Wang (2):
     [PATCH 1/2] IB/Verbs: Use helpers to check transport and link layer
     [PATCH 2/2] IB/Verbs: Use helpers to check IBoE technology

---
  drivers/infiniband/core/agent.c           |    2 -
  drivers/infiniband/core/cm.c              |    2 -
  drivers/infiniband/core/cma.c             |   33 
++++++++++++------------------
  drivers/infiniband/core/mad.c             |    6 ++---
  drivers/infiniband/core/multicast.c       |   11 +++-------
  drivers/infiniband/core/sa_query.c        |   14 ++++++------
  drivers/infiniband/core/ucm.c             |    3 --
  drivers/infiniband/core/user_mad.c        |    2 -
  drivers/infiniband/core/verbs.c           |    5 +---
  drivers/infiniband/hw/mlx4/ah.c           |    2 -
  drivers/infiniband/hw/mlx4/cq.c           |    4 ---
  drivers/infiniband/hw/mlx4/mad.c          |   14 +++---------
  drivers/infiniband/hw/mlx4/main.c         |    8 ++-----
  drivers/infiniband/hw/mlx4/mlx4_ib.h      |    2 -
  drivers/infiniband/hw/mlx4/qp.c           |   21 ++++++-------------
  drivers/infiniband/hw/mlx4/sysfs.c        |    6 +----
  drivers/infiniband/ulp/ipoib/ipoib_main.c |    6 ++---
  include/rdma/ib_verbs.h                   |   30 
+++++++++++++++++++++++++++
  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    3 --
  19 files changed, 87 insertions(+), 87 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
