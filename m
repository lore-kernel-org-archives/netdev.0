From: David Miller <davem@davemloft.net>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely
 duplicate route_reverse function
Date: Mon, 11 Dec 2006 17:33:57 -0800 (PST)
Message-ID: <20061211.173357.92558541.davem@davemloft.net>
References: <20061129065146.GA20681@gondor.apana.org.au>
	<20061130.202206.25410613.davem@davemloft.net>
	<20061201043755.GA13624@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, khc@pm.waw.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33345
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750838AbWLLBd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:33:58 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20061201043755.GA13624@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 1 Dec 2006 15:37:55 +1100

> So in general when allocating packets we have two scenarios:
> 
> 1) The dst is known and fixed, i.e., all datagram protocols.  This is
> the easy case where the headroom is known exactly beforehand.
> 
> 2) The dst is unknown or may vary, this includes TCP, SCTP and DCCP.
> This is where we currently use MAX_HEADER plus some protocol-specific
> headroom.
> 
> Right now the normal (non-IPsec) dst output path always checks for
> sufficient headroom and reallocates if necessary (ip_finish_output2).
> I propose that we make IPsec do the same thing.

Agreed.

> For standard MTU-sized packets this discussion is moot since we have
> 2K of memory in each chunk.  However, for ACKs it could save a bit of
> memory.

For linear MTU-sized SKBs yes, but TCP data packets are going out %99
of the time with paged data these days and thus suffers from the same
set of issues and potential savings.
