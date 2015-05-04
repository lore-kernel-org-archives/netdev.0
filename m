From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Flow label state ranges
Date: Sun, 03 May 2015 21:58:23 -0400 (EDT)
Message-ID: <20150503.215823.1241813224848092278.davem@davemloft.net>
References: <1430346801-2297436-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58421 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbEDB6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 21:58:24 -0400
In-Reply-To: <1430346801-2297436-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 29 Apr 2015 15:33:21 -0700

> This patch divides the IPv6 flow label space into two ranges:
> 0-7ffff is reserved for flow label manager, 80000-fffff will be
> used for creating auto flow labels (per RFC6438). This only affects how
> labels are set on transmit, it does not affect receive. This range split
> can be disbaled by systcl.
> 
> Background:
> 
> IPv6 flow labels have been an unmitigated disappointment thus far
> in the lifetime of IPv6. Support in HW devices to use them for ECMP
> is lacking, and OSes don't turn them on by default. If we had these
> we could get much better hashing in IPv6 networks without resorting
> to DPI, possibly eliminating some of the motivations to to define new
> encaps in UDP just for getting ECMP.
> 
> Unfortunately, the initial specfications of IPv6 did not clarify
> how they are to be used. There has always been a vague concept that
> these can be used for ECMP, flow hashing, etc. and we do now have a
> good standard how to this in RFC6438. The problem is that flow labels
> can be either stateful or stateless (as in RFC6438), and we are
> presented with the possibility that a stateless label may collide
> with a stateful one.  Attempts to split the flow label space were
> rejected in IETF. When we added support in Linux for RFC6438, we
> could not turn on flow labels by default due to this conflict.
> 
> This patch splits the flow label space and should give us
> a path to enabling auto flow labels by default for all IPv6 packets.
> This is an API change so we need to consider compatibility with
> existing deployment. The stateful range is chosen to be the lower
> values in hopes that most uses would have chosen small numbers.
> 
> Once we resolve the stateless/stateful issue, we can proceed to
> look at enabling RFC6438 flow labels by default (starting with
> scaled testing).
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Ok, applied, let's see what happens.

Thanks Tom.
