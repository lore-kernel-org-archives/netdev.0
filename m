From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 04/13] i40evf: make messages less dire
Date: Fri, 06 Jun 2014 05:19:17 -0700
Message-ID: <1402057157.3038.8.camel@joe-AO725>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402045462-10304-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0066.hostedemail.com ([216.40.44.66]:54933 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751135AbaFFMT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:19:27 -0400
In-Reply-To: <1402045462-10304-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-06 at 02:04 -0700, Jeff Kirsher wrote:
> Depending on the timing of what the PF driver is doing, it make take a
> few tries before the VF driver is able to communicate with the PF driver
> on init or reset recovery. In order to prevent confusion, make the most
> common messages less scary by lowering them to a less terrifying log
> level and indicate that the driver will retry.
[]
> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
[]
> @@ -1963,7 +1963,7 @@ static void i40evf_init_task(struct work_struct *work)
>  		}
>  		err = i40evf_check_reset_complete(hw);
>  		if (err) {
> -			dev_err(&pdev->dev, "Device is still in reset (%d)\n",
> +			dev_info(&pdev->dev, "Device is still in reset (%d), retrying\n",
>  				err);
>  			goto err;
>  		}
> @@ -1996,7 +1996,7 @@ static void i40evf_init_task(struct work_struct *work)
>  		/* aq msg sent, awaiting reply */
>  		err = i40evf_verify_api_ver(adapter);
>  		if (err) {
> -			dev_err(&pdev->dev, "Unable to verify API version (%d)\n",
> +			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
>  				err);
>  			goto err;
>  		}

trivia:

It'd be nicer to reindent the multi-line statements.

CHECK: Alignment should match open parenthesis
#73: FILE: drivers/net/ethernet/intel/i40evf/i40evf_main.c:1967:
+			dev_info(&pdev->dev, "Device is still in reset (%d), retrying\n",
 				err);

CHECK: Alignment should match open parenthesis
#82: FILE: drivers/net/ethernet/intel/i40evf/i40evf_main.c:2000:
+			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
 				err);
