From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next 01/12] i40e: only warn once of PTP nonsupport in 100Mbit
 speed
Date: Sat, 15 Nov 2014 13:20:58 -0800
Message-ID: <5467C3BA.6090003@gmail.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com> <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	joe@perches.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:47121 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604AbaKOVVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2014 16:21:00 -0500
Received: by mail-oi0-f52.google.com with SMTP id h136so121779oig.25
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2014 13:21:00 -0800 (PST)
In-Reply-To: <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/11/2014 22:08, Jeff Kirsher a =E9crit :
> From: Shannon Nelson <shannon.nelson@intel.com>
>
> Only warn once that PTP is not supported when linked at 100Mbit.
>
> Yes, using a static this way means that this once-only message is not
> port specific, but once only for the life of the driver, regardless o=
f
> the number of ports.  That should be plenty.
>
> Change-ID: Ie6476530056df408452e195ef06afd4f57caa4b2
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_ptp.c | 12 +++++++++---
>   1 file changed, 9 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net=
/ethernet/intel/i40e/i40e_ptp.c
> index 537b621..f9151037 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> @@ -382,11 +382,17 @@ void i40e_ptp_set_increment(struct i40e_pf *pf)
>   		incval =3D I40E_PTP_1GB_INCVAL;
>   		break;
>   	case I40E_LINK_SPEED_100MB:
> -		dev_warn(&pf->pdev->dev,
> -			 "%s: 1588 functionality is not supported at 100 Mbps. Stopping t=
he PHC.\n",
> -			 __func__);
> +	{
> +		static int warn_once;
> +
> +		if (!warn_once) {
> +			dev_warn(&pf->pdev->dev,
> +				 "1588 functionality is not supported at 100 Mbps. Stopping the =
PHC.\n");
> +			warn_once++;
> +		}

I am sure Joe could come up with dev_warn_once() and others pretty=20
easily. As a temporary change you could use pr_warn_once("%s: ...\n",=20
dev_name(&pf->pdev->dev) which is almost identical?

>   		incval =3D 0;
>   		break;
> +	}
>   	case I40E_LINK_SPEED_40GB:
>   	default:
>   		incval =3D I40E_PTP_40GB_INCVAL;
>
