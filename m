From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ibmveth: Add function to enable live MAC address changes
Date: Thu, 26 Feb 2015 16:55:12 +0100
Message-ID: <20150226155512.GG1973@nanopsycho.lan>
References: <1424910864-32266-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <54EF1AB6.5010004@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33820 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbbBZPzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:55:17 -0500
Received: by wghn12 with SMTP id n12so12198923wgh.1
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:55:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54EF1AB6.5010004@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 02:08:06PM CET, brking@linux.vnet.ibm.com wrote:
>On 02/25/2015 06:34 PM, Thomas Falcon wrote:
>> @@ -1327,6 +1327,24 @@ static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
>>  	return ret;
>>  }
>> 
>> +static int ibmveth_set_mac_addr(struct net_device *dev, void *p)
>> +{
>> +	struct ibmveth_adapter *adapter = netdev_priv(dev);
>> +	struct sockaddr *addr = p;
>> +	u64 mac_address;
>> +	int rc;
>> +
>> +	if (!is_valid_ether_addr(addr->sa_data))
>> +		return -EADDRNOTAVAIL;
>> +
>> +	ether_addr_copy(dev->dev_addr, addr->sa_data);
>> +
>> +	mac_address = ibmveth_encode_mac_addr(dev->dev_addr);
>> +	rc = h_change_logical_lan_mac(adapter->vdev->unit_address, mac_address);
>> +
>> +	return rc;
>
>Do you still want to be changing dev->dev_addr if h_change_logical_lan_mac
>returns a failure?

That should not be done. dev_addr should be in sync with real hw addr.
