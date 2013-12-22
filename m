From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] batman-adv: free nf_bridge member on locally
 delivered skb
Date: Sun, 22 Dec 2013 18:50:27 -0500 (EST)
Message-ID: <20131222.185027.572777902017063381.davem@davemloft.net>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
	<1387412132-889-2-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594Ab3LVXu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:50:29 -0500
In-Reply-To: <1387412132-889-2-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Thu, 19 Dec 2013 01:15:27 +0100

> If an interface enslaved into batman-adv is a bridge (or a
> virtual interface built on top of a bridge) the nf_bridge
> member of the skbs reaching the soft-interface is filled
> with the state about "netfilter bridge" operations.
> 
> Then, if one of such skbs is locally delivered, the nf_bridge
> member should be cleaned up to avoid that the old state
> could mess up with other "netfilter bridge" operations when
> entering a second bridge.
> This is needed because batman-adv is an encapsulation
> protocol.
> 
> However at the moment skb->nf_bridge is not released at all
> leading to bogus "netfilter bridge" behaviours.
> Fix this by releasing skb->nf_bridge before an skb gets
> delivered to the upper layer in interface_rx().
> 
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
> Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>

See nf_reset() and skb_scrub_packet().  Do not reinvent the
wheel.

Thank you.
