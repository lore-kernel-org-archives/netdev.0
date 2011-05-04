From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 19:45:38 +0100
Message-ID: <1304534738.2926.74.camel@bwh-desktop>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>
	 <4DC1883F.7050301@chelsio.com> <1304529892.2926.14.camel@bwh-desktop>
	 <4DC18DF8.3090707@chelsio.com>  <4DC18FB2.8060604@intel.com>
	 <1304532342.2926.46.camel@bwh-desktop>  <4DC19912.3000803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16600 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737Ab1EDSpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 14:45:42 -0400
In-Reply-To: <4DC19912.3000803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 11:21 -0700, Alexander Duyck wrote:
[...]
> Honestly what I would prefer to see is a seperate call added such as an 
> ETHTOOL_GRSCLSRLLOC that we could pass the flow specifier to and perhaps 
> include first/last location call in that and then let the driver return 
> where it wants to drop the rule.

This must not be done as a separate operation because it's racy (in fact
that's an inherent problem with the rule manager).  In the sfc driver
(and probably others in future) filters could be inserted for RFS at any
time.

> That way we can avoid having to create 
> an overly complicated rule manager that can handle all the bizarre rule 
> ordering options that I am sure all the different network devices support.

Right, the rule manager can't implement that.

> The only reason I am not implementing this now is because there aren't 
> any drivers in place that would currently use it.  I figure once cxgb 
> has a means in place of supporting flow classifier rules then Dimitris 
> can add the necessary code to ethtool and the kernel to allow the driver 
> to specify rule locations.  I would prefer to avoid adding features 
> based on speculation of what will be needed and would like to be able to 
> actually see how the features will be used.

If you are going to implement the same interface in ixgbe as in niu
(modulo bugs), then I have no objection to going ahead with this and
then adding the option for driver-assigned locations later.

Please can you confirm that the location specified for
ETHTOOL_SRXCLSRLINS will indeed be used as a priority in case of
overlapping filters?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

