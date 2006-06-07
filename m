From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 07 Jun 2006 14:44:54 -0400
Message-ID: <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
References: <20060605231125.12584.17039.stgit@gitlost.site>
	<20060606135217.GA21969@hmsreliant.homelinux.net>
	<1149611965.13635.19.camel@strongmad>
	<20060606170513.GB21969@hmsreliant.homelinux.net>
	<4485B8EC.4090603@intel.com>
	<x494pyyw5sr.fsf@segfault.boston.redhat.com>
	<4485BCA2.5070904@intel.com>
	<x49zmgquqn0.fsf@segfault.boston.redhat.com>
	<20060606231727.GK24227@waste.org>
	<20060607150522.GA24608@hmsreliant.homelinux.net>
	<20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, "Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:30183 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932231AbWFGSwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 14:52:05 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44871A19.7080805@intel.com> (Auke Kok's message of "Wed, 07
 Jun 2006 11:25:29 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Auke Kok <auke-jan.h.kok@intel.com> adds:

auke-jan.h.kok> Hi,

auke-jan.h.kok> we're not too happy with this as it puts a branch right in
auke-jan.h.kok> the regular receive path. We haven't ran the numbers on it
auke-jan.h.kok> yet but it is likely that this will lower performance
auke-jan.h.kok> significantly during normal receives for something that is
auke-jan.h.kok> not common use.

auke-jan.h.kok> Attached below a (revised) patch that adds proper locking
auke-jan.h.kok> around the rx_clean to prevent the race.

That patch locks around the tx clean routine.  As such, it doesn't prevent
the problem.

> +	disable_irq(adapter->pdev->irq);
> +	if (likely(netif_rx_schedule_prep(&adapter->polling_netdev[0]))) {
> +		if (spin_trylock(&adapter->tx_queue_lock)) {
> +			e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
> +			spin_unlock(&adapter->tx_queue_lock);
> +		}
> +		adapter->clean_rx(adapter, adapter->rx_ring,
> +				&budget, netdev->weight);
> +		clear_bit(__LINK_STATE_RX_SCHED,
> +				&adapter->polling_netdev[0].state);

-Jeff
