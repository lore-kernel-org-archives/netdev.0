From: Ben Greear <greearb@candelatech.com>
Subject: Re: [VLAN 02/04]: Fix MAC address handling
Date: Wed, 11 Jul 2007 11:16:48 -0700
Message-ID: <46951E90.6050608@candelatech.com>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain> <20070711173815.18369.24201.sendpatchset@localhost.localdomain> <4695194A.3040908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, xemul@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53715 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756312AbXGKSQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 14:16:56 -0400
In-Reply-To: <4695194A.3040908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> [VLAN]: Fix MAC address handling
>>
>> +static void vlan_sync_address(struct net_device *dev,
>> +			      struct net_device *vlandev)
>> +{
>> +	struct vlan_dev_info *vlan = VLAN_DEV_INFO(vlandev);
>> +
>> +	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
>> +		return;
>> +
>> +	if (compare_ether_addr(vlandev->dev_addr, dev->dev_addr))
>> +		dev_unicast_add(dev, vlandev->dev_addr, ETH_ALEN);
>> +	else
>> +		dev_unicast_delete(dev, vlandev->dev_addr, ETH_ALEN);
>> +
>> +	memcpy(vlan->real_dev_addr, dev->dev_addr, ETH_ALEN);
>> +}
> 
> 
> Unfortunately the one case I didn't test is still wrong :|
> 
> The above synchronization incorrectly removes the address in case
> if was different before and is still different afterwards. This
> patch is fixed and contains a few comments as an added bonus :)

The new patch looks good to me..though this is some tricky code
so I might have missed something...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

