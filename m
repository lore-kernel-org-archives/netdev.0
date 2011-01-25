From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next-2.6] pktgen: speedup fragmented skbs
Date: Tue, 25 Jan 2011 09:22:07 -0800
Message-ID: <4D3F06BF.7010903@candelatech.com>
References: <1295975635.3588.337.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39858 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255Ab1AYRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 12:22:11 -0500
In-Reply-To: <1295975635.3588.337.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2011 09:13 AM, Eric Dumazet wrote:
> We spend lot of time clearing pages in pktgen.
> (Or not clearing them on ipv6 and leaking kernel memory)
>
> Since we dont modify them, we can use one zeroed page, and get
> references on it. This page can use NUMA affinity as well.
>
> Define pktgen_finalize_skb() helper, used both in ipv4 and ipv6

Some devices, like vlans, can change the skb, but perhaps they
will not actually mess with the paged data?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

