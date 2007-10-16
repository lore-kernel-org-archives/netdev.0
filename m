From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: netif_napi_add vs. multiple netdev's
Date: Tue, 16 Oct 2007 16:37:24 -0700
Message-ID: <20071016163724.28fc1df0@freepuppy.rosehill>
References: <1192513633.19073.21.camel@pasglop>
	<20071016091035.5fcd6d2e@freepuppy.rosehill>
	<20071016.151616.70218795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58245 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754110AbXJPXhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 19:37:32 -0400
In-Reply-To: <20071016.151616.70218795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007 15:16:16 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 16 Oct 2007 09:10:35 -0700
> 
> > On Tue, 16 Oct 2007 15:47:13 +1000
> > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > 
> > > The way it's currently implemented, there's a list of NAPI's attached to
> > > the netdev, so obviously, that won't work for my usage scenario.
> > 
> > sky2 driver has potentially 2 ports for 1 NAPI instance.
> 
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

It isn't possible, there is only one hardware IRQ, and one
common status buffer.  I'll fix the suspend code, it has other
problems as well.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
