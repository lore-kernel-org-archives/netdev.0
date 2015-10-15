From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 05/17] i40e: Change some messages from info to debug
 only
Date: Thu, 15 Oct 2015 02:54:44 -0700
Message-ID: <1444902884.2718.41.camel@perches.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1444902004-14433-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Neerav Parikh <neerav.parikh@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0066.hostedemail.com ([216.40.44.66]:54642 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752062AbbJOJys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 05:54:48 -0400
In-Reply-To: <1444902004-14433-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-15 at 02:39 -0700, Jeff Kirsher wrote:
> From: Neerav Parikh <neerav.parikh@intel.com>
> 
> There are several error messages that have been printing when there is
> no functional issue. These messages should be available at debug message
> level only.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> @@ -6593,9 +6593,9 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
>  	/* make sure our flow control settings are restored */
>  	ret = i40e_set_fc(&pf->hw, &set_fc_aq_fail, true);
>  	if (ret)
> -		dev_info(&pf->pdev->dev, "set fc fail, err %s aq_err %s\n",
> -			 i40e_stat_str(&pf->hw, ret),
> -			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> +		dev_dbg(&pf->pdev->dev, "setting flow control: ret = %s last_status = %s\n",
> +			i40e_stat_str(&pf->hw, ret),
> +			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
[]
> @@ -10333,10 +10339,9 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	/* get the requested speeds from the fw */
>  	err = i40e_aq_get_phy_capabilities(hw, false, false, &abilities, NULL);
>  	if (err)
> -		dev_info(&pf->pdev->dev,
> -			 "get phy capabilities failed, err %s aq_err %s, advertised speed settings may not be correct\n",
> -			 i40e_stat_str(&pf->hw, err),
> -			 i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
> +		dev_dbg(&pf->pdev->dev, "get requested speeds ret =  %s last_status =  %s\n",
> +			i40e_stat_str(&pf->hw, err),
> +			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
>  	pf->hw.phy.link_info.requested_speeds = abilities.link_speed;
>  
>  	/* get the supported phy types from the fw */


Perhaps these 2 are functional issues and should remain
dev_info or maybe upgraded to notice or err
