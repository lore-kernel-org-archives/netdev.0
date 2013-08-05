From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net 1/2] vlan: make vlan_dev_real_dev work over stacked
 vlans
Date: Mon, 05 Aug 2013 10:12:38 +0200
Message-ID: <51FF5E76.1090008@redhat.com>
References: <1375560467-1604-1-git-send-email-nikolay@redhat.com> <51FDB9C7.4090703@redhat.com> <20130805065855.GF22756@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	jhs@mojatatu.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755084Ab3HEIMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 04:12:45 -0400
In-Reply-To: <20130805065855.GF22756@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/05/2013 08:58 AM, Veaceslav Falico wrote:
> On Sun, Aug 04, 2013 at 04:17:43AM +0200, Nikolay Aleksandrov wrote:
>> On 08/03/2013 10:07 PM, Nikolay Aleksandrov wrote:
<snip>
>> I have one question - why not make it possible to call vlan_dev_real_dev()
>> with any device (vlan/non-vlan) and make it return a real device in all
>> cases (e.g. if it's a non-vlan device simply return it) ?
>> In the terms of the code above - simply change:
>> struct net_device *ret = vlan_dev_priv(dev)->real_dev;
>> with
>> struct net_device *ret = dev;
>>
>> This way we'll be able to simplify calls like if (is_vlan_dev(dev)) (or the
>> flag check alternative of this) to just vlan_dev_real_dev(). The old call
>> sites of this function will still work properly.
> 
> I think it'll be a bit harder to understand the callers' code. Now it
> always has the logic "wait, we might be having a vlan here, so lets verify
> if it's really a vlan and if yes - get the real device". However with this
> approach it might look like "we *really* have a vlan here - so lets get the
> real device" (because of the function name - vlan_dev_real_dev) - which is
> wrong. And it doesn't really provide any speed/size improvements - so it's
> kind of useless.
> 
It's not used in fast paths, this suggestion was purely about saving some
lines and indentation levels. And you can still use it the old way if you
prefer it.

> So, unless a better function name can be found (which I can't come up with
> - dev_or_strip_vlan()? dev_devlanitize()? :) ) - I'd stay with the current
>  version. Though, again, I don't have a strong opinion on this.
It's all the same to me as well, I've wasted enough time on these simple
patches so I'd rather see them in (if accepted) than argue about semantics :-)

> 
>>
>> Nik
