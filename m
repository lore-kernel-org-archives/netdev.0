From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Subject: Re: [PATCH 2.6.20-rc5] IPV6: skb is unexpectedly freed.
Date: Thu, 25 Jan 2007 19:36:53 -0800
Message-ID: <45B97755.1030509@ncos.nec.co.jp>
References: <45B6C13E.1050204@ncos.nec.co.jp>	<E1H9ZnX-0001z5-00@gondolin.me.apana.org.au>	<20070124.133725.07735362.yoshfuji@linux-ipv6.org> <20070123.204008.59666972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nakagawa.msy@ncos.nec.co.jp, mhuth@mvista.com,
	netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:19499 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030730AbXAZDg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 22:36:59 -0500
In-Reply-To: <20070123.204008.59666972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David, Yoshifuji-san, Herbert,

I appreciate your feedback.

I made an another patch that simply replaced __kfree_skb() in exit path with
kfree_skb(). I tested it overnight with a chat benchmark tool and
my test program, which can reproduce the original problem.

As a result, I didn't see any problem.
(For example, neither oops nor memory leak happened.)

I will post the patch a few moments later. Please take a look at it.

Thanks,
Masa

David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Wed, 24 Jan 2007 13:37:25 +0900 (JST)
>
>   
>> In article <E1H9ZnX-0001z5-00@gondolin.me.apana.org.au> (at Wed, 24 Jan 2007 15:31:47 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:
>>
>>     
>>> Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp> wrote:
>>>       
>>>> I suggest to use kfree_skb() instead of __kfree_skb().
>>>>         
>>> I agree.  In fact please do it for all paths in that function, i.e.,
>>> just change __kfree_skb to kfree_skb rather than adding a special case
>>> for this path.
>>>       
>> I do think so, too.
>>     
>
> So do I, but initially I want to push his basic patch in
> so that I can push the same exact thing into -stable to
> fix this bug.
>
> So if you make the subsequent change, please make it relative
> to the original patch.
>
> Thank you.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>   
