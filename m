From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BRIDGE] Unaligned access on IA64 when comparing ethernet
 addresses
Date: Thu, 19 Apr 2007 16:14:23 +0200
Message-ID: <20070419161423.a8f5c4f0.dada1@cosmosbay.com>
References: <4625BE2C.1030801@sw.ru>
	<20070418.012804.95897126.davem@davemloft.net>
	<20070418074439.1ba41718@localhost.localdomain>
	<20070418.130422.88477383.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, xemul@sw.ru,
	netdev@vger.kernel.org, bridge@lists.osdl.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:60537 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S637777AbXDSOOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 10:14:35 -0400
In-Reply-To: <20070418.130422.88477383.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Apr 2007 13:04:22 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Although I don't think gcc does anything fancy since we don't
> use memcmp().  It's a tradeoff, we'd like to use unsigned long
> comparisons when both objects are aligned correctly but we also
> don't want it to use any more than one potentially mispredicted
> branch.

Again, memcmp() *cannot* be optimized, because its semantic is to compare bytes.

memcpy() can take into account alignement if known at compile time, not memcmp()

http://lists.openwall.net/netdev/2007/03/13/31


> 
> We could add some alignment tests to the ethernet address
> comparison code, but it's probably more trouble than it's
> worth.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
-- 
Eric Dumazet <dada1@cosmosbay.com>

