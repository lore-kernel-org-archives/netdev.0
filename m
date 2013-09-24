From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet
 need also be handled by UFO
Date: Tue, 24 Sep 2013 11:43:44 -0400 (EDT)
Message-ID: <20130924.114344.932694780733009227.davem@redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752690Ab3IXPnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:43:49 -0400
In-Reply-To: <20130921042700.GB8070@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 21 Sep 2013 06:27:00 +0200

> In the following scenario the socket is corked:
> If the first UDP packet is larger then the mtu we try to append it to the
> write queue via ip6_ufo_append_data. A following packet, which is smaller
> than the mtu would be appended to the already queued up gso-skb via
> plain ip6_append_data. This causes random memory corruptions.
> 
> In ip6_ufo_append_data we also have to be careful to not queue up the
> same skb multiple times. So setup the gso frame only when no first skb
> is available.
> 
> This also fixes a shortcoming where we add the current packet's length to
> cork->length but return early because of a packet > mtu with dontfrag set
> (instead of sutracting it again).
> 
> Found with trinity.
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
