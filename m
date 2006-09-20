From: "cramerj" <cramerj@intel.com>
Subject: RE: [PATCH 08/23] e1000: add multicast stats counters
Date: Wed, 20 Sep 2006 16:50:30 -0700
Message-ID: <F2C59D1E488E7A4FB7F6F673DAF8325901C7BBF3@orsmsx413.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46419 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1750789AbWITXwl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 19:52:41 -0400
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Williams, Mitch A wrote:
> >>> +	{ "rx_broadcast", E1000_STAT(stats.bprc) },
> >>> +	{ "tx_broadcast", E1000_STAT(stats.bptc) },
> >>> +	{ "rx_multicast", E1000_STAT(stats.mprc) },
> >>> +	{ "tx_multicast", E1000_STAT(stats.mptc) },
> >>>  	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
> >>>  	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
> >>>  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },
> >> NAK -- you also need to remove the standard net stats, which are
> >> exported elsewhere
> >
> > Jeff, can you please explain the reason for this NAK a little more?
> > Neither Auke nor I understand why you rejected the patch.
> >
> > This patch just adds the display of a few more stats in Ethtool.  It
> > doesn't affect any other counters, and is really just a convenience
> > feature.  I added this to the driver because of a customer request.
> 
> Adding those stats is fine.  You guys just need to remove the existing
> mess first.
> 
> 	Jeff
> 

Since we have 1-to-1 mapping of some of our statistics registers to the
net_stats, we could s/net_stats/stats/.  However, there are a few
net_stats (e.g. net_stats.rx_errors) that encapsulate more than one
e1000 statistic register of which we don't have a private stat member
defined.

For those statistics, is it really necessary to add another stat
structure just to rm "net_stats" from that list we pass to ethtool?  At
best, it would look something like this...

  { "foo_count", E1000_STAT(stats.foo) },
- { "rx_errors", E1000_STAT(net_stats.rx_errors) },
+ { "rx_errors", E1000_STAT(eth_stats.rx_errors) },
  { "bar_count", E1000_STAT(stats.bar) },

If so, well, OK.  I'm just scratching my head as to why it's a "mess"
as-is.

I've missed obvious alternatives before; care to enlighten?

-Jeb
