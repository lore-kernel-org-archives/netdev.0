From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] bna: fix vlan tag stripping and implement its toggling
Date: Fri, 28 Feb 2014 10:53:14 +0100
Message-ID: <53105C8A.1020908@redhat.com>
References: <1393578674-12658-1-git-send-email-ivecera@redhat.com> <20140228092447.GC2823@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, rmody@brocade.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65083 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbaB1JxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 04:53:19 -0500
In-Reply-To: <20140228092447.GC2823@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 10:24 AM, Jiri Pirko wrote:
>> +int bnad_set_features(struct net_device *dev, netdev_features_t features)
>> +{
>> +	struct bnad *bnad = netdev_priv(dev);
>> +	netdev_features_t changed = features ^ dev->features;
>> +
>> +	if ((changed & NETIF_F_HW_VLAN_CTAG_RX) && netif_running(dev)) {
>                                                     ^^^^^^^^^^^^^^^^^^
> 							   why?
> 	
Because 'bnad->rx_info[0].rx' is assigned during open. But I remembered 
that VLAN stripping is enabled unconditionally during open... need fix 
this yet. Will post v2.

>> +		unsigned long flags;
>> +
>> +		spin_lock_irqsave(&bnad->bna_lock, flags);
>> +
>> +		if (features & NETIF_F_HW_VLAN_CTAG_RX)
>> +			bna_rx_vlan_strip_enable(bnad->rx_info[0].rx);
>> +		else
>> +			bna_rx_vlan_strip_disable(bnad->rx_info[0].rx);
>> +
>> +		spin_unlock_irqrestore(&bnad->bna_lock, flags);
>> +	}
>> +
>> +	return 0;
>> +}
