From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: RE: [RFC net-next (v2) 11/14] igb: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 17:31:30 +0000
Message-ID: <06DFBC1E25D8024DB214DC7F41A3CD3448870CE4@ORSMSX101.amr.corp.intel.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com>
 <1340624745-8650-12-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "eilong@broadcom.com" <eilong@broadcom.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:12101 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab2FYRbk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:31:40 -0400
In-Reply-To: <1340624745-8650-12-git-send-email-yuvalmin@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Yuval Mintz
> Sent: Monday, June 25, 2012 4:46 AM
> To: davem@davemloft.net; netdev@vger.kernel.org
> Cc: eilong@broadcom.com; Yuval Mintz; Kirsher, Jeffrey T
> Subject: [RFC net-next (v2) 11/14] igb: set maximal number of default
> RSS queues
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> 
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index 01ced68..b11ee60 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2465,7 +2465,8 @@ static int __devinit igb_sw_init(struct
> igb_adapter *adapter)
>  		break;
>  	}
> 
> -	adapter->rss_queues = min_t(u32, max_rss_queues,
> num_online_cpus());
> +	adapter->rss_queues = min_t(u32, max_rss_queues,
> +				    netif_get_num_default_rss_queues());
> 
>  	/* Determine if we need to pair queues. */
>  	switch (hw->mac.type) {
> --
> 1.7.9.rc2

Since igb supports a maximum of 8 RSS queues anyway, it's generally unaffected by this change. That being said, I'm confused about what you're trying to accomplish--is it to standardize the number of RSS queues or limit the number of interrupts by default? Or is it the former with a hope that it will trickle down to the latter?

For example, if you take an igb device that supports 8 RSS queues (say, I350) and you change the default to 4 RSS queues, you will end up with the same number of interrupt vectors being requested as we will disable queue pairing and request separate vectors for Rx/Tx queues. I haven't looked at the other drivers affected by this RFC, but it's possible other drivers behave the same way.

Matthew

Matthew Vick
Linux Development
LAN Access Division
Intel Corporation
