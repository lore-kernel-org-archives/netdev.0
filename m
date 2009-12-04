From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH 08/31] Constify struct e1000_phy_operations for 2.6.32
 v1
Date: Fri, 4 Dec 2009 14:40:56 -0800 (Pacific Standard Time)
Message-ID: <Pine.WNT.4.64.0912041440310.5228@ppwaskie-MOBL2.amr.corp.intel.com>
References: <4B198670.2000406@gmail.com> <4B198AE3.2040003@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10476 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754401AbZLDWkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 17:40:51 -0500
In-Reply-To: <4B198AE3.2040003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Dec 2009, Emese Revfy wrote:

> From: Emese Revfy <re.emese@gmail.com>
> 
> Constify struct e1000_phy_operations.
> 
> Signed-off-by: Emese Revfy <re.emese@gmail.com>

Added Dave Miller and netdev.

> ---
>  drivers/net/e1000e/82571.c    |    6 +++---
>  drivers/net/e1000e/e1000.h    |    2 +-
>  drivers/net/e1000e/es2lan.c   |    2 +-
>  drivers/net/e1000e/ich8lan.c  |    2 +-
>  drivers/net/igb/e1000_82575.c |    2 +-
>  drivers/net/igb/e1000_hw.h    |    2 +-
>  6 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
> index d1e0563..9457254 100644
> --- a/drivers/net/e1000e/82571.c
> +++ b/drivers/net/e1000e/82571.c
> @@ -1674,7 +1674,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
>  	.setup_led		= e1000e_setup_led_generic,
>  };
>  
> -static struct e1000_phy_operations e82_phy_ops_igp = {
> +static const struct e1000_phy_operations e82_phy_ops_igp = {
>  	.acquire_phy		= e1000_get_hw_semaphore_82571,
>  	.check_reset_block	= e1000e_check_reset_block_generic,
>  	.commit_phy		= NULL,
> @@ -1691,7 +1691,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
>  	.cfg_on_link_up      	= NULL,
>  };
>  
> -static struct e1000_phy_operations e82_phy_ops_m88 = {
> +static const struct e1000_phy_operations e82_phy_ops_m88 = {
>  	.acquire_phy		= e1000_get_hw_semaphore_82571,
>  	.check_reset_block	= e1000e_check_reset_block_generic,
>  	.commit_phy		= e1000e_phy_sw_reset,
> @@ -1708,7 +1708,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
>  	.cfg_on_link_up      	= NULL,
>  };
>  
> -static struct e1000_phy_operations e82_phy_ops_bm = {
> +static const struct e1000_phy_operations e82_phy_ops_bm = {
>  	.acquire_phy		= e1000_get_hw_semaphore_82571,
>  	.check_reset_block	= e1000e_check_reset_block_generic,
>  	.commit_phy		= e1000e_phy_sw_reset,
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index 3e187b0..7744c27 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -376,7 +376,7 @@ struct e1000_info {
>  	u32			max_hw_frame_size;
>  	s32			(*get_variants)(struct e1000_adapter *);
>  	struct e1000_mac_operations *mac_ops;
> -	struct e1000_phy_operations *phy_ops;
> +	const struct e1000_phy_operations *phy_ops;
>  	struct e1000_nvm_operations *nvm_ops;
>  };
>  
> diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
> index ae5d736..631c037 100644
> --- a/drivers/net/e1000e/es2lan.c
> +++ b/drivers/net/e1000e/es2lan.c
> @@ -1383,7 +1383,7 @@ static struct e1000_mac_operations es2_mac_ops = {
>  	.setup_led		= e1000e_setup_led_generic,
>  };
>  
> -static struct e1000_phy_operations es2_phy_ops = {
> +static const struct e1000_phy_operations es2_phy_ops = {
>  	.acquire_phy		= e1000_acquire_phy_80003es2lan,
>  	.check_reset_block	= e1000e_check_reset_block_generic,
>  	.commit_phy	 	= e1000e_phy_sw_reset,
> diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
> index eff3f47..ca9d830 100644
> --- a/drivers/net/e1000e/ich8lan.c
> +++ b/drivers/net/e1000e/ich8lan.c
> @@ -3469,7 +3469,7 @@ static struct e1000_mac_operations ich8_mac_ops = {
>  	/* id_led_init dependent on mac type */
>  };
>  
> -static struct e1000_phy_operations ich8_phy_ops = {
> +static const struct e1000_phy_operations ich8_phy_ops = {
>  	.acquire_phy		= e1000_acquire_swflag_ich8lan,
>  	.check_reset_block	= e1000_check_reset_block_ich8lan,
>  	.commit_phy		= NULL,
> diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
> index f8f5772..a3e64ae 100644
> --- a/drivers/net/igb/e1000_82575.c
> +++ b/drivers/net/igb/e1000_82575.c
> @@ -1409,7 +1409,7 @@ static struct e1000_mac_operations e1000_mac_ops_82575 = {
>  	.get_speed_and_duplex = igb_get_speed_and_duplex_copper,
>  };
>  
> -static struct e1000_phy_operations e1000_phy_ops_82575 = {
> +static const struct e1000_phy_operations e1000_phy_ops_82575 = {
>  	.acquire              = igb_acquire_phy_82575,
>  	.get_cfg_done         = igb_get_cfg_done_82575,
>  	.release              = igb_release_phy_82575,
> diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
> index 119869b..326e0e7 100644
> --- a/drivers/net/igb/e1000_hw.h
> +++ b/drivers/net/igb/e1000_hw.h
> @@ -311,7 +311,7 @@ struct e1000_nvm_operations {
>  struct e1000_info {
>  	s32 (*get_invariants)(struct e1000_hw *);
>  	struct e1000_mac_operations *mac_ops;
> -	struct e1000_phy_operations *phy_ops;
> +	const struct e1000_phy_operations *phy_ops;
>  	struct e1000_nvm_operations *nvm_ops;
>  };
>  
> 
