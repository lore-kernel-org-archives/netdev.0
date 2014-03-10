From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next 0/7] mlx4: Add SRIOV support for RoCE
Date: Mon, 10 Mar 2014 13:08:02 -0500
Message-ID: <1394474882.28217.6.camel@dcbw.local>
References: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752381AbaCJSGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 14:06:24 -0400
In-Reply-To: <1394376844-12812-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-09 at 16:53 +0200, Or Gerlitz wrote:
> Hi Dave, Roland
> 
> This series adds SRIOV support for RoCE (RDMA over Ethernet). 
> 
> The patches touch both the mlx4_core and mlx4_ib drivers, and as such we 
> prefer to run them through netdev and the net-next tree. This will also 
> allow for another feature we hope to get accepted during the coming merge 
> window (single ported mlx4 VFs) which is strictly in mlx4_core to get in 
> smoothly without heavy context based dependencies with the IB tree. 
> 
> Roland, hope this is ok with you?

While I could be wrong, I think the phys_port_id sysfs attribute is
relevant here.  This attribute should be set for any VF so that
userspace clients can determine that two VFs are backed by the same PF,
which of course means they share bandwidth and thus some operations
cannot be performed.  This is implemented with ndo_get_phys_port_id.

Dan

> The patches are against net-next, as of commit 2d8d40a "pkt_sched: fq: 
> do not hold qdisc lock while allocating memory"
> 
> Or.
> 
> 
> Jack Morgenstein (6):
>   mlx4: Adjust QP1 multiplexing for RoCE/SRIOV
>   mlx4_core: For RoCE, allow slaves to set the GID entry at that slave's index
>   mlx4: In RoCE allow guests to have multiple GIDS
>   mlx4: Add ref counting to port MAC table for RoCE
>   mlx4: Implement IP based gids support for RoCE/SRIOV
>   mlx4: Activate RoCE/SRIOV
> 
> Shani Michaelli (1):
>   mlx4_ib: Fix SIDR support of for UD QPs under SRIOV/RoCE
> 
>  drivers/infiniband/hw/mlx4/cm.c                    |   80 ++++-
>  drivers/infiniband/hw/mlx4/cq.c                    |   42 ++-
>  drivers/infiniband/hw/mlx4/mad.c                   |  123 +++++++-
>  drivers/infiniband/hw/mlx4/main.c                  |    8 -
>  drivers/infiniband/hw/mlx4/mcg.c                   |    2 +-
>  drivers/infiniband/hw/mlx4/mlx4_ib.h               |   21 ++-
>  drivers/infiniband/hw/mlx4/qp.c                    |  319 ++++++++++++++++----
>  drivers/net/ethernet/mellanox/mlx4/cmd.c           |   23 ++
>  drivers/net/ethernet/mellanox/mlx4/fw.c            |    5 +-
>  drivers/net/ethernet/mellanox/mlx4/main.c          |    6 +-
>  drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    8 +
>  drivers/net/ethernet/mellanox/mlx4/port.c          |  142 +++++++++-
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  146 ++++++++--
>  include/linux/mlx4/cmd.h                           |    6 +
>  include/linux/mlx4/device.h                        |    8 +-
>  15 files changed, 801 insertions(+), 138 deletions(-)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
