From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Fri, 24 Aug 2012 17:51:28 +0100
Message-ID: <1345827088.2694.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120823110357.GB2238@netboy.at.omicron.at>
	 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
	 <20120823172950.GA2192@netboy.at.omicron.at>
	 <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
	 <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
	 <20120824101053.GA6038@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19067 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752060Ab2HXQvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 12:51:33 -0400
In-Reply-To: <20120824101053.GA6038@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 12:10 +0200, Richard Cochran wrote:
> On Thu, Aug 23, 2012 at 06:40:25PM +0000, Vick, Matthew wrote:
> > 
> > I tend to agree with Jake here--I like having the information. I'm fine removing them, but I'd like to do it for all CONFIG_IGB_PTP wrapping if we're going to do it. What do you think, Richard?
> 
> Come to think of it, I never liked the CONFIG_IGB_PTP very much in the
> first place. These were added after the fact by Jeff Kirsher. He had
> said off list that there was some issue with CONFIG_PTP_1588_CLOCK and
> igb as a module, or something like that. At that time I said, just go
> ahead and fix it up.

If there is some feature of a driver that depends on an optional
modularisable subsystem, and you want the driver to be built without
that feature when the subsystem is missing, then the feature has to be
disabled when the driver is built-in and the subsystem is a module.  So
in general you need:

config DRIVER_FEATURE
	bool "This is a really neat feature for the driver"
	depends on DRIVER && SUBSYSTEM && !(DRIVER=y && SUBYSTEM=m)

> I think it would be better if the "time stamp all Rx packets" of the
> 82580 were always available, and that the PHC feature always be
> compiled when CONFIG_PTP_1588_CLOCK is selected.
> 
> Maybe you could ask Jeff what the issue was, and then see if there is
> a way to remove CONFIG_IGB_PTP altogether.

Even if they are to be enabled automatically, CONFIG_IGB_PTP and similar
config symbols are important as shorthand.  So I think what you want is:

config IGB_PTP
	def_bool y
	depends on IGB && PTP_1588_CLOCK && !(IGB=y && PTP_1588_CLOCK=m)

(But currently it's actually *selecting* PTP_1588_CLOCK.  We should
probably have drivers consistently select or depend on it, not a
mixture.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
