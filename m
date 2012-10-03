From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Wed, 03 Oct 2012 16:01:02 +0100
Message-ID: <506C532E.9070001@googlemail.com>
References: <1349192133.12401.768.camel@edumazet-glaptop> <1349192919.12401.778.camel@edumazet-glaptop> <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg> <20121002.231037.581571797430134988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	gpiez@web.de, davej@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:39672 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab2JCPBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 11:01:03 -0400
Received: by lbon3 with SMTP id n3so6282866lbo.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 08:01:01 -0700 (PDT)
In-Reply-To: <20121002.231037.581571797430134988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/03/12 04:10, David Miller wrote:
> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 3 Oct 2012 02:24:53 +0300 (EEST)
>
>> 	Can it be a problem related to fib_info reuse
>> from different routes. For example, when local IP address
>> is created for subnet we have:
>>
>> broadcast 192.168.0.255 dev DEV  proto kernel  scope link  src 192.168.0.1
>> 192.168.0.0/24 dev DEV  proto kernel  scope link  src 192.168.0.1
>> local 192.168.0.1 dev DEV  proto kernel  scope host  src 192.168.0.1
>>
>> 	The "dev DEV  proto kernel  scope link  src 192.168.0.1" is
>> a reused fib_info structure where we put cached routes.
>> The result can be same fib_info for 192.168.0.255 and
>> 192.168.0.0/24. RTN_BROADCAST is cached only for input
>> routes. Incoming broadcast to 192.168.0.255 can be cached
>> and can cause problems for traffic forwarded to 192.168.0.0/24.
>> So, this patch should solve the problem because it
>> separates the broadcast from unicast traffic.
>
> Now I understand the problem.
>
> I think the way to fix this is to add cfg->fc_type as another
> thing that fib_info objects are key'd by.
>
> I think it also would fix your obscure output multicast case too.
>
>

I've seen the discussion about whether Eric's patch is OK or not, but 
thought I'd give it a spin anyway. It applies to 3.6.0 with some fuzz, 
but I can confirm that with the patch applied I can now ping my router 
and browse the internet from a KVM client, so the Eric's diagnosis 
matches the problem I reported.

However, after closing the client, I got an oops. I've taken a 
photograph of the screen and uploaded it to 
http://i714.photobucket.com/albums/ww149/chris2553/IMAG0059.jpg. As it's 
not the final patch, this may be a red herring, but I thought I'd better 
give a heads up anyway.

Chris
