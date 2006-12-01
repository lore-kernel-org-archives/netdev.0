From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPSEC][4/7] inter address family ipsec tunnel
Date: Fri, 01 Dec 2006 13:41:39 +0900
Message-ID: <456FB283.9090904@miyazawa.org>
References: <20061124143839.8559449b.kazunori@miyazawa.org> <20061130.164827.57154936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: miika@iki.fi, Diego.Beltrami@hiit.fi, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:47518 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S1758889AbWLAEm1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 23:42:27 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061130.164827.57154936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
> Date: Fri, 24 Nov 2006 14:38:39 +0900
> 
> What is going on here?
> 
>> +			/* Without this, the atomic inc below segfaults */
>> +			if (encap_family == AF_INET6) {
>> +				rt->peer = NULL;
>> +				rt_bind_peer(rt,1);
>> +			}
>  ...
>> -		dst_prev->output	= xfrm4_output;
>> +		if (dst_prev->xfrm->props.family == AF_INET)
>> +			dst_prev->output = xfrm4_output;
>> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
>> +		else
>> +			dst_prev->output = xfrm6_output;
>> +#endif
>>  		if (rt->peer)
>>  			atomic_inc(&rt->peer->refcnt);
> 
> If it's non-NULL and you get a segfault for atomic_inc() that
> means there is garbage here, and it seems that if you're
> setting it to NULL explicitly then it's just a workaround
> for whatever problem is causing it to be non-NULL to begin
> with.
> 
> What is putting a non-valid pointer value there?  Is this an IPV6 or
> IPSEC dst route by chance?  If so, that makes this change really
> wrong, and we are corrupting the route by running rt_bind_peer() on
> it.  rt_bind_peer() is only valid on ipv4 route entries.

Thank you for your good catch.
I think atomic_inc must be done in case of props.family == AF_INET.
And we probably should manage reference count of the device in case of
AF_INET6.

Anyway I'll check and fix it.

Thank you.

--
Kazunori Miyazawa
