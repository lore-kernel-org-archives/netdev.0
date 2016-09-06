From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v7 1/3] netdevice: Add offload statistics ndo
Date: Tue, 6 Sep 2016 17:46:19 +0200
Message-ID: <20160906154619.GB1972@nanopsycho>
References: <1473095937-27100-1-git-send-email-jiri@resnulli.us>
 <1473095937-27100-2-git-send-email-jiri@resnulli.us>
 <57CEDBE9.1090501@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
        ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36193 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754927AbcIFPqY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 11:46:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id l65so11393238wmf.3
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 08:46:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57CEDBE9.1090501@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 06, 2016 at 05:08:25PM CEST, roopa@cumulusnetworks.com wrote:
>On 9/5/16, 10:18 AM, Jiri Pirko wrote:
>> From: Nogah Frankel <nogahf@mellanox.com>
>>
>> Add a new ndo to return statistics for offloaded operation.
>> Since there can be many different offloaded operation with many
>> stats types, the ndo gets an attribute id by which it knows which
>> stats are wanted. The ndo also gets a void pointer to be cast according
>> to the attribute id.
>>
>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  include/linux/netdevice.h | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 67bb978..2d2c09b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -924,6 +924,14 @@ struct netdev_xdp {
>>   *	3. Update dev->stats asynchronously and atomically, and define
>>   *	   neither operation.
>>   *
>> + * bool (*ndo_has_offload_stats)(int attr_id)
>> + *	Return true if this device supports offload stats of this attr_id.
>> + *
>> + * int (*ndo_get_offload_stats)(int attr_id, const struct net_device *dev,
>> + *	void *attr_data)
>> + *	Get statistics for offload operations by attr_id. Write it into the
>> + *	attr_data pointer.
>> + *
>
>this could have been a single ndo_get_offload_stats like the others.
>and possibly new ndo_get_offload_stats_size.

Size is determined by the attribute.


>Ideally the driver could do the nest.
>But, this can be changed if needed in the future.
>
>>   * int (*ndo_vlan_rx_add_vid)(struct net_device *dev, __be16 proto, u16 vid);
>>   *	If device supports VLAN filtering this function is called when a
>>   *	VLAN id is registered.
>> @@ -1155,6 +1163,10 @@ struct net_device_ops {
>>  
>>  	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
>>  						     struct rtnl_link_stats64 *storage);
>> +	bool			(*ndo_has_offload_stats)(int attr_id);
>> +	int			(*ndo_get_offload_stats)(int attr_id,
>> +							 const struct net_device *dev,
>> +							 void *attr_data);
>>  	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
>>  
>>  	int			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
>
