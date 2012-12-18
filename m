From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH V4 0/5] Add LE hash collision bug fix for active and passive
 offloaded connections
Date: Tue, 18 Dec 2012 10:11:00 -0600
Message-ID: <50D09594.9050006@opengridcomputing.com>
References: <1355131856-29142-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, abhishek-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1355131856-29142-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

On 12/10/2012 3:30 AM, Vipul Pandya wrote:
> This patch series fixes the LE hash collision issue in cxgb4 and RDMA/cxgb4
> drivers in kernel.org.
>
> If the hash functionality is enabled in T4 then tuple information of active and
> passive offloaded connections are stored in DDR3 memory. LE (Lookup Engine)
> implements the interface to search this tuple entries using hash algorithm. To
> avoid LE hash collision, firmware provides new mechanisms to setup active and
> passive open connections.
>
> In case of active open connection, firmware detects LE hash collision situation
> and notifies driver. Driver uses fw_ofld_connection work request to offload
> that connection. Its tuple information will be stored in TCAM memory array.
>
> In case of passive open connection, server filter region is created in TCAM.
> This region stores the filter which will redirect the incoming SYN packet to
> offload queues. After this driver tries to establish the connection using
> firmware work request.
>
> This patch series also adds framework for managing filters and to use T4's
> filter capabilities.
>
> Following testing has been carried out successfully on this patch series.
> 1. 1000 active open connections created and saw that tcam_full counter is
> getting incremented through debugfs file.
> 2. Multiple passive open connections were created and ran the same test
> repetatively to verify server filter is getting created and deleted properly.
>
> The patch-series is based on Roland's infiniband tree (for-next branch),
> and involves changes on cxgb4 and RDMA/cxgb4 drivers. Both linux-rdma and netdev
> are included in this post for review.
>
> We have some more bug fixes in RDMA/cxgb4 after this patch series. So, we would
> like to request this series to get mereged through Roland's infiniband for-next
> tree.
>
> V2: Changed commenting style from kernel-doc format('/**') to normal
> V3: Resending the whole patch series again with the missing patches in V2
> V4: Changed comments for networking from '/*' to '/* Comment' format.
>
> Thanks,
> Vipul Pandya
>
> Vipul Pandya (5):
>    cxgb4: Add T4 filter support
>    cxgb4: Add LE hash collision bug fix path in LLD driver
>    RDMA/cxgb4: Fix LE hash collision bug for active open connection
>    RDMA/cxgb4: Fix LE hash collision bug for passive open connection
>    RDMA/cxgb4: Fix bug for active and passive LE hash collision path
>
>   drivers/infiniband/hw/cxgb4/cm.c                |  789 +++++++++++++++++++---
>   drivers/infiniband/hw/cxgb4/device.c            |  210 ++++++-
>   drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   33 +
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  146 +++++
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  473 +++++++++++++-
>   drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   23 +-
>   drivers/net/ethernet/chelsio/cxgb4/l2t.c        |   34 +
>   drivers/net/ethernet/chelsio/cxgb4/l2t.h        |    3 +
>   drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   23 +-
>   drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   66 ++
>   drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   37 ++
>   drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  388 +++++++++++
>   12 files changed, 2100 insertions(+), 125 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
