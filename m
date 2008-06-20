From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software
 LRO
Date: Fri, 20 Jun 2008 23:57:20 +0200
Message-ID: <485C27C0.9070005@gmail.com>
References: <485B4ADE.8070102@domat.com.pl> <20080620063706.GA4009@ff.dom.local> <200806201309.35272.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:40928 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbYFTV5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 17:57:37 -0400
Received: by rv-out-0506.google.com with SMTP id k40so5838476rvb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2008 14:57:37 -0700 (PDT)
In-Reply-To: <200806201309.35272.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote, On 06/20/2008 12:09 PM:

> On Friday 20 June 2008, Jarek Poplawski wrote:
> 
>> This patch looks fine to me, but I wonder if, btw., this place can't
>> be optimized a bit, so why can't we simply:
>>
>> 	if (spd_fill_page(spd, f->page, plen, poff, skb))
>> 		goto err;
>>
>> in both cases, since nothing more can't be filled after this?
> 
> Yes, you are right. Here is the patch with your suggestions in place, tested. 
> 
> BTW, I have another trivial fix and a RFC related to tcp splice read that I've 
> sent a while ago. Should I resend them as well? 
> 
> Thanks,
> tavi
> 

> commit b4671a70a6d70cdf11537a5231193271b06a3efa
> Author: Octavian Purdila <opurdila@ixiacom.com>
> Date:   Fri Jun 20 12:49:24 2008 +0300
> 
>     tcp: fix for splice receive when used with software LRO
>     
>     If an skb has nr_frags set to zero but its frag_list is not empty (as
>     it can happen if software LRO is enabled), and a previous
>     tcp_read_sock has consumed the linear part of the skb, then
>     __skb_splice_bits:
>     
>     (a) incorrectly reports an error and
>     
>     (b) forgets to update the offset to account for the linear part
>     
>     Any of the two problems will cause the subsequent __skb_splice_bits
>     call (the one that handles the frag_list skbs) to either skip data,
>     or, if the unadjusted offset is greater then the size of the next skb
>     in the frag_list, make tcp_splice_read loop forever.
>     
>     Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 25fa74d..4262006 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1198,12 +1198,14 @@ static int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
>  

Octavian, since these readability changes later in this thread are quite
substantial, my proposal is to separate them from this bug fix. I'll need
more time to check them, but they are probably rather for net-next, while
the bug fix could probably make to current. If you agree with this try to
resend this once more as a new thread with David in To or Cc (and maybe
re-diff this to more current tree). You can add my ack below if you like.

Thanks,
Jarek P.

Acked-by: Jarek Poplawski <jarkao2@gmail.com>
