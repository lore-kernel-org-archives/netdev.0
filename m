From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Mon, 07 Mar 2011 15:57:10 +0000
Message-ID: <1299513430.2522.9.camel@bwh-desktop>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>
	 <1298302841.2608.35.camel@bwh-desktop>  <4D642222.6050202@intel.com>
	 <1298939712.2569.43.camel@bwh-desktop>  <4D7138EF.7050606@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10646 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab1CGP5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 10:57:14 -0500
In-Reply-To: <4D7138EF.7050606@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-04 at 11:09 -0800, Alexander Duyck wrote:
> On 2/28/2011 4:35 PM, Ben Hutchings wrote:
> > On Tue, 2011-02-22 at 12:52 -0800, Alexander Duyck wrote:
> 
> [...]
> 
> >>>>                                 } else
> >>>>                                         show_usage(1);
> >>>>                                 break;
> >>>
> >>> I don't think the same options (-n, -N) should be used both for flow
> >>> hashing and n-tuple flow steering/filtering.  This command-line
> >>> interface and the structure used in the ethtool API just seem to reflect
> >>> the implementation in the niu driver.
> >>>
> >>> (In fact I would much prefer it if the -u and -U options could be used
> >>> for both the rxnfc and rxntuple interfaces.  But I haven't thought about
> >>> how the differences in functionality would be exposed to or hidden from
> >>> the user.)
> >>
> >> I was kind of thinking about merging the two interfaces too, but I was
> >> looking at it more from the perspective of moving away from ntuple more
> >> towards this newer interface.  My main motivation being that the filter
> >> display option is so badly broken for ntuple that it would be easier to
> >> make ntuple a subset of the flow classifier instead of the other way around.
> >>
> >> What would you think of using the "flow-type" keyword to indicate legacy
> >> ntuple support, and then adding something like "class-rule-add", and
> >> "class-rule-del" to add support for the network flow classifier calls?
> >
> > I really don't want to introduce different syntax for functionality that
> > is common between the two command sets.  The user should not have to
> > know that driver A implements interface I and driver B implements
> > interface J, except that since version 2.6.y driver A implements
> > interface J too.
> >
> > Surely it is possible to try one interface, then the other, when the
> > requested filter can be implemented either way?
> 
> The problem is that the interfaces are different in the way they 
> implement their masks.  N-tuple defines the mask as 0s mean inclusion, 
> 1s, mean exclusion.

You have got to be kidding me!

If this is the case, then the current kernel-doc for
ethtool_rx_flow_spec::m_u is incorrect.

> The network flow classifier filters are the exact 
> opposite.  As such we really need to know which type of filter we are 
> dealing with before we start setting up values.

This is nonsense; it's not hard to flip the bits later.

> In addition there are 
> options such as location which exist in network flow classifier rules, 
> but not in ntuple rules.

Sure, and when those are specified then there can be no fallback.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

