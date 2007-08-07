From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH] drivers/net/ibmveth.c: memset fix
Date: Tue, 07 Aug 2007 10:40:16 -0500
Message-ID: <46B89260.8000405@linux.vnet.ibm.com>
References: <200708062217.04361.m.kozlowski@tuxland.pl> <46B78672.9090808@linux.vnet.ibm.com> <46B78814.50508@pobox.com> <200708062344.03443.m.kozlowski@tuxland.pl>
Reply-To: brking@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, santil@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:37018 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbXHGPkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 11:40:51 -0400
In-Reply-To: <200708062344.03443.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski wrote:
>>>> 	Looks like memset() is zeroing wrong nr of bytes.
>>> Good catch, however, I think we can just remove this memset altogether
>>> since the memory gets allocated via kzalloc.
>> Correct, that memset() is superfluous.
> 
> Ok. Then this should do it.

Acked-by: Brian King <brking@linux.vnet.ibm.com>

> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
>  drivers/net/ibmveth.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> --- linux-2.6.23-rc1-mm2-a/drivers/net/ibmveth.c	2007-08-01 08:43:46.000000000 +0200
> +++ linux-2.6.23-rc1-mm2-b/drivers/net/ibmveth.c	2007-08-06 23:32:13.000000000 +0200
> @@ -963,7 +963,7 @@ static int __devinit ibmveth_probe(struc
>  {
>  	int rc, i;
>  	struct net_device *netdev;
> -	struct ibmveth_adapter *adapter = NULL;
> +	struct ibmveth_adapter *adapter;
> 
>  	unsigned char *mac_addr_p;
>  	unsigned int *mcastFilterSize_p;
> @@ -997,7 +997,6 @@ static int __devinit ibmveth_probe(struc
>  	SET_MODULE_OWNER(netdev);
> 
>  	adapter = netdev->priv;
> -	memset(adapter, 0, sizeof(adapter));
>  	dev->dev.driver_data = netdev;
> 
>  	adapter->vdev = dev;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center
