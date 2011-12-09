From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 2/6] net: make vlan ndo_vlan_rx_[add/kill]_vid
 return error value
Date: Fri, 9 Dec 2011 11:41:40 +0100
Message-ID: <20111209104139.GA2193@minipsycho.brq.redhat.com>
References: <1323353480-1900-1-git-send-email-jpirko@redhat.com>
 <1323353480-1900-3-git-send-email-jpirko@redhat.com>
 <87iplqfgcz.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab1LIKlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 05:41:44 -0500
Content-Disposition: inline
In-Reply-To: <87iplqfgcz.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 09, 2011 at 06:45:16AM CET, rusty@rustcorp.com.au wrote:
>On Thu,  8 Dec 2011 15:11:16 +0100, Jiri Pirko <jpirko@redhat.com> wrote:
>> Let caller know the result of adding/removing vlan id to/from vlan
>> filter.
>> 
>> In some drivers I make those functions to just return 0. But in those
>> where there is able to see if hw setup went correctly, return value is
>> set appropriately.
>...
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 5a96172..609c51f 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -855,7 +855,7 @@ static void virtnet_set_rx_mode(struct net_device *dev)
>>  	kfree(buf);
>>  }
>>  
>> -static void virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
>> +static int virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
>>  {
>>  	struct virtnet_info *vi = netdev_priv(dev);
>>  	struct scatterlist sg;
>> @@ -865,9 +865,10 @@ static void virtnet_vlan_rx_add_vid(struct net_device *dev, u16 vid)
>>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
>>  				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, 1, 0))
>>  		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
>> +	return 0;
>>  }
>>  
>> -static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>> +static int virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>>  {
>>  	struct virtnet_info *vi = netdev_priv(dev);
>>  	struct scatterlist sg;
>> @@ -877,6 +878,7 @@ static void virtnet_vlan_rx_kill_vid(struct net_device *dev, u16 vid)
>>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
>>  				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, 1, 0))
>>  		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
>> +	return 0;
>>  }
>
>Hmm, see that virtnet_send_command?  That's what you're after.  You
>could even replace the dev_warn(), if you're doing something more useful
>with the result.

I was not sure what value to return here so I let that be as it was.
Feel free to post follow-up.

Thanks

Jirka

>
>Thanks,
>Rusty.
