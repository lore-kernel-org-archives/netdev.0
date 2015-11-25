From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v2 04/15] i40e: remove BUG_ON from feature string
 building
Date: Wed, 25 Nov 2015 21:26:58 +0300
Message-ID: <5655FD72.70902@cogentembedded.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:33701 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbbKYS1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 13:27:03 -0500
Received: by lfaz4 with SMTP id z4so70991232lfa.0
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 10:27:00 -0800 (PST)
In-Reply-To: <1448475679-57194-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/25/2015 09:21 PM, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>
>
> There's really no reason to kill the kernel thread just because of a
> little info string. This reworks the code to use snprintf's limiting to
> assure that the string is never too long, and WARN_ON to still put out
> a warning that we might want to look at the feature list length.
>
> Prompted by a recent Linus diatribe.
>
> Change-ID: If52ba5ca1c2344d8bf454a31bbb805eb5d2c5802
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 34 +++++++++++++++--------------
>   1 file changed, 18 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 7715c54..7a4595a 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
[...]
> @@ -10124,42 +10126,42 @@ static void i40e_print_features(struct i40e_pf *pf)
>
>   	buf = string;
>
> -	buf += sprintf(string, "Features: PF-id[%d] ", hw->pf_id);
> +	i += snprintf(&buf[i], REMAIN(i), "Features: PF-id[%d] ", hw->pf_id);
>   #ifdef CONFIG_PCI_IOV
> -	buf += sprintf(buf, "VFs: %d ", pf->num_req_vfs);
> +	i += snprintf(&buf[i], REMAIN(i), "VFs: %d ", pf->num_req_vfs);
>   #endif
> -	buf += sprintf(buf, "VSIs: %d QP: %d RX: %s ",
> -		       pf->hw.func_caps.num_vsis,
> -		       pf->vsi[pf->lan_vsi]->num_queue_pairs,
> -		       pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
> +	i += snprintf(&buf[i], REMAIN(i), "VSIs: %d QP: %d RX: %s ",
> +		      pf->hw.func_caps.num_vsis,
> +		      pf->vsi[pf->lan_vsi]->num_queue_pairs,
> +		      pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
>
>   	if (pf->flags & I40E_FLAG_RSS_ENABLED)
> -		buf += sprintf(buf, "RSS ");
> +		i += snprintf(&buf[i], REMAIN(i), "RSS ");
>   	if (pf->flags & I40E_FLAG_FD_ATR_ENABLED)
> -		buf += sprintf(buf, "FD_ATR ");
> +		i += snprintf(&buf[i], REMAIN(i), "FD_ATR ");
>   	if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
> -		buf += sprintf(buf, "FD_SB ");
> -		buf += sprintf(buf, "NTUPLE ");
> +		i += snprintf(&buf[i], REMAIN(i), "FD_SB ");
> +		i += snprintf(&buf[i], REMAIN(i), "NTUPLE ");
>   	}
>   	if (pf->flags & I40E_FLAG_DCB_CAPABLE)
> -		buf += sprintf(buf, "DCB ");
> +		i += snprintf(&buf[i], REMAIN(i), "DCB ");
>   #if IS_ENABLED(CONFIG_VXLAN)
> -	buf += sprintf(buf, "VxLAN ");
> +	i += snprintf(&buf[i], REMAIN(i), "VxLAN ");
>   #endif
>   	if (pf->flags & I40E_FLAG_PTP)
> -		buf += sprintf(buf, "PTP ");
> +		i += snprintf(&buf[i], REMAIN(i), "PTP ");
>   #ifdef I40E_FCOE
>   	if (pf->flags & I40E_FLAG_FCOE_ENABLED)
> -		buf += sprintf(buf, "FCOE ");
> +		i += snprintf(&buf[i], REMAIN(i), "FCOE ");
>   #endif
>   	if (pf->flags & I40E_FLAG_VEB_MODE_ENABLED)
> -		buf += sprintf(buf, "VEB ");
> +		i += snprintf(&buf[i], REMAIN(i), "VEPA ");

    Not "VEB "?

>   	else
>   		buf += sprintf(buf, "VEPA ");
>
> -	BUG_ON(buf > (string + INFO_STRING_LEN));
>   	dev_info(&pf->pdev->dev, "%s\n", string);
>   	kfree(string);
> +	WARN_ON(i > INFO_STRING_LEN);
>   }
>
>   /**

MBR, Sergei
