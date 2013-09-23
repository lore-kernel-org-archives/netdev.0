From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need also be handled by UFO
Date: Mon, 23 Sep 2013 02:43:43 +0200
Message-ID: <20130923004343.GD22033@order.stressinduktion.org>
References: <20130921042700.GB8070@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: pjt@google.com, andreyknvl@google.com, kcc@google.com,
	therbert@google.com
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, dvyukov@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44310 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219Ab3IWAnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 20:43:45 -0400
Content-Disposition: inline
In-Reply-To: <20130921042700.GB8070@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 06:27:00AM +0200, Hannes Frederic Sowa wrote:
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

Further analysis showed it is very probable that this fixes the bug Dmitry
reported. So I want to give proper credits:

Reported-by: Dmitry Vyukov <dvyukov@google.com>
