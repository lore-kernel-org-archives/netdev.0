From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
 with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 16:26:57 +0800
Message-ID: <496DA1D1.2050005@cn.fujitsu.com>
References: <20090114034711.GA8361@gondor.apana.org.au> <496D61FE.7080500@cn.fujitsu.com> <496D651B.2000106@cn.fujitsu.com> <496D77B8.2000001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54295 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbZANIc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 03:32:26 -0500
In-Reply-To: <496D77B8.2000001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang said:
> Wei Yongjun wrote:
>> Yang Hongyang wrote:
>>> Herbert Xu wrote:
>>>  
>>>> Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
>>>>    
>>>>> Actually the condition (optlen == 0) is included in (optlen <
>>>>> sizeof(struct in6_pktinfo)),
>>>>> so we do not need to check it separately.
>>>>>       
>>>> You don't need to check optval == NULL either since that's the
>>>> job of copy_from_user.
>>>>     
>>> If optval==NULL, what we should return?EINVAL or EFAULT?
>>> If it is EINVAL,then we should check it .otherwise it's the job of
>>> copy_from_user
>>>   
>> I think if optval==NULL, the in6_pktinfo which is set should be remove.
>> So, you should handle optval==NULL. Not just return error.
> 
> There's no RFC defines the behavior above,but:
>   RFC3542 said The application can remove any sticky Routing header or sticky 
> Destination options header or sticky Hop-by-Hop options header by calling 
> setsockopt() with a zero option length.
> 
> So,do we need to allow remove any sticky pktinfo option by calling 
> setsockopt() with a zero option length?
> 

Can remove the option using seting in6_pktinfo struct wiht 
ipi6_ifindex=0,ipi6_ifindex=IN6ADDR_ANY_INIT.

If no RFC definition, not to reset with optlen=0,
for example IPV6_TCLASS, PV6_2292DSTOPTS.

-- 
Best Regards
Shan Wei
