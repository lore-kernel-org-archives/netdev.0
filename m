From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: skb header allocation
Date: Wed, 26 Aug 2009 08:01:23 +0200
Message-ID: <4A94CFB3.4020706@linux.vnet.ibm.com>
References: <17cd85320908252004r31874732n9e06921d6eae4ad7@mail.gmail.com> <20090825201514.0dd143ad@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Chris Ross <chris@compilednetworks.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:53144 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761AbZHZGBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 02:01:31 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.1/8.13.1) with ESMTP id n7Q61WMl016873
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 06:01:32 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7Q61WZP2764992
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 08:01:32 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7Q61WtG016126
	for <netdev@vger.kernel.org>; Wed, 26 Aug 2009 08:01:32 +0200
In-Reply-To: <20090825201514.0dd143ad@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it save to change dev->hard_header_len to a value other than ETH_HLEN for
an ethernet device?

I rememeber we run in trouble with some kernel components (netfilter?, I'm
not sure can't remember the details ...) when we did this is the past.

Is this not an issue any more?

Thanks

Stephen Hemminger schrieb:
> On Tue, 25 Aug 2009 22:04:10 -0500
> Chris Ross <chris@compilednetworks.com> wrote:
> 
>> I have a network driver that acts as a Ethernet device and builds up a
>> series of outer headers on skb(s) it receives from upper layers. I am
>> currently using the technique that is in ipip.c to ensure I have
>> enough room to add my header ...
>>
>> if (skb_headroom(skb) < some_value || skb_shared(skb) ||
>>          ((skb_cloned(skb) && !skb_clone_writable(skb, 0))))
>>    {
>>       if ((skb2 = skb_realloc_headroom(skb, some_value)) == NULL)
>>          return -1;
>>
>>       dev_kfree_skb(skb);
>>       skb = skb2;
>>    }
>>
>> Is this the best practice for a high bandwidth scenario?
> 
> Define a value of dev->hard_header_len that adds space for what you need.
> Use skb_cow_head(skb, headroom) before touching skb header.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


