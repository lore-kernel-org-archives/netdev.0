From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [net] net_sched: make dev_trans_start return vlan's real dev
 trans_start
Date: Sat, 03 Aug 2013 21:35:20 +0200
Message-ID: <51FD5B78.6000208@redhat.com>
References: <1375542471-22739-1-git-send-email-nikolay@redhat.com> <20130803170733.GA10218@redhat.com> <20130803.115228.1509916868029010372.davem@davemloft.net> <20130803190918.GA11976@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fubar@us.ibm.com, jhs@mojatatu.com
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840Ab3HCTfZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Aug 2013 15:35:25 -0400
In-Reply-To: <20130803190918.GA11976@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2013 09:09 PM, Veaceslav Falico wrote:
> On Sat, Aug 03, 2013 at 11:52:28AM -0700, David Miller wrote:
>> From: Veaceslav Falico <vfalico@redhat.com>
>> Date: Sat, 3 Aug 2013 19:07:33 +0200
>>
>>> On Sat, Aug 03, 2013 at 05:07:51PM +0200, nikolay@redhat.com wrote:
>>> ...snip...
>>>> +    while (is_vlan_dev(dev))
>>>> +        dev = vlan_dev_real_dev(dev);
>>>
>>> While at it - I've checked a few users (mainly network drivers) of
>>> vlan_dev_real_dev(dev) and they all rely on that the return device
>>> would be the *real* device, but not another vlan.
>>
>> Did you find any cases that want the device under the VLAN,
>> whether it is a non-vlan device or not?
> 
> Not really. All of the cases seem to explicitly call it to get a non-vlan
> device, and not the purely 'underlying' one.
> 
> Another point is that they won't work properly with QinQ... cause the
> majority of callers are searching for their own device. Or bonding, as in
> netxen that Nik mentioned. And they will find yet another vlan device.
> 
> So either QinQ isn't really that used or I'm missing something...
> 
>>
>>> So maybe we should move this while loop to vlan_dev_real_dev()
>>> instead?
>>
>> Perhaps.  As per above, we may also need the one-level demux
>> helper too, something like "vlan_dev_slave(dev)".
> 
> I haven't found any usage for it, tbh. Only the vlan code itself might
> benefit from it, but it already uses the vlan_dev_priv(dev)->real_dev, and
> not the vlan_dev_real_dev(), which is used by drivers.
I agree with this. I also can't find users of the one-level variant, so I
think it'd be safe to go ahead and do it.
Just one question in case that we all agree -
Dave should I queue the patches (vlan change & net_sched's dev_trans_start)
for net-next or net would be fine ?

Thanks,
 Nik
