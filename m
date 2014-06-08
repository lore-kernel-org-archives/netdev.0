From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/15] i40e/i40evf: remove chatty reset messages
Date: Sun, 08 Jun 2014 10:34:19 -0700
Message-ID: <1402248859.6328.13.camel@joe-AO725>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402238037-20661-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0134.hostedemail.com ([216.40.44.134]:55649 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753659AbaFHReX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 13:34:23 -0400
In-Reply-To: <1402238037-20661-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-08 at 07:33 -0700, Jeff Kirsher wrote:
> Because some of these message are inside if statements, we have to
> rejigger the brackets at the same time to keep our coding style
> consistent.

trivia:

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
[]
> @@ -1503,12 +1500,10 @@ static void i40evf_reset_task(struct work_struct *work)
>  	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
>  		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
>  			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
> -		if (rstat_val == I40E_VFR_VFACTIVE) {
> -			dev_info(&adapter->pdev->dev, "Reset complete, reinitializing\n");
> +		if (rstat_val == I40E_VFR_VFACTIVE)
>  			break;
> -		} else {
> +		else
>  			msleep(I40EVF_RESET_WAIT_MS);
> -		}
>  	}
>  	if (i == I40EVF_RESET_WAIT_COUNT) {
>  		/* reset never finished */

Unnecessary else, maybe simpler as

 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
		if (rstat_val == I40E_VFR_VFACTIVE)
			break;
		msleep(I40EVF_RESET_WAIT_MS);
	}
