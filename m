From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] netxen: only half timeout waited
Date: Tue, 17 Feb 2009 07:33:12 +0000
Message-ID: <20090217073312.GA4677@ff.dom.local>
References: <4999704A.9030004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhananjay@netxen.com, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f167.google.com ([209.85.218.167]:52149 "EHLO
	mail-bw0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZBQHdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 02:33:19 -0500
Received: by bwz11 with SMTP id 11so1840085bwz.13
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 23:33:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4999704A.9030004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-2009 14:55, Roel Kluin wrote:
> Only half the timeout was waited, due to the double increment, and an error
> occurred one too early.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
> index c3b9c83..df3aa08 100644
> --- a/drivers/net/netxen/netxen_nic_niu.c
> +++ b/drivers/net/netxen/netxen_nic_niu.c
> @@ -147,12 +147,11 @@ int netxen_niu_gbe_phy_read(struct netxen_adapter *adapter, long reg,
>  					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
>  					  &status, 4))
>  			return -EIO;
> -		timeout++;
>  	} while ((netxen_get_gb_mii_mgmt_busy(status)
>  		  || netxen_get_gb_mii_mgmt_notvalid(status))
>  		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
>  
> -	if (timeout < NETXEN_NIU_PHY_WAITMAX) {
> +	if (timeout <= NETXEN_NIU_PHY_WAITMAX) {

Roel, very good caches, but IMHO in all such cases changing to
++timeout with 'if (timeout == NETXEN_NIU_PHY_WAITMAX)' where
possible, should be really more readable. At least wrt. next similar
patches.

Thanks,
Jarek P.

>  		if (adapter->hw_read_wx(adapter,
>  					  NETXEN_NIU_GB_MII_MGMT_STATUS(0),
>  					  readval, 4))
> @@ -240,11 +239,10 @@ int netxen_niu_gbe_phy_write(struct netxen_adapter *adapter, long reg,
>  					  NETXEN_NIU_GB_MII_MGMT_INDICATE(0),
>  					  &status, 4))
>  			return -EIO;
> -		timeout++;
>  	} while ((netxen_get_gb_mii_mgmt_busy(status))
>  		 && (timeout++ < NETXEN_NIU_PHY_WAITMAX));
>  
> -	if (timeout < NETXEN_NIU_PHY_WAITMAX)
> +	if (timeout <= NETXEN_NIU_PHY_WAITMAX)
>  		result = 0;
>  	else
>  		result = -EIO;
