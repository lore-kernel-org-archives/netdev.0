From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 0/4] v6 Add support for network flow classifier
Date: Fri, 13 May 2011 02:14:52 +0100
Message-ID: <1305249292.14174.13.camel@bwh-desktop>
References: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com, dm@chelsio.com,
	netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5522 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759055Ab1EMBO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 21:14:56 -0400
In-Reply-To: <20110504183752.26394.29231.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 11:41 -0700, Alexander Duyck wrote:
> This series is nearly identical to the last series with only a few changes in
> the RX packet classification interface patch.  Specifically I have narrowed
> down the rule manager to the point where it is only used to identify a
> location for a rule if the rule location is unspecified.  The display
> functionality for rules now just pulls the rule list in and goes through the
> list from top to bottom displaying the rules instead of initializing the rule
> manager and pulling the rules form there.
> 
> The main advantage to this approach is that the rule manager could easily be
> replaced by a future ioctl call and on the failure of that ioctl call with a
> return of EOPNOTSUPP it should be easy to fall back and just use the rule
> manager.

Thanks a lot for persevering with this, Alexander.

I've applied this series with minor changes to the last patch.  I
abbreviated the version history in the commit message, and I deleted a
blank line in the manual page additions which made the indentation wrong
for the -U option.  I also recorded the author as you, since you've
largely rewritten it!  The commit message credits Santwona Behera.

You managed to uncover a bug in the sfc driver, which is that
set_rx_ntuple can return a positive value.  Previously ethtool accepted
any non-negative return value as successful, so I made a separate commit
to restore that behaviour.  Of course I'll fix the driver too.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

