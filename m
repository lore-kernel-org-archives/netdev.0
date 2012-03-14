From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Wed, 14 Mar 2012 11:56:55 -0700
Message-ID: <4F60E9F7.4000402@candelatech.com>
References: <1331751214.6022.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60534 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756314Ab2CNS5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 14:57:03 -0400
In-Reply-To: <1331751214.6022.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2012 11:53 AM, Eric Dumazet wrote:
> A driver start_xmit() method cannot free skb and return NETDEV_TX_BUSY,
> since caller is going to reuse freed skb.
>
> This is mostly a revert of commit bf769375c (staging: hv: fix the return
> status of netvsc_start_xmit())
>
> In fact netif_tx_stop_queue() / netif_stop_queue() is needed before
> returning NETDEV_TX_BUSY or you can trigger a ksoftirqd fatal loop.
>
> In case of memory allocation error, only safe way is to drop the packet
> and return NETDEV_TX_OK

Can you not just leave the skb alone, not bump any tx-dropped
stats, and return NETDEV_TX_BUSY?

Been a while since I looked at this code however...

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
