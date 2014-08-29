From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 05/15] i40e: Tell OS link is going down when calling
 set_phy_config
Date: Fri, 29 Aug 2014 21:37:39 +0400
Message-ID: <5400BA63.7030307@cogentembedded.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com> <1409304620-23251-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:56792 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbaH2Rho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 13:37:44 -0400
Received: by mail-lb0-f171.google.com with SMTP id n15so3022078lbi.16
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 10:37:42 -0700 (PDT)
In-Reply-To: <1409304620-23251-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2014 01:30 PM, Jeff Kirsher wrote:

> From: Catherine Sullivan <catherine.sullivan@intel.com>

> Since we don't seem to be getting an LSE telling us link is going down
> during set_phy_config (but we do get an LSE telling us we are coming
> back up), fake one for the OS and tell them link is going down. Also
> do an atomic restart no matter what because there are times the user
> may want to end with link up even if they started with link down (like
> if they accidentally set it to a speed that can't link and are trying to
> fix it).

> Change-ID: I0a642af9c1d0feb67bce741aba1a9c33bd349ed6
> Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 21 ++++++++++++++++++---
>   1 file changed, 18 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index de4ce0e..101be2f 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -559,9 +559,17 @@ static int i40e_set_settings(struct net_device *netdev,
>   		config.eeer = abilities.eeer_val;
>   		config.low_power_ctrl = abilities.d3_lpan;
>
> -		/* If link is up set link and an so changes take effect */
> -		if (hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
> -			config.abilities |= I40E_AQ_PHY_ENABLE_ATOMIC_LINK;
> +		/* set link and an so changes take effect */

    Can't parse this comment, probably a word is missing?

WBR, Sergei
