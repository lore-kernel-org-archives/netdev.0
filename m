From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] drop_monitor: convert to modular building
Date: Wed, 16 May 2012 16:34:56 +0100
Message-ID: <1337182496.2568.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	 <1337180505.2568.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120516151932.GB30195@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59017 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754367Ab2EPPfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 11:35:00 -0400
In-Reply-To: <20120516151932.GB30195@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-16 at 11:19 -0400, Neil Horman wrote:
> On Wed, May 16, 2012 at 04:01:45PM +0100, Ben Hutchings wrote:
> > On Wed, 2012-05-16 at 10:27 -0400, Neil Horman wrote:
> > > When I first wrote drop monitor I wrote it to just build monolithically.  There
> > > is no reason it can't be built modularly as well, so lets give it that
> > > flexibiity.
[...]
> > > +	/*
> > > +	 * Because of the module_get/put we do in the trace state change path
> > > +	 * we are guarnateed not to have any current users when we get here
> > > +	 * all we need to do is make sure that we don't have any running timers
> > > +	 * or pending schedule calls
> > > +	 */
> > 
> > Surely you need to call set_all_monitor_traces(TRACE_OFF) first...
> > 
> Nope, If you'll note the code higher up in the patch, I use try_module_get and
> module_put to prevent the module unload code from getting here while anyone is
> actually using the protocol.  Once we are in the module remove routine here, we
> are guaranateed that there are no users of this protocol, and that the
> tracepoints are all unregistered.
[...]

Yes, of course.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
