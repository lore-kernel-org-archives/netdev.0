From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Fri, 07 Dec 2012 14:20:04 -0500 (EST)
Message-ID: <20121207.142004.1330913822593924898.davem@davemloft.net>
References: <1354826194-9289-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, therbert@google.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438Ab2LGTUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:20:06 -0500
In-Reply-To: <1354826194-9289-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Thu,  6 Dec 2012 15:36:34 -0500

> This patch maintains flow affinity in normal conditions, but
> trades it for throughput when a cpu becomes saturated. Then, packets
> destined to that cpu (only) are redirected to the lightest loaded cpu
> in the rxqueue's rps_map. This breaks flow affinity under high load
> for some flows, in favor of processing packets up to the capacity
> of the complete rps_map cpuset in all circumstances.

We specifically built-in very strict checks to make sure we never
deliver packets out-of-order.  Those mechanisms must be used and
enforced in any change of this nature.
