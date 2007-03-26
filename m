From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH/RFC] e1000: Check for hw type before enabling ipv6 TSO
Date: Mon, 26 Mar 2007 16:48:51 -0700
Message-ID: <46085BE3.6040009@intel.com>
References: <1174951189.3347.15.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21560 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933786AbXCZXsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:48:52 -0400
In-Reply-To: <1174951189.3347.15.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> I think the check for hw type is missing in e1000_set_tso()
> before enabling ipv6 TSO.
> 
> e1000_probe() makes sure that NETIF_F_TSO6 is set only if
> hw.mac_type > e1000_82547_rev_2. But this is not done in
> e1000_set_tso() that gets called when trying to enable TSO
> using ethtool.
> 
> I noticed this problem when i tried to do an ipv6 netperf
> test with TSO enabled on 82541 based e1000 card.
> 
> The following patch adds this check to e1000_set_tso()


that looks indeed like an oversight. I'll make sure this is verified and will 
include this patch in my upstream submission to the kernel maintainer if it 
checks out,

thanks for posting!

Auke


> 
> Thanks
> Sridhar
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -351,10 +351,12 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
>  	else
>  		netdev->features &= ~NETIF_F_TSO;
>  
> -	if (data)
> -		netdev->features |= NETIF_F_TSO6;
> -	else
> -		netdev->features &= ~NETIF_F_TSO6;
> +	if (adapter->hw.mac_type > e1000_82547_rev_2) {
> +		if (data)
> +			netdev->features |= NETIF_F_TSO6;
> +		else
> +			netdev->features &= ~NETIF_F_TSO6;
> +	}
>  
>  	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
>  	adapter->tso_force = TRUE;
> 
