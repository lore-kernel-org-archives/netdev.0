From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Sun, 11 Jun 2006 20:13:56 -0400
Message-ID: <20060612001356.GA5112@localhost.localdomain>
References: <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net> <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com> <x49d5dkvm8p.fsf@segfault.boston.redhat.com> <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:6927 "EHLO
	ra.tuxdriver.com") by vger.kernel.org with ESMTP id S1750937AbWFLARH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 20:17:07 -0400
To: Jeff Moyer <jmoyer@redhat.com>
Content-Disposition: inline
In-Reply-To: <x49ac8nwo83.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 01:29:00PM -0400, Jeff Moyer wrote:
> ==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Mitch Williams <mitch.a.williams@intel.com> adds:
> 
> mitch.a.williams> On Wed, 2006-06-07 at 11:44 -0700, Jeff Moyer wrote:
> >> That patch locks around the tx clean routine.  As such, it doesn't
> >> prevent the problem.
> 
> mitch.a.williams> The call to netif_rx_schedule_prep provides locking
> mitch.a.williams> because it sets the __LINK_STATE_RX_SCHED bit atomically.
> mitch.a.williams> The spinlock around e1000_clean_tx_irq is to protect it
> mitch.a.williams> from other calls to the transmit routine, not NAPI.
> 
> Yes, but what prevents recursion in the poll routine?  Consider that the
> poll routine could end up triggerring a printk (think iptables, here).  In
> that case, you end up calling into netpoll, and if the tx ring is full, we
> call the poll_controller routine.  We've now recursed.
> 
> The poll lock was originally introduced to prevent recursion, not
> concurrent access.
> 
Any further thoughts on this guys?  I still think my last solution solves all of
the netpoll problems, and isn't going to have any noticable impact on
performance.

Regards
Neil

> -Jeff
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
