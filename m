From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next v2 11/16] i40e: remove chatty log messages
Date: Fri, 20 Dec 2013 21:18:21 +0300
Message-ID: <52B489ED.3010704@cogentembedded.com>
References: <1387557965-13241-1-git-send-email-jeffrey.t.kirsher@intel.com> <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:44548 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753342Ab3LTRSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 12:18:13 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so1215742lab.37
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 09:18:11 -0800 (PST)
In-Reply-To: <1387557965-13241-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 07:46 PM, Jeff Kirsher wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>

> Don't complain when we disable queues that are already disable, or
> enable them when they're already enabled. This removes a bunch of bogus
> log messages that we see at every VF reset.

> Change-Id: Ia127be572abdccc48a53d8c43f8a07b8bb920de1
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 16 +++-------------
>   1 file changed, 3 insertions(+), 13 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index c0f78bc..38e07e6 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -2988,21 +2988,11 @@ static int i40e_vsi_control_tx(struct i40e_vsi *vsi, bool enable)
>   		} while (j-- && ((tx_reg >> I40E_QTX_ENA_QENA_REQ_SHIFT)
>   			       ^ (tx_reg >> I40E_QTX_ENA_QENA_STAT_SHIFT)) & 1);
>
> -		if (enable) {
> -			/* is STAT set ? */
> -			if ((tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> -				dev_info(&pf->pdev->dev,
> -					 "Tx %d already enabled\n", i);
> +		/* Skip if the queue is already in the requested state */
> +		if (enable && (tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
>   				continue;

    This line seems over-indented now.

> -			}
> -		} else {
> -			/* is !STAT set ? */
> -			if (!(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK)) {
> -				dev_info(&pf->pdev->dev,
> -					 "Tx %d already disabled\n", i);
> +		if (!enable && !(tx_reg & I40E_QTX_ENA_QENA_STAT_MASK))
>   				continue;

    This one too.

WBR, Sergei
