From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] ibmveth: Remove duplicate checksum offload setup
 code
Date: Fri, 20 Aug 2010 09:01:43 -0500
Message-ID: <4C6E8AC7.1010606@linux.vnet.ibm.com>
References: <20100818160515.GA29528@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Santiago Leon <santil@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:58862 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab0HTOB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 10:01:59 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7KDh5mn004243
	for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 09:43:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7KE1hd31507434
	for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 10:01:43 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7KE1h60024698
	for <netdev@vger.kernel.org>; Fri, 20 Aug 2010 10:01:43 -0400
In-Reply-To: <20100818160515.GA29528@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches 1-3

Acked-by: Brian King <brking@linux.vnet.ibm.com>

On 08/18/2010 11:05 AM, Robert Jennings wrote:
> Remove code in the device probe function where we set up the checksum
> offload feature and replace it with a call to an existing function that
> is doing the same.  This is done to clean up the driver in preparation
> of adding IPv6 checksum offload support.
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> ---
>  drivers/net/ibmveth.c |   18 +-----------------
>  1 file changed, 1 insertion(+), 17 deletions(-)
> 
> Index: b/drivers/net/ibmveth.c
> ===================================================================
> --- a/drivers/net/ibmveth.c
> +++ b/drivers/net/ibmveth.c
> @@ -1222,10 +1222,8 @@ static const struct net_device_ops ibmve
>  static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
>  {
>  	int rc, i;
> -	long ret;
>  	struct net_device *netdev;
>  	struct ibmveth_adapter *adapter;
> -	unsigned long set_attr, ret_attr;
> 
>  	unsigned char *mac_addr_p;
>  	unsigned int *mcastFilterSize_p;
> @@ -1310,21 +1308,7 @@ static int __devinit ibmveth_probe(struc
> 
>  	ibmveth_debug_printk("registering netdev...\n");
> 
> -	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr);
> -
> -	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
> -	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
> -	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
> -		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
> -
> -		ret = h_illan_attributes(dev->unit_address, 0, set_attr, &ret_attr);
> -
> -		if (ret == H_SUCCESS) {
> -			adapter->rx_csum = 1;
> -			netdev->features |= NETIF_F_IP_CSUM;
> -		} else
> -			ret = h_illan_attributes(dev->unit_address, set_attr, 0, &ret_attr);
> -	}
> +	ibmveth_set_csum_offload(netdev, 1, ibmveth_set_tx_csum_flags);
> 
>  	rc = register_netdev(netdev);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center


