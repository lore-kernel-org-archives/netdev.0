From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use
 irq_affinity_notifier to track changes in IRQ affinity map
Date: Mon, 30 Jun 2014 20:33:08 -0700 (PDT)
Message-ID: <20140630.203308.1311350484055713992.davem@davemloft.net>
References: <1404032097-5132-2-git-send-email-amirv@mellanox.com>
	<1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<53B1210E.6040409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, yevgenyp@mellanox.com, tglx@linutronix.de,
	ben@decadent.org.uk, amira@mellanox.com, yuvala@mellanox.com
To: amirv@mellanox.com, amirv.mellanox@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbaGADdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 23:33:11 -0400
In-Reply-To: <53B1210E.6040409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv.mellanox@gmail.com>
Date: Mon, 30 Jun 2014 11:34:22 +0300

> On 6/30/2014 9:41 AM, Eric Dumazet wrote:
>> You might want to drain whole queue instead of limiting to a 'budget',
>> otherwise, a cpu might be stuck servicing (soft)irq for the TX
>> completion, even if irq affinities say otherwise.
>> 
> 
> TX completions are very quick compared to the skb preparation and
> sending. Which is not the case for RX completions. Because of that, it
> is very easy to reproduce the problem in RX flows, but we never had any
> report of that problem in the TX flow.
> I prefer not to spend time on the TX, since we plan to send a patch soon
> to use the same NAPI for both TX and RX.

It is always advised to completely ignore the budget for TX work, this is
what we tell every driver author when discussion NAPI implementations.

Please make your driver conform to this, thanks.
