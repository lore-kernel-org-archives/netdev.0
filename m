From: Michael Wang <yun.wang-EIkl63zCoXaH+58JC4qpiA@public.gmane.org>
Subject: [RFC PATCH 00/11] IB/Verbs: IB Management Helpers
Date: Fri, 27 Mar 2015 16:39:54 +0100
Message-ID: <551579CA.4030901@profitbricks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	PJ Waskiewicz <pj.waskiewicz-PrFOU5CTvK1l57MIdRCFDg@public.gmane.org>,
	Tatyana Nikolova <Tatyana.E.Nikolova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yan Burman <yanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Alex Estrin <alex.estrin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Sagi Grimberg <sagig-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Mike Marciniszyn <mike.m
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ira Weiny <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


There are plenty of lengthy code to check the transport type of IB device,
or the link layer type of it's port, but actually we are just speculating
whether a particular management is supported by the device/port.

Thus instead of inferring, we should have our own mechanism for
IB management capability/protocol checking, several proposals below.

This patch set is the pioneer which try to collecting all the cases where
a management helper applicable, and put all the speculating logical together,
in order to be easily integrated to the new querying mechanism in future.

TODO:
    The helper in patch 10 and 11 are still to be classified, that is
    cap_ib() and cap_eth().

    The name/description of each helper may not correct enough, those folks
    who are familiar with these particular parts, your suggestion would be
    invaluable ;-)

Proposals:
    Sean:
    https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23339.html
    Doug:
    https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23418.html
    Jason:
    https://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg23425.html

Michael Wang (11):
    [PATCH 01/11] IB/Verbs: Use helpers to check transport and link layer
    [RFC PATCH 02/11] IB/Verbs: Use management helper tech_iboe() for iboe-check
    [RFC PATCH 03/11] IB/Verbs: Use management helper has_mad() for mad-check
    [RFC PATCH 04/11] IB/Verbs: Use management helper cap_smi() for smi-check
    [RFC PATCH 05/11] IB/Verbs: Use management helper has_cm() for cm-check
    [RFC PATCH 06/11] IB/Verbs: Use management helper has_sa() and cap_sa() for sa-check
    [RFC PATCH 07/11] IB/Verbs: Use management helper has_mcast() and cap_mcast() for mcast-check
    [RFC PATCH 08/11] IB/Verbs: Use management helper has_iwarp() for iwarp-check
    [RFC PATCH 09/11] IB/Verbs: Use management helper has_ipoib() and cap_ipoib() for ipoib-check
    [RFC PATCH 10/11] IB/Verbs: Use management helper cap_ib() for ib-check
    [RFC PATCH 11/11] IB/Verbs: Use management helper cap_eth() for eth-check

---
 drivers/infiniband/core/agent.c           |    6
 drivers/infiniband/core/cm.c              |    6
 drivers/infiniband/core/cma.c             |   79 ++++------
 drivers/infiniband/core/mad.c             |   18 +-
 drivers/infiniband/core/multicast.c       |   30 +---
 drivers/infiniband/core/sa_query.c        |   42 ++---
 drivers/infiniband/core/ucm.c             |    8 -
 drivers/infiniband/core/user_mad.c        |    6
 drivers/infiniband/core/verbs.c           |   14 -
 drivers/infiniband/hw/mlx4/ah.c           |    6
 drivers/infiniband/hw/mlx4/cq.c           |   10 -
 drivers/infiniband/hw/mlx4/mad.c          |   36 +---
 drivers/infiniband/hw/mlx4/main.c         |   23 +--
 drivers/infiniband/hw/mlx4/mlx4_ib.h      |    6
 drivers/infiniband/hw/mlx4/qp.c           |   57 ++-----
 drivers/infiniband/hw/mlx4/sysfs.c        |   16 --
 drivers/infiniband/ulp/ipoib/ipoib_main.c |   18 +-
 include/rdma/ib_verbs.h                   |  218 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c   |    8 -
 19 files changed, 381 insertions(+), 226 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
