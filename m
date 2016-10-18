From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] udp: Flow dissection for tunnels
Date: Tue, 18 Oct 2016 11:48:37 -0400 (EDT)
Message-ID: <20161018.114837.323859592404227389.davem@davemloft.net>
References: <20161017194202.3510238-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43150 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964865AbcJRPsj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 11:48:39 -0400
In-Reply-To: <20161017194202.3510238-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 17 Oct 2016 12:41:55 -0700

> Now that we have a means to perform a UDP socket lookup without taking
> a reference, it is feasible to have flow dissector crack open UDP
> encapsulated packets. Generally, we would expect that the UDP source
> port or the flow label in IPv6 would contain enough entropy about
> the encapsulated flow. However, there will be cases, such as a static
> UDP tunnel with fixed ports, where dissecting the encapsulated packet
> is valuable.
> 
> The model is here is similar to that implemented for UDP GRO. A
> tunnel implementation (e.g. GUE) may set a flow_dissect function
> in the udp_sk. In __skb_flow_dissect a case has been added for
> UDP to check if there is a socket with flow_dissect set. If there
> is the function is called. The (per tunnel implementation)
> function can parse the encapsulation headers and return the
> next protocol for __skb_flow_dissect to process and it's position
> in nhoff.
> 
> Since performing a UDP lookup on every packet might be expensive
> I added a static key check to bypass the lookup if there are no
> sockets with flow_dissect set. I should mention that doing the
> lookup wasn't particularly a big hit anyway.
> 
> Fou/gue was modified to perform tunnel dissection. This is enabled
> on each listener socket via a netlink configuration option.

Series applied, thanks Tom.
