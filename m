From: David Miller <davem@davemloft.net>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 01:42:57 -0500 (EST)
Message-ID: <20150305.014257.974664546228241067.davem@davemloft.net>
References: <54F7B76E.4040902@gmail.com>
	<20150305.000015.1427044514000703740.davem@davemloft.net>
	<CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, davidch@broadcom.com,
	simon.horman@netronome.com, dev@openvswitch.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbbCEGnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 01:43:01 -0500
In-Reply-To: <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 4 Mar 2015 21:20:41 -0800

> On Wed, Mar 4, 2015 at 9:00 PM, David Miller <davem@davemloft.net> wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Wed, 04 Mar 2015 17:54:54 -0800
>>
>>> I think a set operation _is_ necessary for OVS and other
>>> applications that run in user space.
>>
>> It's necessary for the kernel to internally manage the chip
>> flow resources.
>>
>> Full stop.
>>
>> It's not being exported to userspace.  That is exactly the kind
>> of open ended, outside the model, crap we're trying to avoid
>> by putting everything into the kernel where we have consistent
>> mechanisms, well understood behaviors, and rules.
> 
> David,
> 
> Just to make sure everyone is on the same page... this discussion has
> been about where the policy of offload is implemented, not just who is
> actually sending config bits to the device. The question is who gets
> to decide how to best divvy up the finite resources of the device and
> network amongst various requestors. Is this what you're referring to?

I'm talking about only the kernel being able to make ->set() calls
through the flow manager API to the device.

Resource control is the kernel's job.

You cannot delegate this crap between ipv4 routing in the kernel,
L2 bridging in the kernel, and some user space crap.  It's simply
not going to happen.

All of the delegation of the hardware resource must occur in the
kernel.  Because only the kernel has a full view of all of the
resources and how each and every subsystem needs to use it.
