From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 06/17] i40e: Convert CEE App TLV selector to IEEE
 selector
Date: Tue, 13 Oct 2015 16:42:56 +0300
Message-ID: <561D0A60.6030605@cogentembedded.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1444715598-20970-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Bowers <gregory.j.bowers@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33124 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbbJMNm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 09:42:59 -0400
Received: by lbbk10 with SMTP id k10so20661387lbb.0
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 06:42:57 -0700 (PDT)
In-Reply-To: <1444715598-20970-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/13/2015 8:53 AM, Jeff Kirsher wrote:

> From: Greg Bowers <gregory.j.bowers@intel.com>
>
> Changes the parsing of CEE App TLVs to fill in the App selector in struct
> i40e_dcbx_config with the IEEE App selector so the caller doesn't have to
> consider whether the App came from a CEE or IEEE DCBX negotiation.
>
> Change-ID: Ia7d9d664cde04d2ebcc9822fd22e4929c6edab3a
> Signed-off-by: Greg Bowers <gregory.j.bowers@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_dcb.c  | 16 ++++++++++++----
>   drivers/net/ethernet/intel/i40e/i40e_type.h |  2 ++
>   2 files changed, 14 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.c b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
> index 251a841..2691277 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_dcb.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.c
[...]
> @@ -397,9 +397,17 @@ static void i40e_parse_cee_app_tlv(struct i40e_cee_feat_tlv *tlv,
>   				break;
>   		}
>   		dcbcfg->app[i].priority = up;
> -		/* Get Selector from lower 2 bits */
> -		dcbcfg->app[i].selector = (app->upper_oui_sel &
> -					   I40E_CEE_APP_SELECTOR_MASK);
> +
> +		/* Get Selector from lower 2 bits, and convert to IEEE */
> +		selector = (app->upper_oui_sel & I40E_CEE_APP_SELECTOR_MASK);
> +		if (selector == I40E_CEE_APP_SEL_ETHTYPE)
> +			dcbcfg->app[i].selector = I40E_APP_SEL_ETHTYPE;
> +		else if (selector == I40E_CEE_APP_SEL_TCPIP)
> +			dcbcfg->app[i].selector = I40E_APP_SEL_TCPIP;
> +		else
> +			/* Keep selector as it is for unknown types */
> +			dcbcfg->app[i].selector = selector;

    The above is asking to be a *switch* statement.

[...]

MBR, Sergei
