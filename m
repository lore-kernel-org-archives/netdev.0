From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 02/14] i40e: make prep_for_reset void
Date: Tue, 24 Jun 2014 18:03:59 +0400
Message-ID: <53A9854F.8020405@cogentembedded.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com> <1403570858-13548-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:55531 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbaFXOD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:03:58 -0400
Received: by mail-lb0-f171.google.com with SMTP id s7so510832lbd.30
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:03:56 -0700 (PDT)
In-Reply-To: <1403570858-13548-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/24/2014 04:47 AM, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>

> The return from i40e_prep_for_reset() was being ignored by almost all
> its callers.  The one place it wasn't ignored could have caused a silent
> and confusing failure of the driver to finish a reset.  Since we really
> are doing a rebuild anyway, ignore this last case as well and simply
> make the function a void type.

> Change-ID: Ia4fed7f903d39a6c47c5722625a53e59c3f7ed53
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 17 ++++++-----------
>   1 file changed, 6 insertions(+), 11 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index b167fc2..0a68065 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> @@ -5636,13 +5636,11 @@ static int i40e_prep_for_reset(struct i40e_pf *pf)
>   	/* call shutdown HMC */
>   	if (hw->hmc.hmc_obj) {
>   		ret = i40e_shutdown_lan_hmc(hw);
> -		if (ret) {
> +		if (ret)
>   			dev_warn(&pf->pdev->dev,
>   				 "shutdown_lan_hmc failed: %d\n", ret);
> -			clear_bit(__I40E_RESET_RECOVERY_PENDING, &pf->state);
> -		}
>   	}
> -	return ret;
> +	return;

    *return* at the end of function not needed.

>   }
>
>   /**

WBR, Sergei
