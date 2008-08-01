From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] inet6: Fix paramater issue of inet6_csk_xmit
Date: Fri, 01 Aug 2008 13:17:15 +0800
Message-ID: <48929C5B.5030108@cn.fujitsu.com>
References: <48918C49.4070708@cn.fujitsu.com> <20080731.204826.189988398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63112 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbYHAFTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 01:19:04 -0400
In-Reply-To: <20080731.204826.189988398.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Thu, 31 Jul 2008 17:56:25 +0800
>
>   
>> inet6_csk_xmit() has a paramater ipfragok, but never pass to
>> ip6_xmit(), always call it with ipfragok = 0.
>>
>> This patch fixed this problem by instead 0 of ipfragok.
>>
>> Compiled test only.
>>
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>>     
>
> I would like to see someone do some testing of this patch
> before I apply it.
>   
inet6_csk_xmit() just be used by tcp and dccp:
1042 net/dccp/ipv6.c      .queue_xmit       = inet6_csk_xmit
1853 net/ipv6/tcp_ipv6.c     .queue_xmit       = inet6_csk_xmit,

And used always with ipfragok = 0.
139 net/dccp/output.c         err = icsk->icsk_af_ops->queue_xmit(skb, 0);
626 net/ipv4/tcp_output.c     err = icsk->icsk_af_ops->queue_xmit(skb, 0);

I can not find any place used inet6_csk_xmit() with ipfragok = 1.

So I think it is safe to apply this patch. Or maybe this paramater is 
useless.



