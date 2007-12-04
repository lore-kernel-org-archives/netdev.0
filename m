From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPv6][IPsec] fix the address family for xfrm_state_lookup
 in xfrm_input
Date: Tue, 04 Dec 2007 15:23:01 +0900
Message-ID: <4754F245.1070602@miyazawa.org>
References: <20071204142836.a864e30e.kazunori@miyazawa.org> <20071204054935.GA1747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:46535 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbXLDGXQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 01:23:16 -0500
In-Reply-To: <20071204054935.GA1747@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Dec 04, 2007 at 02:28:36PM +0900, Kazunori MIYAZAWA wrote:
>> Hi Herbert, 
>>
>> This is the patch to fix IPv6 IPsec input.
>>
>> Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> 
> Good catch! Thanks.
> 
>> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
>> index 96f42c1..da3c963 100644
>> --- a/net/xfrm/xfrm_input.c
>> +++ b/net/xfrm/xfrm_input.c
>> @@ -136,7 +136,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>>  		if (skb->sp->len == XFRM_MAX_DEPTH)
>>  			goto drop;
>>  
>> -		x = xfrm_state_lookup(daddr, spi, nexthdr, AF_INET);
>> +		x = xfrm_state_lookup(daddr, spi, nexthdr, skb->dst->ops->family);
> 
> I'd prefer to put this in XFRM_SPI_SKB_CB instead because the xfrm
> layer shouldn't really rely on dst->ops structures except on entry
> and exit, like this:
> 
> [IPSEC]: Use the correct family for input state lookup
> 
> When merging the input paths of IPsec I accidentally left a hard-coded
> AF_INET for the state lookup call.  This broke IPv6 obviously.  This
> patch fixes by getting the input callers to specify the family through
> skb->cb.
> 
> Credit goes to Kazunori Miyazawa for diagnosing this and providing an
> initial patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,

It works fine.

Thank you!!

--
Kazunori Miyazawa
