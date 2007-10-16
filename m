From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH/RFC] net: Add __napi_sycnhronize() to sync with napi
	poll
Date: Wed, 17 Oct 2007 07:14:55 +1000
Message-ID: <1192569295.11899.14.camel@pasglop>
References: <1192513792.19073.23.camel@pasglop>
	 <20071016115318.0fc36af3@freepuppy.rosehill>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52593 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934453AbXJPVPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 17:15:40 -0400
In-Reply-To: <20071016115318.0fc36af3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> So this is really just like synchronize_irq()?  Using msleep is bogus
> because you want to spin, you are only waiting for a softirq on the other
> cpu to finish. If you wait for a whole millisecond and sleep that
> is far longer than the napi routine should take.
> 
> You could even optimize it like synchronize_irq() for the non-SMP case.

It's just like synchronize_irq() indeed. I used the mlseep() just like
napi_disable() mostly because I use it in a very similar context, for
disabling my sub-channels on things like link change etc... where I need
to reconfigure parts of the chip.

I prefer sleeping in my case but I agree that if somebody else was going
to use for something else more performance critical, it might be an
issue. On the other hand, spinning will not be nice for my usage
scenario :-)

I agree about the SMP optimisation though again, in my usage pattern,
it's very unimportant (similar code path as napi_disable)

I'll respin later today though.

Cheers,
Ben.


