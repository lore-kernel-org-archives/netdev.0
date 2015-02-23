From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 10/16] i40e: Fix the EMPR interrupt received handling
Date: Mon, 23 Feb 2015 15:45:18 +0300
Message-ID: <54EB20DE.1010508@cogentembedded.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com> <1424661944-1779-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:45854 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBWMpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 07:45:23 -0500
Received: by labge10 with SMTP id ge10so17968192lab.12
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2015 04:45:21 -0800 (PST)
In-Reply-To: <1424661944-1779-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/23/2015 6:25 AM, Jeff Kirsher wrote:

> From: Anjali Singhai Jain <anjali.singhai@intel.com>

> We shouldn't trigger another EMPR when we receive an EMPR event.
> This patch handles EMPR event reception with a different state
> so that we can do the right thing for NVM.

> Change-ID: I9cac70b3658600f016a65beb6fb157e1c1f9adf9
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

[...]

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 2260cc1..0c1c38e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c

> @@ -6179,8 +6179,8 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
>   	}
>
>   	/* re-verify the eeprom if we just had an EMP reset */
> -	if (test_bit(__I40E_EMP_RESET_REQUESTED, &pf->state)) {
> -		clear_bit(__I40E_EMP_RESET_REQUESTED, &pf->state);
> +	if (test_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state)) {
> +		clear_bit(__I40E_EMP_RESET_INTR_RECEIVED, &pf->state);

    Why not use test_and_clear_bit()?

>   		i40e_verify_eeprom(pf);
>   	}

WBR, Sergei
