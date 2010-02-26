From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Fri, 26 Feb 2010 19:59:57 +0000
Message-ID: <1267214397.2098.17.camel@achroite.uk.solarflarecom.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
	 <4B85F173.40703@garzik.org>
	 <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B87315E.4080905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31704 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965876Ab0BZUAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 15:00:05 -0500
In-Reply-To: <4B87315E.4080905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 21:26 -0500, Jeff Garzik wrote:
> On 02/25/2010 08:49 PM, Waskiewicz Jr, Peter P wrote:
[...]
> > This will require a small kernel change.  Will something like this be
> > pulled in at this point, given that 2.6.33 just released?
> 
> The n-tuple stuff is not in 2.6.33's ethtool interface, so it hasn't 
> actually made it into a released kernel at this point.
> 
> It seems reasonable for 2.6.34 to either add ETHTOOL_GSTRINGS_COUNT or 
> update drvinfo.  Even if net-next has already been pulled into 
> post-2.6.33 merge window, that would IMO qualify as a reasonable 
> interface bugfix to get upstream.  The ethtool n-tuple ABI is not locked 
> into stone until 2.6.34 is released by Linus.

Given that, I would really like to see the tuple strings replaced with
binary structures.  Setting them in binary format and retrieving them in
text format is inelegant.  Also we should not assume that ethtool is the
only user of the ethtool API.  If someone wanted to write a GUI to
manage the filter tuples, or a tool that would programmatically
reconfigure filters, they would have to parse the strings.

Even the lookup of number of strings seems to be completely
misconceived.  It's delegated to the driver thus:

        ret = ops->get_sset_count(dev, gstrings.string_set);
        if (ret < 0)
                return ret;

What if gstrings.string_set != ETH_SS_NTUPLE_FILTERS?  Why is that even
a parameter to the operation?

Further, each filter can be formatted as multiple strings.  So is the
driver supposed to know how many strings the ethtool core might
generate?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

