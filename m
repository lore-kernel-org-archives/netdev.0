From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ip_tunnel:multicast process cause panic due to skb->_skb_refdst NULL pointer
Date: Mon, 24 Feb 2014 15:58:08 +0100
Message-ID: <20140224145807.GG6598@order.stressinduktion.org>
References: <1393216519-9066-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49235 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbaBXO6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 09:58:09 -0500
Content-Disposition: inline
In-Reply-To: <1393216519-9066-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 12:35:19PM +0800, Xin Long wrote:
> when ip_tunnel process multicast packets, it may check if the packet is looped
> back packet though 'rt_is_output_route(skb_rtable(skb))' in ip_tunnel_rcv(),
> but before that , skb->_skb_refdst has been dropped in iptunnel_pull_header(),
> so which leads to a panic.
> 
> fix the bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681

If the packet is locally forwarded we can test for IPCB(skb)->flags &
IPSKB_FORWARDED.

I am not sure if we actually have the correct dst at that point.

Greetings,

  Hannes
