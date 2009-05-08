From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH]ipv6:use ipv6_addr_type instead of __ipv6_addr_type
Date: Fri, 08 May 2009 16:13:33 +0800
Message-ID: <4A03E9AD.3080105@cn.fujitsu.com>
References: <4A02921A.1090200@cn.fujitsu.com>	<20090507.145931.179746218.davem@davemloft.net>	<4A038853.4020205@cn.fujitsu.com> <20090508.004420.22402966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52834 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754501AbZEHIMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 04:12:33 -0400
In-Reply-To: <20090508.004420.22402966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Fri, 08 May 2009 09:18:11 +0800
> 
>> David Miller wrote:
>>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>>> Date: Thu, 07 May 2009 15:47:38 +0800
>>>
>>>> Although the function of these two functions are the same,we should use the
>>>> encapsulation function of __ipv6_addr_type
>>>>
>>>> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>
>>> Are you sure?  ipv6_addr_type() masks out the upper 16-bits
>>> of __ipv6_addr_type()'s return value, which is the scope.
>>>
>>> I'm not convinced that is what we want to do here.
>> My advice here is that the function which has __ maybe shouldn't be directly used.
> 
> You're using vague terms like "advice" and "maybe" and this
> only decreases my confidence in your change.

Yes,I said maybe because I judge this change by search the code.There are many
places that use ipv6_addr_type() but only three places out of ipv6.h use
__ipv6_addr_type().Now, there are two methods can  to do the right things,
one is ipv6_addr_type(),another is __ipv6_addr_type().There's no doult that
These three places can be converted to use ipv6_addr_type().I said converted
because it's not just change __ipv6_addr_type() to ipv6_addr_type().

Of course you can say that this dose not imply that we *should* do this change.
I agree,so I just said this is a advice:)

> 
> You're also not addressing my questions at all.
> 
> Two "_" characters at the beginning of the function's name says
> nothing about whether these call sites want the scope bits present in
> the return value they receive.

I used to think Two "_" means the funtion shouldn't(or should better not)
be called outside of the  file.You teach me,thank you!

> 
> This seems like a completely pointless and mindless change,
> and in fact might introduce bugs.

If you think this is a pointless change,you can just ingore it,
So sorry for the inconvenience:(But I don't think it's mindless,Because
before you teach me, I really misunderstand  Two "_" means .

> 
> There is no way I'm applying this.  You can't even explain if the
> patch is correct or not.  In fact, I doubt you even know.
> 

Yes,this single patch is not correct.As I said,this patch should together with
another patch to covert use of __ipv6_addr_src_scope to ipv6_addr_src_scope.

-- 
Regards
Yang Hongyang
