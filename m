From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH V4 0/5] Add LE hash collision bug fix for active and passive
 offloaded connections
Date: Tue, 18 Dec 2012 21:37:09 +0530
Message-ID: <50D094AD.8040404@chelsio.com>
References: <1355131856-29142-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Vipul Pandya <vipul@chelsio.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Abhishek Agrawal <abhishek@chelsio.com>
To: "roland@purestorage.com" <roland@purestorage.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3590 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712Ab2LRQHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:07:20 -0500
In-Reply-To: <1355131856-29142-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roland and David,

Any feedback on this?

Thanks,
Vipul

On 10-12-2012 15:00, Vipul Pandya wrote:
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
>   cxgb4: Add T4 filter support
>   cxgb4: Add LE hash collision bug fix path in LLD driver
>   RDMA/cxgb4: Fix LE hash collision bug for active open connection
>   RDMA/cxgb4: Fix LE hash collision bug for passive open connection
>   RDMA/cxgb4: Fix bug for active and passive LE hash collision path
> 
>  drivers/infiniband/hw/cxgb4/cm.c                |  789 +++++++++++++++++++---
>  drivers/infiniband/hw/cxgb4/device.c            |  210 ++++++-
>  drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   33 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  146 +++++
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  473 +++++++++++++-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   23 +-
>  drivers/net/ethernet/chelsio/cxgb4/l2t.c        |   34 +
>  drivers/net/ethernet/chelsio/cxgb4/l2t.h        |    3 +
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   23 +-
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   66 ++
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   37 ++
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  388 +++++++++++
>  12 files changed, 2100 insertions(+), 125 deletions(-)
> 
