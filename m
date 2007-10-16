From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: netif_napi_add vs. multiple netdev's
Date: Wed, 17 Oct 2007 08:24:23 +1000
Message-ID: <1192573463.11899.20.camel@pasglop>
References: <1192513633.19073.21.camel@pasglop>
	 <20071016091035.5fcd6d2e@freepuppy.rosehill>
	 <20071016.151616.70218795.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41515 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934737AbXJPWYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 18:24:32 -0400
In-Reply-To: <20071016.151616.70218795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 15:16 -0700, David Miller wrote:
> And it's unfortunately buggy.
> 
> For example, the sky2_suspend() code iterates over the ports
> and calls sky2_down() on each one that is up.
> 
> That will call napi_disable() on the same NAPI instance if
> multiple ports are up, and thus hang the machine.
> 
> This is why, Stephen, for the second time, I'm telling you
> that perhaps you should put the NAPI instance into the
> sky2_port struct.

Can sky2 send/mask interrupts separately per port ? The reason why I
can't do that with EMAC is why I'm doing multiple ports per NAPI
instance...

If sky2 sticks to doing like EMAC, then it probably also needs to do
like EMAC which is to have it's own port_disable/enable that use local
per-port disable bits. (It may do a real napi_disable when all ports are
disabled, I suppose, though I don't currently do it in EMAC).

Ben.


