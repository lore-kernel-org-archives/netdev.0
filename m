From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH v2] tipc: fix build issue when building without IPv6
Date: Fri, 20 Mar 2015 10:09:26 +0800
Message-ID: <550B8156.3020400@windriver.com>
References: <20150319.150433.850095478975909930.davem@davemloft.net>	<1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com> <20150319.160658.1294624225284354605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <richard.alpe@ericsson.com>, <jon.maloy@ericsson.com>,
	<netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<erik.hugne@ericsson.com>
To: David Miller <davem@davemloft.net>, <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60990 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTCJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 22:09:57 -0400
In-Reply-To: <20150319.160658.1294624225284354605.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2015 04:06 AM, David Miller wrote:
> From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Date: Thu, 19 Mar 2015 16:47:58 -0300
> 
>> We can't directly call ipv6_sock_mc_join() but should use the stub
>> instead and protect it around IS_ENABLED.
>>
>> Fixes: d0f91938bede ("tipc: add ip/udp media type")
>> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> 

Sorry, this patch doesn't work at all especially when IPV6=m and TIPC=y. For
example, when we use the combination of the kernel config options, error appears
like:

net/built-in.o: In function `tipc_udp_send_msg':
/home/ying/work/tipc/tipc2.0/net-next-2.6-debug/net/tipc/udp_media.c:196:
undefined reference to `ip6_dst_lookup'
make: *** [vmlinux] Error 1

Instead, I ever tried to fix the issue several days ago. Please refer to the thread:

https://patchwork.ozlabs.org/patch/448836/

According to the suggestion David gave lastly, we should separate the UDP media
as an independent module, make TIPC_MEDIA_UDP depend on (IPV6 || IPV6=n), and
mark TIPC_MEDIA_UDP tristate. Now I am busy doing this following the proposal.

Regards,
Ying

> This works better, applied, thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
