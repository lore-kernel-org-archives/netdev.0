From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: allow shifted address in smsc911x
Date: Fri, 25 Mar 2011 21:46:08 +0000
Message-ID: <1301089568.2694.41.camel@bwh-desktop>
References: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	lee.jones@linaro.org, patches@linaro.org, linus.walleij@linaro.org
To: mathieu.poirier@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55687 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313Ab1CYVqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 17:46:12 -0400
In-Reply-To: <1301088437-31915-1-git-send-email-mathieu.poirier@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-25 at 15:27 -0600, mathieu.poirier@linaro.org wrote:
> From: Alessandro Rubini <rubini@gnudd.com>
> 
> At least one device I'm using needs address shifting to access
> registers in the LAN9221 device (smsc911x driver).  This patch
> adds a shift parameter in platform_data. The feature must be
> enabled at configuration time, because shifting by a pdata
> parameter makes access slower in those devices where no shift is
> needed (I tested one, it was 20% slower).
[...]

I guess you are using 16-bit registers, so that FIFO access involves
calling smsc911x_reg_{read,write}() in a loop.  And the compiler
probably can't hoist the address calculation out of the loop due to
potential aliasing between the register lock and the platform data (yes,
really).

Try calculating the FIFO address in a local variable at the top of
smsc911x_tx_writefifo() and smsc911x_rx_readfifo() and then using that
variable in the calls to smsc911x_reg_{read,write}().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

