From: Raanan Avargil <raanan.avargil@intel.com>
Subject: Re: [Intel-wired-lan] e1000e: PHY cann't be initialized correctly on
 some I218 controllers
Date: Thu, 4 Aug 2016 19:18:08 +0300
Message-ID: <1e8f37ec-eda4-eb2d-64d2-e96a7aa71902@intel.com>
References: <579F407E.9090602@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	linux-kernel@vger.kernel.org
To: Denis Turischev <denis.turischev@compulab.co.il>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <579F407E.9090602@compulab.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 8/1/2016 15:28, Denis Turischev wrote:
> There is an error "e1000e: probe of 0000:00:19.0 failed with error -3"
> that can be observed after power-on on some I218 controllers.
> Hardware reset and re-initialization fixes the issue.
>
> Signed-off-by: Denis Turischev <denis.turischev@compulab.co.il>
>
> diff -Nru linux-4.7.orig/drivers/net/ethernet/intel/e1000e/ich8lan.c linux-4.7/drivers/net/ethernet/intel/e1000e/ich8lan.c
> --- linux-4.7.orig/drivers/net/ethernet/intel/e1000e/ich8lan.c	2016-07-24 22:23:50.000000000 +0300
> +++ linux-4.7/drivers/net/ethernet/intel/e1000e/ich8lan.c	2016-08-01 13:59:08.046563095 +0300
> @@ -155,6 +155,7 @@
>   static s32 e1000_disable_ulp_lpt_lp(struct e1000_hw *hw, bool force);
>   static s32 e1000_setup_copper_link_pch_lpt(struct e1000_hw *hw);
>   static s32 e1000_oem_bits_config_ich8lan(struct e1000_hw *hw, bool d0_state);
> +static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw);
>   
>   static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
>   {
> @@ -459,8 +460,12 @@
>   	phy->id = e1000_phy_unknown;
>   
>   	ret_val = e1000_init_phy_workarounds_pchlan(hw);
> -	if (ret_val)
> -		return ret_val;
> +	if (ret_val) {
> +		e1000_reset_hw_ich8lan(hw);
> +		ret_val = e1000_init_phy_workarounds_pchlan(hw);
> +		if (ret_val)
> +			return ret_val;
> +	}
>   
>   	if (phy->id == e1000_phy_unknown)
>   		switch (hw->mac.type) {
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@lists.osuosl.org
> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
>

It is hard to determine what is exactly the problem here and what causes 
the -3 error, but this is not the place to perform hw reset and retry to 
init the phy.
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
