From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in __skb_flow_get_ports
Date: Fri, 10 Oct 2014 09:50:17 -0700
Message-ID: <54380E49.5050504@redhat.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>		<20141010035840.21428.359.stgit@ahduyck-workstation.home>	 <20141010.004708.1975127853551765914.davem@davemloft.net>	 <5437F072.5060502@redhat.com>	 <063D6719AE5E284EB5DD2968C1650D6D174C858B@AcuExch.aculab.com>	 <5437F7CB.5010101@redhat.com> <1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: alexander.h.duyck@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbaJJQuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 12:50:23 -0400
In-Reply-To: <1412954973.9362.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 08:29 AM, Eric Dumazet wrote:
> On Fri, 2014-10-10 at 08:14 -0700, Alexander Duyck wrote:
>
>> I think you might be coming to this a little late.  The igb and ixgbe
>> drivers had been working this way for a long time.  We did a memcpy to
>> move the headers from the page and into the skb->data at an aligned
>> offset.  In order to determine the length to memcpy we had a function
>> that could walk through the DMA aligned data to get the header length.
>> The function for that was replaced with the __skb_flow_dissect as it was
>> considered a duplication of code with the flow_dissection functions.
>> However that is obviously not the case now that we are hitting these
>> alignment issues.
>>
>> The question I have in all this is do I push forward and make
>> __skb_flow_dissect work with unaligned accesses, or do I back off and
>> put something equivilent to igb/ixgbe_get_headlen functions in the
>> kernel in order to deal with the unaligned accesses as they had no
>> issues with them since they were only concerned with getting the header
>> length and kept all accesses 16b aligned.
>>
> I see nothing wrong dealing with unaligned accesses, as these helpers
> are nop on x86 or CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y arches.

Still it means possibly hurting performance on those platforms that 
don't have it defined.

If I just use get_unaligned that is pretty easy in terms of cleanup for 
the ports and IPv4 addresses, the IPv6 will still be a significant 
hurdle to overcome though.

Thanks,

Alex
