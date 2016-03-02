From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [Intel-wired-lan] [net-next PATCH] net: relax setup_tc ndo op
	handle restriction
Date: Wed, 2 Mar 2016 02:09:42 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A18490D77AEA@ORSMSX104.amr.corp.intel.com>
References: <20160229192613.24163.31830.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:3914 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756805AbcCBCJo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 21:09:44 -0500
In-Reply-To: <20160229192613.24163.31830.stgit@john-Precision-Tower-5810>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of John Fastabend
> Sent: Monday, February 29, 2016 11:26 AM
> To: intel-wired-lan@lists.osuosl.org; john.fastabend@gmail.com; Kirsher,
> Jeffrey T
> Cc: netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [net-next PATCH] net: relax setup_tc ndo op
> handle restriction
> 
> I added this check in setup_tc to multiple drivers,
> 
>  if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
> 
> Unfortunately restricting to TC_H_ROOT like this breaks the old
> instantiation of mqprio to setup a hardware qdisc. This patch
> relaxes the test to only check the type to make it equivalent
> to the check before I broke it. With this the old instantiation
> continues to work.
> 
> A good smoke test is to setup mqprio with,
> 
> # tc qdisc add dev eth4 root mqprio num_tc 8 \
>   map 0 1 2 3 4 5 6 7 \
>   queues 0@0 1@1 2@2 3@3 4@4 5@5 6@6 7@7
> 
> Fixes: e4c6734eaab9 ("net: rework ndo tc op to consume additional qdisc
> handle paramete")
> Reported-by: Singh Krishneil <krishneil.k.singh@intel.com>
> Reported-by: Jake Keller <jacob.e.keller@intel.com>
> CC: Murali Karicheri <m-karicheri2@ti.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: Or Gerlitz <ogerlitz@mellanox.com>
> CC: Ariel Elior <ariel.elior@qlogic.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Bruce Allan <bruce.w.allan@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  drivers/net/ethernet/amd/xgbe/xgbe-drv.c        |    2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c       |    2 +-
>  drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    2 +-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2 +-
>  drivers/net/ethernet/sfc/tx.c                   |    2 +-
>  drivers/net/ethernet/ti/netcp_core.c            |    2 +-
>  8 files changed, 8 insertions(+), 8 deletions(-)

Jeff, please apply this to your next-queue tree/dev-queue branch ASAP as it is
blocking the testing of another patch already in that queue.

Thanks,
Bruce.
