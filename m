From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Regression in net-2.6.24?
Date: Thu, 11 Oct 2007 18:22:59 -0700
Message-ID: <20071011182259.3715182d@freepuppy.rosehill>
References: <20071011.164827.64988925.davem@davemloft.net>
	<20071011165548.6545b207@freepuppy.rosehill>
	<20071011.171743.118962219.davem@davemloft.net>
	<20071011.181449.130846976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: takano@axe-inc.co.jp, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39846 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbXJLBXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:23:17 -0400
In-Reply-To: <20071011.181449.130846976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Oct 2007 18:14:49 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> Here is what I'm checking into net-2.6 for now:
> 
> commit 6f535763165331bb91277d7519b507fed22034e5
> Author: David S. Miller <davem@sunset.davemloft.net>
> Date:   Thu Oct 11 18:08:29 2007 -0700
> 
>     [NET]: Fix NAPI completion handling in some drivers.
>     
>     In order for the list handling in net_rx_action() to be
>     correct, drivers must follow certain rules as stated by
>     this comment in net_rx_action():
>     
>     		/* Drivers must not modify the NAPI state if they
>     		 * consume the entire weight.  In such cases this code
>     		 * still "owns" the NAPI instance and therefore can
>     		 * move the instance around on the list at-will.
>     		 */
>     
>     A few drivers do not do this because they mix the budget checks
>     with reading hardware state, resulting in crashes like the one
>     reported by takano@axe-inc.co.jp.
>     
>     BNX2 and TG3 are taken care of here, SKY2 fix is from Stephen
>     Hemminger.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>

Please use the version I just sent, it saves another non-cached read.
