From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 5/5 v2] net: add old_queue_mapping into skb->cb
Date: Wed, 15 Dec 2010 08:19:23 -0800
Message-ID: <20101215081923.46fac651@nehalam>
References: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38823 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751053Ab0LOQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:19:46 -0500
In-Reply-To: <1292390636-3156-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Dec 2010 13:23:56 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
> 
> We save old queue_mapping in old_queue_mapping just before calling 
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the skb.
> 
> dev_pick_tx() use the current queue_mapping for the skbs reinjected
> by ifb.
> 
> A new struct dev_skb_cb is added, and valid in qdisc and gso layer.
> The original qdisc_skb_cb and DEV_GSO_CB are placed after dev_skb_cb.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

What about a more general mechanism that lets a layer push
some amount of data onto the skb and then pop it off.
Kind of link notes to self, maybe even encode them as netlink
(except netlink messages have excess padding).

This would allow nesting, and avoid cb[] clobbering.
The existing usage of cb[] is only because there wasn't a better
solution.

-- 
