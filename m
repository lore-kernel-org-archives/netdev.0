From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [PATCH] e1000: remove unused variables
Date: Wed, 26 Nov 2014 21:59:28 -0800 (PST)
Message-ID: <alpine.NEB.2.11.1411262157110.1481@chris.i8u.org>
References: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417065728-5592-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm pretty sure those double reads are there for a reason, so most of
this I'm going to have to check on Monday. We have a long holiday
weekend here in the US.

I'm not sure why you're bothering with an old driver like this, but if
you haven't actually tried this on all the hardware it pertains to, I'm
going want to NAK this.

I should do this from my todd.fujinaka@intel.com account but it's 10PM
on the first day of a long holiday weekend.

On Thu, 27 Nov 2014, Sudip Mukherjee wrote:

> these variables were only being assigned some values, but were never
> used.
>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
> drivers/net/ethernet/intel/e1000/e1000_hw.c   | 142 ++++++++++++--------------
> drivers/net/ethernet/intel/e1000/e1000_main.c |   3 -
> 2 files changed, 66 insertions(+), 79 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
> index 45c8c864..7812f59 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
> @@ -154,7 +154,6 @@ static s32 e1000_set_phy_type(struct e1000_hw *hw)
>  */
> static void e1000_phy_init_script(struct e1000_hw *hw)
> {
> -	u32 ret_val;
> 	u16 phy_saved_data;
>
> 	if (hw->phy_init_script) {
> @@ -163,7 +162,7 @@ static void e1000_phy_init_script(struct e1000_hw *hw)
> 		/* Save off the current value of register 0x2F5B to be restored
> 		 * at the end of this routine.
> 		 */
> -		ret_val = e1000_read_phy_reg(hw, 0x2F5B, &phy_saved_data);
> +		e1000_read_phy_reg(hw, 0x2F5B, &phy_saved_data);
>
> 		/* Disabled the PHY transmitter */
> 		e1000_write_phy_reg(hw, 0x2F5B, 0x0003);
> @@ -402,7 +401,6 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
> {
> 	u32 ctrl;
> 	u32 ctrl_ext;
> -	u32 icr;
> 	u32 manc;
> 	u32 led_ctrl;
> 	s32 ret_val;
> @@ -527,7 +525,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
> 	ew32(IMC, 0xffffffff);
>
> 	/* Clear any pending interrupt events. */
> -	icr = er32(ICR);
> +	er32(ICR);
>
> 	/* If MWI was previously enabled, reenable it. */
> 	if (hw->mac_type == e1000_82542_rev2_0) {
> @@ -2396,16 +2394,13 @@ static s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
>  */
> s32 e1000_check_for_link(struct e1000_hw *hw)
> {
> -	u32 rxcw = 0;
> -	u32 ctrl;
> 	u32 status;
> 	u32 rctl;
> 	u32 icr;
> -	u32 signal = 0;
> 	s32 ret_val;
> 	u16 phy_data;
>
> -	ctrl = er32(CTRL);
> +	er32(CTRL);
> 	status = er32(STATUS);
>
> 	/* On adapters with a MAC newer than 82544, SW Definable pin 1 will be
> @@ -2414,12 +2409,9 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
> 	 */
> 	if ((hw->media_type == e1000_media_type_fiber) ||
> 	    (hw->media_type == e1000_media_type_internal_serdes)) {
> -		rxcw = er32(RXCW);
> +		er32(RXCW);
>
> 		if (hw->media_type == e1000_media_type_fiber) {
> -			signal =
> -			    (hw->mac_type >
> -			     e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
> 			if (status & E1000_STATUS_LU)
> 				hw->get_link_status = false;
> 		}
> @@ -4698,78 +4690,76 @@ s32 e1000_led_off(struct e1000_hw *hw)
>  */
> static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
> {
> -	volatile u32 temp;
> -
> -	temp = er32(CRCERRS);
> -	temp = er32(SYMERRS);
> -	temp = er32(MPC);
> -	temp = er32(SCC);
> -	temp = er32(ECOL);
> -	temp = er32(MCC);
> -	temp = er32(LATECOL);
> -	temp = er32(COLC);
> -	temp = er32(DC);
> -	temp = er32(SEC);
> -	temp = er32(RLEC);
> -	temp = er32(XONRXC);
> -	temp = er32(XONTXC);
> -	temp = er32(XOFFRXC);
> -	temp = er32(XOFFTXC);
> -	temp = er32(FCRUC);
> -
> -	temp = er32(PRC64);
> -	temp = er32(PRC127);
> -	temp = er32(PRC255);
> -	temp = er32(PRC511);
> -	temp = er32(PRC1023);
> -	temp = er32(PRC1522);
> -
> -	temp = er32(GPRC);
> -	temp = er32(BPRC);
> -	temp = er32(MPRC);
> -	temp = er32(GPTC);
> -	temp = er32(GORCL);
> -	temp = er32(GORCH);
> -	temp = er32(GOTCL);
> -	temp = er32(GOTCH);
> -	temp = er32(RNBC);
> -	temp = er32(RUC);
> -	temp = er32(RFC);
> -	temp = er32(ROC);
> -	temp = er32(RJC);
> -	temp = er32(TORL);
> -	temp = er32(TORH);
> -	temp = er32(TOTL);
> -	temp = er32(TOTH);
> -	temp = er32(TPR);
> -	temp = er32(TPT);
> -
> -	temp = er32(PTC64);
> -	temp = er32(PTC127);
> -	temp = er32(PTC255);
> -	temp = er32(PTC511);
> -	temp = er32(PTC1023);
> -	temp = er32(PTC1522);
> -
> -	temp = er32(MPTC);
> -	temp = er32(BPTC);
> +	er32(CRCERRS);
> +	er32(SYMERRS);
> +	er32(MPC);
> +	er32(SCC);
> +	er32(ECOL);
> +	er32(MCC);
> +	er32(LATECOL);
> +	er32(COLC);
> +	er32(DC);
> +	er32(SEC);
> +	er32(RLEC);
> +	er32(XONRXC);
> +	er32(XONTXC);
> +	er32(XOFFRXC);
> +	er32(XOFFTXC);
> +	er32(FCRUC);
> +
> +	er32(PRC64);
> +	er32(PRC127);
> +	er32(PRC255);
> +	er32(PRC511);
> +	er32(PRC1023);
> +	er32(PRC1522);
> +
> +	er32(GPRC);
> +	er32(BPRC);
> +	er32(MPRC);
> +	er32(GPTC);
> +	er32(GORCL);
> +	er32(GORCH);
> +	er32(GOTCL);
> +	er32(GOTCH);
> +	er32(RNBC);
> +	er32(RUC);
> +	er32(RFC);
> +	er32(ROC);
> +	er32(RJC);
> +	er32(TORL);
> +	er32(TORH);
> +	er32(TOTL);
> +	er32(TOTH);
> +	er32(TPR);
> +	er32(TPT);
> +
> +	er32(PTC64);
> +	er32(PTC127);
> +	er32(PTC255);
> +	er32(PTC511);
> +	er32(PTC1023);
> +	er32(PTC1522);
> +
> +	er32(MPTC);
> +	er32(BPTC);
>
> 	if (hw->mac_type < e1000_82543)
> 		return;
>
> -	temp = er32(ALGNERRC);
> -	temp = er32(RXERRC);
> -	temp = er32(TNCRS);
> -	temp = er32(CEXTERR);
> -	temp = er32(TSCTC);
> -	temp = er32(TSCTFC);
> +	er32(ALGNERRC);
> +	er32(RXERRC);
> +	er32(TNCRS);
> +	er32(CEXTERR);
> +	er32(TSCTC);
> +	er32(TSCTFC);
>
> 	if (hw->mac_type <= e1000_82544)
> 		return;
>
> -	temp = er32(MGTPRC);
> -	temp = er32(MGTPDC);
> -	temp = er32(MGTPTC);
> +	er32(MGTPRC);
> +	er32(MGTPDC);
> +	er32(MGTPTC);
> }
>
> /**
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 24f3986..a70ea46 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -2443,7 +2443,6 @@ static void e1000_watchdog(struct work_struct *work)
> 	if (link) {
> 		if (!netif_carrier_ok(netdev)) {
> 			u32 ctrl;
> -			bool txb2b = true;
> 			/* update snapshot of PHY registers on LSC */
> 			e1000_get_speed_and_duplex(hw,
> 						   &adapter->link_speed,
> @@ -2465,11 +2464,9 @@ static void e1000_watchdog(struct work_struct *work)
> 			adapter->tx_timeout_factor = 1;
> 			switch (adapter->link_speed) {
> 			case SPEED_10:
> -				txb2b = false;
> 				adapter->tx_timeout_factor = 16;
> 				break;
> 			case SPEED_100:
> -				txb2b = false;
> 				/* maybe add some timeout factor ? */
> 				break;
> 			}
>

-- 
Hisashi T Fujinaka - htodd@twofifty.com
BSEE + BSChem + BAEnglish + MSCS + $2.50 = coffee
