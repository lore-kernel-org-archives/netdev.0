From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: fix napi regression with reset work
Date: Wed, 28 Nov 2007 10:28:44 +1100
Message-ID: <1196206124.7157.60.camel@pasglop>
References: <1196107328.8459.8.camel@johannes.berg>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58607 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440AbXK0XbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 18:31:24 -0500
In-Reply-To: <1196107328.8459.8.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-11-26 at 21:02 +0100, Johannes Berg wrote:
> sungem's gem_reset_task() will unconditionally try to disable NAPI even
> when it's called while the interface is not operating and hence the NAPI
> struct isn't enabled. Make napi_disable() depend on gp->running.
> 
> Also removes a superfluous test of gp->running in the same function.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> ---
> Not exactly sure how I got there but I did get stuck in there (sysrq-W)
> when I plugged in the network cable and booted the computer on the other
> end of it... while the interface was down. I would've thought that the
> driver wouldn't even notice the fact that I plugged in the cable while
> the interface is down, but maybe it does. Or it sets up the device
> wrongly at resume time when the interface was down at suspend.
> 
> In any case, this should fix the issue.

Thanks.

Ben.


