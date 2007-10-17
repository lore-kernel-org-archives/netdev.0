From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi	poll
Date: Tue, 16 Oct 2007 23:16:52 -0400
Message-ID: <47157EA4.1000500@garzik.org>
References: <1192513792.19073.23.camel@pasglop>	 <20071016115318.0fc36af3@freepuppy.rosehill> <1192589522.11899.130.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33653 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbXJQDRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 23:17:03 -0400
In-Reply-To: <1192589522.11899.130.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
> net: Add __napi_synchronize() to sync with napi poll
> 
> The EMAC driver which needs to handle multiple devices with one
> NAPI instance implements its own per-channel disable bit. However,
> when setting such a bit, it needs to synchronize with the poller
> (that is make sure that any pending poller instance has completed,
> or is started late enough to see that disable bit).
> 
> This implements a low level __napi_synchronize() function to acheive
> that. The underscores are to emphasis the low level aspect of it and
> to discourage driver writers who don't know what they are doing to
> use it (to please DaveM :-)
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
> Switched to do a cpu_relax() spin instead and only on SMP. Not that
> we have an smp_mb() in there which synchronize_irq() lacks. I believe
> this is a bug in synchronize_irq() which I'll handle separately.
> 
> Note: unfortunately, Jeff already picked up the EMAC patch without
> waiting for this to be sorted out (oops...). So if you agree with
> this patch, it would be nice to have it go in quickly or maybe via
> Jeff's tree to avoid breakage ? Not terribly important tho.


Sorry, I thought that was the way everybody was headed.  With the driver 
broken /anyway/, I just sorta threw it into the pile of fixes.

It's upstream now, so let me know if you want to revert or move forward 
from here...

	Jeff


