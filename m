From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Add the command to show the time stamping
 capabilities.
Date: Tue, 3 Apr 2012 14:38:58 +0100
Message-ID: <1333460338.2577.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
	 <1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120403053717.GA2155@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11120 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751872Ab2DCNjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 09:39:05 -0400
In-Reply-To: <20120403053717.GA2155@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 07:37 +0200, Richard Cochran wrote:
> On Mon, Apr 02, 2012 at 08:25:58PM +0100, Ben Hutchings wrote:
> > On Sun, 2012-04-01 at 17:23 +0200, Richard Cochran wrote:
> 
> > > +	if (info->tx_types & (1 << HWTSTAMP_TX_OFF))
> > > +		fprintf(stdout, "HWTSTAMP_TX_OFF\n");
> > > +
> > > +	if (info->tx_types & (1 << HWTSTAMP_TX_ON))
> > > +		fprintf(stdout, "HWTSTAMP_TX_ON\n");
> > > +
> > > +	if (info->tx_types & (1 << HWTSTAMP_TX_ONESTEP_SYNC))
> > > +		fprintf(stdout, "HWTSTAMP_TX_ONESTEP_SYNC\n");
> > 
> > If there is no hardware timestamping available then shouldn't we see
> > HWTSTAMP_TX_OFF reported here?  But that's going to be the case.  Not
> > sure whether the kernel or the ethtool utility should deal with that,
> > but don't assume the ethtool utility is the only consumer.
> 
> Actually, if the device does not support hardware time stamping at
> all, then ioctl SIOCSHWTSTAMP returns EOPNOTSUPP. So, HWTSTAMP_TX_ON
> means you can turn Tx time stamping on, and HWTSTAMP_TX_OFF means you
> can turn it off again. It might not seem too logical, but that is how
> the interface works.

OK, this makes sense.

> So (tx_types == 0) means no hardware timestamping available. We can
> print that as a special case, if you think it best.
[...]

I think that from an administrator's point of view it would make more
sense to see that hardware timestamping is always off.  But from a
developer's point of view I can see it would make no sense to show a
mode/filter name which cannot actually be used.

So you could show tx_types == 0 or rx_filter == 0 using (1) no heading
and no list or (2) heading and a dummy entry (e.g. 'N/A').  Or maybe you
can think of something better.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
