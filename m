From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/14] ixgbe: Add support for generic Tx checksums
Date: Mon, 04 Apr 2016 21:27:39 -0400 (EDT)
Message-ID: <20160404.212739.417828551756386273.davem@davemloft.net>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1459808097-26409-9-git-send-email-jeffrey.t.kirsher@intel.com>
	<5702EB85.5080307@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, aduyck@mirantis.com,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: sridhar.samudrala@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbcDEB1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 21:27:46 -0400
In-Reply-To: <5702EB85.5080307@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Date: Mon, 04 Apr 2016 15:32:37 -0700

> On 4/4/2016 3:14 PM, Jeff Kirsher wrote:
>> @@ -9190,41 +9148,37 @@ skip_sriov:
>>     #endif
>>   	netdev->features = NETIF_F_SG |
>> -			   NETIF_F_IP_CSUM |
>> -			   NETIF_F_IPV6_CSUM |
>> -			   NETIF_F_HW_VLAN_CTAG_TX |
>> -			   NETIF_F_HW_VLAN_CTAG_RX |
>>   			   NETIF_F_TSO |
>>   			   NETIF_F_TSO6 |
>>   			   NETIF_F_RXHASH |
>> -			   NETIF_F_RXCSUM;
>> -
>> -	netdev->hw_features = netdev->features | NETIF_F_HW_L2FW_DOFFLOAD;
>> +			   NETIF_F_RXCSUM |
>> +			   NETIF_F_HW_CSUM |
>> +			   NETIF_F_SCTP_CRC |
>> +			   NETIF_F_HW_VLAN_CTAG_TX |
>> +			   NETIF_F_HW_VLAN_CTAG_RX;
>>   -	switch (adapter->hw.mac.type) {
>> -	case ixgbe_mac_82599EB:
>> -	case ixgbe_mac_X540:
>> -	case ixgbe_mac_X550:
>> -	case ixgbe_mac_X550EM_x:
>> +	if (hw->mac.type >= ixgbe_mac_82599EB)
>>   		netdev->features |= NETIF_F_SCTP_CRC;
>> -		netdev->hw_features |= NETIF_F_SCTP_CRC |
>> -				       NETIF_F_NTUPLE |
>> -				       NETIF_F_HW_TC;
>> -		break;
>> -	default:
>> -		break;
>> -	}
>>   -	netdev->hw_features |= NETIF_F_RXALL;
>> +	/* copy netdev features into list of user selectable features */
>> +	netdev->hw_features |= netdev->features;
>> +	netdev->hw_features |= NETIF_F_RXALL |
>> +			       NETIF_F_HW_L2FW_DOFFLOAD;
>> +
>> +	if (hw->mac.type >= ixgbe_mac_82599EB)
>> +		netdev->hw_features |= NETIF_F_NTUPLE;
> 
> looks like the cleanup missed moving NETIF_F_HW_TC flag here that
> enables cls_u32 offloads via TC.

Indeed, this is a regression.
