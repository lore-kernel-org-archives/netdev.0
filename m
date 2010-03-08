From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()	checks
Date: Mon, 08 Mar 2010 08:56:47 -0800
Message-ID: <4B952C4F.8000504@intel.com>
References: <20100227001954.32474.62766.stgit@localhost.localdomain> <20100227.032725.158512690.davem@davemloft.net> <20100227155245.GB3176@gondor.apana.org.au> <4B92ACB6.1090909@intel.com> <20100307014324.GA19589@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4926 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab0CHQ4s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 11:56:48 -0500
In-Reply-To: <20100307014324.GA19589@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Mar 06, 2010 at 11:27:50AM -0800, John Fastabend wrote:
>   
>> It looks like dev_gso_segment() could be used to "Verify header  
>> integrity only" according to the comment?  If this is true I think the  
>> logic should probably be
>>
>> 		if (netif_needs_gso(dev, skb)) {
>> 			if (unlikely(dev_gso_segment(skb)))
>> 				goto out_kfree_skb;
>> 			if (skb->next)
>> 				goto gso;
>> 		} 		do your thing
>>
>> 		
>>
>> That way we linearize the skb if necessary in the case were  
>> dev_gso_segment() only verifies the header and does not return a list of  
>> segments.
>>     
>
> If we needed to linearise the skb then dev_gso_segment should
> perform the segmentation.  Is there a case where it doesn't?
>
> Cheers,
Nope as far as I can tell all cases are covered my concerns were 
unfounded.  Thanks for the review, I'll get this updated and resent.

-John.
