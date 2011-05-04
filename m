From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 22:54:09 +0100
Message-ID: <1304546049.2926.81.camel@bwh-desktop>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>
	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>
	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com>
	 <1304532342.2926.46.camel@bwh-desktop>  <4DC19912.3000803@intel.com>
	 <1304534738.2926.74.camel@bwh-desktop>  <4DC1C018.5090709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35881 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab1EDVyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 17:54:13 -0400
In-Reply-To: <4DC1C018.5090709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 14:07 -0700, Alexander Duyck wrote:
> On 5/4/2011 11:45 AM, Ben Hutchings wrote:
[...]
> > Please can you confirm that the location specified for
> > ETHTOOL_SRXCLSRLINS will indeed be used as a priority in case of
> > overlapping filters?
> >
> > Ben.
> >
> 
> The ixgbe approach should be nearly identical in terms of how the 
> priorities are based on the location of the filters.

OK, good.

> The original 
> version from Santwona had the rule manager breaking the rules up into 7 
> sections so that rules that specified fewer fields would be near the end 
> of the list.  I'm pretty sure that was all due to priorities from what I 
> could see in the niu driver since the filters that covered wider ranges 
> were being made lower priority to be matched last.

That would make sense.

> In terms of overloading the get count call, that probably would be the 
> best route in terms of changing rule manager behavior.  The only thing I 
> am having a hard time seeing is how the rule manager would be able to 
> distinguish between low priority and high priority filter rules, or is 
> this something that new keywords would be added to the parser for?

Right, there would have to be keywords to specify that.

> I just put out version 6 of the patches.  Essentially I have reduced the 
> size of the rule manager to being used only on insertion without any 
> rule location specified.  The one thing to keep in mind with this rule 
> manager is that the rule at table size - 1 is always going to be the 
> lowest priority rule.  So if it was reserved for unspecified rules it 
> would be easy to use something like that to achieve an "auto-select" 
> location that the driver could then reassign as rules were added to it.

I don't think any location value within the physical table size should
select this special behaviour.  The special location values for
auto-select (with whatever priority) should be distinct from all the
physical location values.

I still need to review your patches but it sounds like they will be
ready to apply.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

