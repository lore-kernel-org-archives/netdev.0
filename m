From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Mon, 14 Jan 2013 12:26:59 +0400
Message-ID: <50F3C153.9030204@oktetlabs.ru>
References: <50D1BCC0.2000208@oktetlabs.ru> <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com> <50D1CECE.7090706@oktetlabs.ru> <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com> <20121220073445.GM18940@secunet.com> <50D2F4E5.4050904@oktetlabs.ru> <20121220123535.GN18940@secunet.com> <20121221102253.GO18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:46478 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756208Ab3ANI1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 03:27:14 -0500
In-Reply-To: <20121221102253.GO18940@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/12 14:22, Steffen Klassert wrote:
> On Thu, Dec 20, 2012 at 01:35:35PM +0100, Steffen Klassert wrote:
>    
>> On Thu, Dec 20, 2012 at 03:22:13PM +0400, Yurij M. Plotnikov wrote:
>>      
>>> On 12/20/12 11:34, Steffen Klassert wrote:
>>>        
>>>> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
>>>> index 3c9d208..1049ce0 100644
>>>> --- a/net/ipv4/ip_sockglue.c
>>>> +++ b/net/ipv4/ip_sockglue.c
>>>> @@ -1198,7 +1198,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>>>>   	{
>>>>   		struct dst_entry *dst;
>>>>   		val = 0;
>>>> -		dst = sk_dst_get(sk);
>>>> +		dst = sk_dst_check(sk, 0);
>>>>   		if (dst) {
>>>>   			val = dst_mtu(dst);
>>>>   			dst_release(dst);
>>>>          
>>> With this patch kernel 3.7.1 works perfect. All described problems
>>> are fixed.
>>>        
>> Thanks for testing!
>>
>> I'm not sure if we can't use this as a fix. I think with this patch it
>> could happen that we return -ENOTCONN instead of a pmtu value on a
>> connected socket. Perhaps it is better to update the cached dst_entry in
>> ipv4_sk_update_pmtu() when we receive the -EMSGSIZE. I'll do some
>> investigation.
>>
>>      
> It turned out that updating the cached dst_entry in ipv4_sk_update_pmtu()
> is not trivial. We need to implement proper socket locking and we need
> socket release calback functions for all protocols that use
> ipv4_sk_update_pmtu(), similar to tcp.
>
> Today is my last office day for this year, so we probably have to defer
> a solution to the next year.
>
> Thanks.
>    
Hi Steffen,

Could you, please, tell me is there any news about this bug?

Thanks in advance,
Yurij.
