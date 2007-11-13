From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: fix suspend regression due to NAPI changes
Date: Mon, 12 Nov 2007 18:09:46 -0800 (PST)
Message-ID: <20071112.180946.150182058.davem@davemloft.net>
References: <1194889547.4456.4.camel@johannes.berg>
	<1194906766.18185.79.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, shemminger@linux-foundation.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755262AbXKMCJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 21:09:46 -0500
In-Reply-To: <1194906766.18185.79.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 13 Nov 2007 09:32:46 +1100

> 
> On Mon, 2007-11-12 at 18:45 +0100, Johannes Berg wrote:
> > Commit bea3348e (the NAPI changes) made sungem unconditionally enable
> > NAPI when resuming and unconditionally disable when suspending, this,
> > however, makes napi_disable() hang when suspending when the interface
> > was taken down before suspend because taking the interface down also
> > disables NAPI. This patch makes touching the napi struct in
> > suspend/resume code paths depend on having the interface up, thereby
> > fixing the hang on suspend.
> > 
> > The patch also moves the napi_disable() in gem_close() under the lock so
> > that the NAPI state is always modified atomically together with the
> > "opened" variable.
> > 
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> 
> Thanks for fixing that !
> 
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Indeed, thanks a lot Johannes.

Patch applied.
