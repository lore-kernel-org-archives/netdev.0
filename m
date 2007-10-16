From: David Miller <davem@davemloft.net>
Subject: Re: netif_napi_add vs. multiple netdev's
Date: Tue, 16 Oct 2007 15:16:16 -0700 (PDT)
Message-ID: <20071016.151616.70218795.davem@davemloft.net>
References: <1192513633.19073.21.camel@pasglop>
	<20071016091035.5fcd6d2e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55092
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761808AbXJPWQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 18:16:11 -0400
In-Reply-To: <20071016091035.5fcd6d2e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 16 Oct 2007 09:10:35 -0700

> On Tue, 16 Oct 2007 15:47:13 +1000
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > The way it's currently implemented, there's a list of NAPI's attached to
> > the netdev, so obviously, that won't work for my usage scenario.
> 
> sky2 driver has potentially 2 ports for 1 NAPI instance.

And it's unfortunately buggy.

For example, the sky2_suspend() code iterates over the ports
and calls sky2_down() on each one that is up.

That will call napi_disable() on the same NAPI instance if
multiple ports are up, and thus hang the machine.

This is why, Stephen, for the second time, I'm telling you
that perhaps you should put the NAPI instance into the
sky2_port struct.
