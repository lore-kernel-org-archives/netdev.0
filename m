From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Wed, 7 Jun 2006 11:48:01 -0500
Message-ID: <20060607164801.GX24227@waste.org>
References: <20060605231125.12584.17039.stgit@gitlost.site> <20060606135217.GA21969@hmsreliant.homelinux.net> <1149611965.13635.19.camel@strongmad> <20060606170513.GB21969@hmsreliant.homelinux.net> <4485B8EC.4090603@intel.com> <x494pyyw5sr.fsf@segfault.boston.redhat.com> <4485BCA2.5070904@intel.com> <x49zmgquqn0.fsf@segfault.boston.redhat.com> <20060606231727.GK24227@waste.org> <20060607150522.GA24608@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Moyer <jmoyer@redhat.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([64.81.244.121]:55258 "EHLO waste.org")
	by vger.kernel.org with ESMTP id S932341AbWFGQ7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 12:59:07 -0400
To: Neil Horman <nhorman@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060607150522.GA24608@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 07, 2006 at 11:05:22AM -0400, Neil Horman wrote:
> >  
> > > Matt, any ideas on this?
> > 
> > Not at the moment.
> 
> how about this for a solution?  It doesn't make netpoll any more robust, but I
> think in the interests of efficiency it would be fair to require that, when
> netpolled, a driver must receive frames on the same net device for which it was
> polled.  With this patch we detect that condition and handle it accordingly in
> e1000_intr.  This eliminates the need for us to call the clean_rx method from
> the poll_controller when napi is configured, instead allowing the poll method to
> be called from napi_poll, as the netpoll model currently does.  This fixes the
> netdump regression, and eliminates the layering violation and the potential race
> that we've been discussing.  I've just tested it with netdump here and it works
> quite well.
> 
> Thoughts appreciated.

This looks pretty reasonable, mostly from the perspective that it
doesn't put any further ugliness in netpoll. We might want to add a
comment somewhere in netpoll of the new rule we're now observing.
I'll let the e1000 guys comment on the particulars of the driver change.

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.
