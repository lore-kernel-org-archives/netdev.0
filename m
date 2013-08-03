From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 03 Aug 2013 20:19:10 +0200
Message-ID: <51FD499E.70104@redhat.com>
References: <1375542471-22739-1-git-send-email-nikolay@redhat.com> <20130803170733.GA10218@redhat.com> <51FD4864.6060009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	jhs@mojatatu.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752385Ab3HCSTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 14:19:17 -0400
In-Reply-To: <51FD4864.6060009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 08:13 PM, Nikolay Aleksandrov wrote:
> On 08/03/2013 07:07 PM, Veaceslav Falico wrote:
>> On Sat, Aug 03, 2013 at 05:07:51PM +0200, nikolay@redhat.com wrote:
>> ...snip...
>>> +    while (is_vlan_dev(dev))
>>> +        dev = vlan_dev_real_dev(dev);
>>
>> While at it - I've checked a few users (mainly network drivers) of
>> vlan_dev_real_dev(dev) and they all rely on that the return device would be
>> the *real* device, but not another vlan.
>>
>> So maybe we should move this while loop to vlan_dev_real_dev() instead?
<snip>
> Not really, there're users that rely to get only 1 level of real_dev (e.g.
> netxen ip config which expects a configuration like vlan -> bond -> netxen,
> and it needs to go from vlan to bond only) which will be broken, there're
Scratch this part, I need to get some sleep :-)


> also many non-ethernet users which may rely on similar behaviour.
> Most of the network drivers don't expect a *real* device, they check if the
> returned device is one of their own after using that function.
> I'd suggest using a helper that uses vlan_dev_real_dev so we will have both
> without breaking anything.
> 
> Nik
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
