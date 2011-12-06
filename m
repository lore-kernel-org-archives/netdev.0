From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/4 v2] bnx2x, cnic: support DRV_INFO upon FW
 request
Date: Mon, 05 Dec 2011 23:58:14 -0800
Message-ID: <1323158294.1762.4.camel@joe2Laptop>
References: <1323157945-28333-1-git-send-email-mchan@broadcom.com>
	 <1323157945-28333-2-git-send-email-mchan@broadcom.com>
	 <1323157945-28333-3-git-send-email-mchan@broadcom.com>
	 <1323157945-28333-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, barak@broadcom.com,
	eilong@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34171 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932964Ab1LFH6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 02:58:17 -0500
In-Reply-To: <1323157945-28333-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-05 at 23:52 -0800, Michael Chan wrote:
> From: Barak Witkowski <barak@broadcom.com>
> Add support to send driver capabilities, settings and statistics to
> management firmware.
[]
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
[]
> @@ -1965,9 +1970,38 @@ struct shmem2_region {
[]
> +	u32 drv_capabilities_flag[E2_FUNC_MAX];
> +	#define DRV_FLAGS_CAPABALITIES_LOADED_SUPPORTED 0x00000001

capabilities.

> +	#define DRV_FLAGS_CAPABILITIES_LOADED_L2        0x00000002
> +	#define DRV_FLAGS_CAPABILITIES_LOADED_FCOE      0x00000004
> +	#define DRV_FLAGS_CAPABILITIES_LOADED_ISCSI     0x00000008

I think the #defines should be left aligned.

> +/*  Per PCI Function FCOE Statistics required from the driver */
> +struct fcoe_stats_info {
> +	u8 version[12];		/* Function's Driver Version. */
> +	u8 mac_local[8];	/* Locally Admin Addr. */
> +	u8 mac_add1[8];		/* Additional Programmed MAC Addr 1. */
> +	u8 mac_add2[8];		/* Additional Programmed MAC Addr 2. */

Should these addresses be u8 name[6]?
