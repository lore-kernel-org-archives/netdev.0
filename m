From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Mon, 12 Jun 2006 09:42:14 -0700
Message-ID: <1150130534.2879.9.camel@strongmad>
References: <x494pyyw5sr.fsf@segfault.boston.redhat.com>
	 <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com>
	 <20060606231727.GK24227@waste.org>
	 <20060607150522.GA24608@hmsreliant.homelinux.net>
	 <20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
	 <x49d5dkvm8p.fsf@segfault.boston.redhat.com>
	 <1149787174.2928.3.camel@strongmad> <x49ac8nwo83.fsf@redhat.com>
	 <20060612001356.GA5112@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Moyer <jmoyer@redhat.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32061 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751494AbWFLQmS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 12:42:18 -0400
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20060612001356.GA5112@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-06-11 at 17:13 -0700, Neil Horman wrote:
> Any further thoughts on this guys?  I still think my last solution
> solves all of
> the netpoll problems, and isn't going to have any noticable impact on
> performance.
> 
I haven't had time to evaluate performance on your patch (sorry!), but
after thinking about it, I agree that it should not have any noticeable
impact.  OTOH, performance tuning is a funny thing, and things you think
won't cause problems often do.

Anyway, I'm still not quite ready to ACK this because it's just not
future-proof.  Eventually, we will need to support multiple RX queues,
and this solution will not work in that situation.

A simpler short-term solution is just to schedule our NAPI polling on
the "real" netdev instead of our polling netdev.  This is a trivial
change and works correctly with a single queue.  But, like your patch,
it isn't future-proof.

So, I'm still thinking and pondering on this one.

If we get a patch in to fix the recursive loop in netpoll, my original
patch will work, right?  Or is there still another issue?

-Mitch
