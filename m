From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 17:55:16 +0200
Message-ID: <4C35F4E4.4070606@trash.net>
References: <1278522874.5906.9.camel@edumazet-laptop>	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>	 <1278571587.2543.9.camel@edumazet-laptop>	 <1278581971.2651.10.camel@edumazet-laptop>	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com> <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50296 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239Ab0GHPzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 11:55:16 -0400
In-Reply-To: <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Thu, 2010-07-08 at 16:43 +0100, Ben Hutchings wrote:
>   
>> On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
>>     
>>> When we need to shape traffic with low speeds, we need to disable tso on
>>> network interface :
>>>
>>> ethtool -K eth0.2240 tso off
>>>
>>> It seems vlan interfaces miss the set_tso() ethtool method.
>>> Propagating tso changes from lower device is not always wanted, some
>>> vlans want TSO on, others want TSO off.
>>>       
> [...]
>   
>> I think the vlan driver should also have a netdev notifier to handle
>> feature changes on the underlying device.
>>     
>
> To clarify, I think offload features should be disabled on a vlan device
> if they are later disabled on the underlying device.  Propagating
> changes to enable features, as you say, might not be wanted.

I agree. The VLAN driver should also propagate feature changes
upwards itself.
