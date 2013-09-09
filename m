From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: Re: [PATCH net] net: fib: fib6_add: fix potential NULL pointer dereference
Date: Mon, 09 Sep 2013 09:26:07 +0300
Message-ID: <522D69FF.9000001@nsn.com>
References: <1378559600-15858-1-git-send-email-dborkman@redhat.com> <20130907193557.GB17248@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:12608 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212Ab3IIFYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 01:24:55 -0400
In-Reply-To: <20130907193557.GB17248@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 10:35 PM, ext Hannes Frederic Sowa wrote:
> On Sat, Sep 07, 2013 at 03:13:20PM +0200, Daniel Borkmann wrote:
>> When the kernel is compiled with CONFIG_IPV6_SUBTREES, and we return
>> with an error in fn = fib6_add_1(), then error codes are encoded into
>> the return pointer e.g. ERR_PTR(-ENOENT). In such an error case, we
>> write the error code into err and jump to out, hence enter the if(err)
>> condition. Now, if CONFIG_IPV6_SUBTREES is enabled, we check for:
>>
>>    if (pn != fn && pn->leaf == rt)
>>      ...
>>    if (pn != fn && !pn->leaf && !(pn->fn_flags & RTN_RTINFO))
>>      ...
>>
>> Since pn is NULL and fn is f.e. ERR_PTR(-ENOENT), then pn != fn
>> evaluates to true and causes a NULL-pointer dereference on further
>> checks on pn. Fix it, by setting both NULL in error case, so that
>> pn != fn already evaluates to false and no further dereference
>> takes place.
>>
>> This was first correctly implemented in 4a287eba2 ("IPv6 routing,
>> NLM_F_* flag support: REPLACE and EXCL flags support, warn about
>> missing CREATE flag"), but the bug got later on introduced by
>> 188c517a0 ("ipv6: return errno pointers consistently for fib6_add_1()").
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Lin Ming <mlin@ss.pku.edu.cn>
>> Cc: Matti Vaittinen <matti.vaittinen@nsn.com>
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Full ACK!
>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
Acked-by: Matti Vaittinen <matti.vaittinen@nsn.com>
