From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Fri, 11 Apr 2014 09:17:28 -0700
Message-ID: <53481598.7050803@candelatech.com>
References: <20140407142334.GA28814@gondor.apana.org.au> <53442868.3090701@candelatech.com> <20140408172349.GA7147@gondor.apana.org.au> <20140410.214023.849284639345029049.davem@davemloft.net> <20140411015906.GB31251@gondor.apana.org.au> <1397182170.16584.75.camel@edumazet-glaptop2.roam.corp.google.com> <20140411021300.GA31748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46640 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759746AbaDKQRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 12:17:35 -0400
In-Reply-To: <20140411021300.GA31748@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/10/2014 07:13 PM, Herbert Xu wrote:
> On Thu, Apr 10, 2014 at 07:09:30PM -0700, Eric Dumazet wrote:
>> On Fri, 2014-04-11 at 09:59 +0800, Herbert Xu wrote:
>>> On Thu, Apr 10, 2014 at 09:40:23PM -0400, David Miller wrote:
>>>> From: Herbert Xu <herbert@gondor.apana.org.au>
>>>> Date: Wed, 9 Apr 2014 01:23:49 +0800
>>>>
>>>>> On Tue, Apr 08, 2014 at 09:48:40AM -0700, Ben Greear wrote:
>>>>>>
>>>>>> At least for ARPs, maybe we could inspect the packet and only
>>>>>> deliver to interfaces configured with the MAC that is being
>>>>>> ARPed for (or ones that are in promisc)?
>>>>>
>>>>> Yes this would definitely be a great optimisation.
>>>>
>>>> Yes and you can use the direct rather than the workqueue path.
>>>
>>> This would be a worthy optimisation for bridge.c too.  In fact,
>>> I wonder if it would be possible to share some of the broadcast/
>>> multicast logic between macvlan and bridge.
>>
>> But many ARP messages are broadcasted, particularly when you restart
>> an hypervisor with thousand of macvlan. This is the moment we have
>> this horrible quadratic behavior in macvlan.
>>
>> I do not understand the idea...
>>
>> ARP filter would require to inspect the queried IPv4 address, and
>> macvlan do not currently have a list of IPv4 addresses per port.
> 
> Indeed.  Thanks for snapping us out of our collective daydream :)

arp-filter can already do this, so you could just re-use that
behaviour, I think?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
