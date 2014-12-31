From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: call cond_resched after broadcasting
 updates
Date: Wed, 31 Dec 2014 18:38:38 -0500 (EST)
Message-ID: <20141231.183838.806545236690156809.davem@davemloft.net>
References: <20141227095433.00333deb@urahara>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaLaXik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:38:40 -0500
In-Reply-To: <20141227095433.00333deb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sat, 27 Dec 2014 09:54:33 -0800

> When a netlink event is posted to a socket, the receiving process maybe
> waiting to wakeup. Reduce the latency by calling cond_resched() in this
> loop. This reduces the problems with missed events during a netlink
> storm such as when a routing daemon does mass update in response to
> a link transition.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

As mentioned by others, this is potentially invoked from software
interrupts generating netlink events (one example is ipv6) so we
can't try to conditionally sleep here.
