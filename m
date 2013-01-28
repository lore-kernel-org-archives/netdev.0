From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix possible wrong checksum generation
Date: Mon, 28 Jan 2013 00:28:01 -0500 (EST)
Message-ID: <20130128.002801.200824996474874108.davem@davemloft.net>
References: <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
	<1359143538.12374.3379.camel@edumazet-glaptop>
	<1359182077.5222.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3A1F2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 00:28:02 -0500
In-Reply-To: <1359182077.5222.132.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Jan 2013 22:34:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Pravin Shelar mentioned that GSO could potentially generate
> wrong TX checksum if skb has fragments that are overwritten
> by the user between the checksum computation and transmit.
> 
> He suggested to linearize skbs but this extra copy can be
> avoided for normal tcp skbs cooked by tcp_sendmsg().
> 
> This patch introduces a new SKB_GSO_SHARED_FRAG flag, set
> in skb_shinfo(skb)->gso_type if at least one frag can be
> modified by the user.
> 
> Typical sources of such possible overwrites are {vm}splice(),
> sendfile(), and macvtap/tun/virtio_net drivers.
> 
> Tested:
 ...
> Performance of the SENDFILE is impacted by the extra allocation and
> copy, and because we use order-0 pages, while the TCP_STREAM uses
> bigger pages.
> 
> Reported-by: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
