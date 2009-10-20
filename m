From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Tue, 20 Oct 2009 14:30:40 -0700
Message-ID: <4ADE2C00.8030900@candelatech.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com> <4ADE2A24.6080300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, robert@herjulf.net,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39108 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbZJTVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 17:30:40 -0400
In-Reply-To: <4ADE2A24.6080300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2009 02:22 PM, Eric Dumazet wrote:

> Problem is skb->queue_mapping has different meaning if skb is directly given to a real device ->  start_xmit()
>
> ( In this case skb->queue_mapping should be between [O ... real_num_tx_queues-1])
>
> But if it goes through dev_queue_xmit(), it should be set between [1 .. real_num_tx_queues], because
> dev_pick_tx() will decrement skb->queue_mapping
>
> In fact skb->queue_mapping only works for forwarded packets, not locally generated ones.
>
> I am too tired to cook a fix at this moment, sorry :(

That's definitely a nasty little issue.  Using skb_set_queue_mapping
in pktgen makes it run for me, but may just be getting lucky with the
mac-vlan interfaces which will do the dev_queue_xmit (but, I don't so much
care exactly what queue is used as long as things don't crash and the
link doesn't reset).

Don't worry about a quick patch on my account.  I seem to have it working
to at least some degree (no funny crashes, no link watchdog timeouts).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

