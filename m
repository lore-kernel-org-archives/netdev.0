From: Chris Mason <clm@fb.com>
Subject: Re: [PATCH net] net: Revert "net: avoid one atomic operation in
 skb_clone()"
Date: Fri, 21 Nov 2014 14:39:34 -0500
Message-ID: <1416598774.24312.9@mail.thefacebook.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	<1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
	<1416589451.8629.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141121180510.GA22112@kria>
	<1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Cc: Sabrina Dubroca <sd@queasysnail.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14075 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915AbaKUTjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:39:46 -0500
In-Reply-To: <1416598161.8629.120.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2014 at 2:29 PM, Eric Dumazet <eric.dumazet@gmail.com> 
wrote:
> On Fri, 2014-11-21 at 19:05 +0100, Sabrina Dubroca wrote:
>>  Hello Eric,
>> 
>>  >
>>  > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>  > index c16615bfb61e..be4c7deed971 100644
>>  > --- a/net/core/skbuff.c
>>  > +++ b/net/core/skbuff.c
>>  > @@ -552,20 +552,13 @@ static void kfree_skbmem(struct sk_buff 
>> *skb)
>>  >  	case SKB_FCLONE_CLONE:
>>  >  		fclones = container_of(skb, struct sk_buff_fclones, skb2);
>>  >
>>  > -		/* Warning : We must perform the atomic_dec_and_test() before
>>  > -		 * setting skb->fclone back to SKB_FCLONE_FREE, otherwise
>>  > -		 * skb_clone() could set clone_ref to 2 before our decrement.
>>  > -		 * Anyway, if we are going to free the structure, no need to
>>  > -		 * rewrite skb->fclone.
>>  > +		/* The clone portion is available for
>>  > +		 * fast-cloning again.
>>  >  		 */
>>  > -		if (atomic_dec_and_test(&fclones->fclone_ref)) {
>>  > +		skb->fclone = SKB_FCLONE_UNAVAILABLE;
>> 
>>  Shouldn't that be SKB_FCLONE_FREE ?
> 
> Absolutely :(
> 
> I'll send a v2, thanks !

v1 made it through the first pass here.  I'll switch to SKB_FCLONE_FREE 
and restart.

-chris
