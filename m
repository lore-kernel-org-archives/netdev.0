From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: ipv6: put host and anycast routes on
 device with address
Date: Sat, 19 Aug 2017 21:53:42 -0700 (PDT)
Message-ID: <20170819.215342.1302284519030634269.davem@davemloft.net>
References: <1502997440-32334-1-git-send-email-dsahern@gmail.com>
        <87wp60lb70.fsf@stressinduktion.org>
        <75e79efe-4a41-7b15-b7bb-8ed0624b72b5@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
        yoshfuji@linux-ipv6.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdHTExn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Aug 2017 00:53:43 -0400
In-Reply-To: <75e79efe-4a41-7b15-b7bb-8ed0624b72b5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 18 Aug 2017 18:05:56 -0600

> On 8/18/17 5:15 PM, Hannes Frederic Sowa wrote:
>> Hello David,
>> 
>> David Ahern <dsahern@gmail.com> writes:
>> 
>>> @@ -2688,15 +2716,9 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
>>>  {
>>>  	u32 tb_id;
>>>  	struct net *net = dev_net(idev->dev);
>>> -	struct net_device *dev = net->loopback_dev;
>>> +	struct net_device *dev = idev->dev;
>>>  	struct rt6_info *rt;
>>>  
>>> -	/* use L3 Master device as loopback for host routes if device
>>> -	 * is enslaved and address is not link local or multicast
>>> -	 */
>>> -	if (!rt6_need_strict(addr))
>>> -		dev = l3mdev_master_dev_rcu(idev->dev) ? : dev;
>>> -
>>>  	rt = ip6_dst_alloc(net, dev, DST_NOCOUNT);
>>>  	if (!rt)
>>>  		return ERR_PTR(-ENOMEM);
>> 
>> I am afraid this change might break Java:
>> 
>> <http://hg.openjdk.java.net/jdk9/jdk9/jdk/file/65464a307408/src/java.base/unix/native/libnet/net_util_md.c#l574>
>> 
>> I am all in for this change, but maybe it might be necessary to mask
>> RTF_LOCAL routes with "lo" somehow.
> 
> That's asinine.

To say the least.

We really should suggest to them a better way to do what they are
trying to do.
