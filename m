From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/2] E1000: Fix ifdown hang in git-2.6.24
Date: Thu, 23 Aug 2007 09:11:01 -0700
Message-ID: <46CDB195.5090303@intel.com>
References: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar <krkumar2@in.ibm.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10564 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752740AbXHWQLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 12:11:06 -0400
In-Reply-To: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> Doing napi_disable twice hangs "ifdown" of the device. e1000_down is the
> common place to call napi_disable.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  e1000_main.c |    4 ----
>  1 files changed, 4 deletions(-)
> 
> diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
> --- org/drivers/net/e1000/e1000_main.c	2007-08-23 13:32:16.000000000 +0530
> +++ new/drivers/net/e1000/e1000_main.c	2007-08-23 13:32:34.000000000 +0530
> @@ -1477,10 +1477,6 @@ e1000_close(struct net_device *netdev)
>  {
>  	struct e1000_adapter *adapter = netdev_priv(netdev);
>  
> -#ifdef CONFIG_E1000_NAPI
> -	napi_disable(&adapter->napi);
> -#endif
> -
>  	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
>  	e1000_down(adapter);
>  	e1000_power_down_phy(adapter);

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>

I pushed this change to akpm for -mm as well in e1000e...

Thanks Krishna,

Auke
