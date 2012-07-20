From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues
 (VMDQ)
Date: Fri, 20 Jul 2012 09:30:47 -0700
Message-ID: <500987B7.2030705@intel.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1> <20120719064258.GA1665@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, davem@davemloft.net, roland@kernel.org,
	netdev@vger.kernel.org, ali@mellanox.com, sean.hefty@intel.com,
	shlomop@mellanox.com, "Ronciak, John" <john.ronciak@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:50101 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab2GTQat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 12:30:49 -0400
In-Reply-To: <20120719064258.GA1665@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 11:42 PM, Jiri Pirko wrote:
> Thu, Jul 19, 2012 at 12:05:44AM CEST, john.r.fastabend@intel.com wrote:
>> This adds support to allow virtual net devices to be created. These
>> devices can be managed independtly of the physical function but
>> use the same physical link.

[...]

>> +
>> +size_t vmdq_getpriv_size(struct net *src_net, struct nlattr *tb[])
>> +{
>> +	struct net_device *lowerdev;
>> +
>> +	if (!tb[IFLA_LINK])
>> +		return -EINVAL;
>> +
>> +	lowerdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
>> +	if (!lowerdev)
>> +		return -ENODEV;
>> +
>> +	return sizeof(netdev_priv(lowerdev));
>> +}
>
> Why exactly do you need to have the priv of same size as lowerdev? I do
> not see you use that anywhere...
>

When we add a child device the hardware/sw may have some private data
it needs to manage this device.

I made an assumption here that the priv space for child devices is the
same as the lowerdev but this might be a bad assumption.

.John
