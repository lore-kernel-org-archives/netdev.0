From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skbuff: ensure to reset dev in skb_scrub_packet()
Date: Mon, 22 Jul 2013 14:54:45 -0700 (PDT)
Message-ID: <20130722.145445.571586476649309482.davem@davemloft.net>
References: <1374244891-7030-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388Ab3GVVyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:54:47 -0400
In-Reply-To: <1374244891-7030-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 19 Jul 2013 16:41:31 +0200

> Because this function is used to scrub a packet when it cross netns, we must
> ensure that skb->dev points to the new netns.
> 
> This was done by eth_type_trans() in dev_forward_skb(), but it's also needed
> for ip tunnels.
> 
> I take the opportunity to move the call of skb_scrub_packet() after
> eth_type_trans(), to be sure that pkt_type is set to PACKET_HOST.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Like others I do not like this change at all.

Every write into the SKB is costly at high packet rates, so writing
the device pointer multiple times unnecessarily can't be done.

The device does get set properly in all cases, the netns change is
not violated, so there is nothing wrong with the current code.
