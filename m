From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibmveth: Add function to enable live MAC address changes
Date: Thu, 26 Feb 2015 07:08:06 -0600
Message-ID: <54EF1AB6.5010004@linux.vnet.ibm.com>
References: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:52990 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbBZNIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:08:11 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <brking@linux.vnet.ibm.com>;
	Thu, 26 Feb 2015 06:08:10 -0700
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AE21838C8039
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 08:08:08 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22035.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t1QD88X728442842
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 13:08:08 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t1QD87rE032300
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 08:08:08 -0500
In-Reply-To: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2015 06:34 PM, Thomas Falcon wrote:
> @@ -1327,6 +1327,24 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
>  	return ret;
>  }
> 
> +static int ibmveth_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct ibmveth_adapter *adapter = netdev_priv(dev);
> +	struct sockaddr *addr = p;
> +	u64 mac_address;
> +	int rc;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	ether_addr_copy(dev->dev_addr, addr->sa_data);
> +
> +	mac_address = ibmveth_encode_mac_addr(dev->dev_addr);
> +	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);
> +
> +	return rc;

Do you still want to be changing dev->dev_addr if h_change_logical_lan_mac
returns a failure?

-Brian

-- 
Brian King
Power Linux I/O
IBM Linux Technology Center
