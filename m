From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 07/13] igb: random code and comments fix
Date: Thu, 04 Apr 2013 18:22:18 +0400
Message-ID: <515D8C9A.8030606@cogentembedded.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com> <1365075480-20183-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	"Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:65501 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761441Ab3DDOXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:23:18 -0400
Received: by mail-lb0-f177.google.com with SMTP id r10so2722552lbi.22
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 07:23:17 -0700 (PDT)
In-Reply-To: <1365075480-20183-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04-04-2013 15:37, Jeff Kirsher wrote:

> From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

> This patch fixes code and comments as identified in the driver.

   It seems you are doing 3 different things in 3 different files in this 
patch... it would be better to split it up.

> Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

> diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
> index a5c7200..5d407f4 100644
> --- a/drivers/net/ethernet/intel/igb/e1000_mac.c
> +++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
> @@ -1007,9 +1007,9 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
>   		 * be asked to delay transmission of packets than asking
>   		 * our link partner to pause transmission of frames.
>   		 */
> -		else if ((hw->fc.requested_mode == e1000_fc_none ||
> -			  hw->fc.requested_mode == e1000_fc_tx_pause) ||
> -			 hw->fc.strict_ieee) {
> +		else if ((hw->fc.requested_mode == e1000_fc_none) ||
> +			 (hw->fc.requested_mode == e1000_fc_tx_pause) ||
> +			 (hw->fc.strict_ieee)) {

    The code was alright bnefore this change, so this isn't really a fix at 
all. Aside of that, () around == are not needed, and yet less around 
'hw->fc.strict_ieee'.

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index fb162ef..8752f4f 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -3859,9 +3859,8 @@ static bool igb_thermal_sensor_event(struct e1000_hw *hw, u32 event)
>   		ctrl_ext = rd32(E1000_CTRL_EXT);
>
>   		if ((hw->phy.media_type == e1000_media_type_copper) &&
> -		    !(ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII)) {
> +		    !(ctrl_ext & E1000_CTRL_EXT_LINK_MODE_SGMII))
>   			ret = !!(thstat & event);
> -		}

    This was checkpatch.pl's message right?

WBR, Sergei
