From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 4/4] v5 Add RX packet classification interface
Date: Wed, 04 May 2011 18:24:52 +0100
Message-ID: <1304529892.2926.14.camel@bwh-desktop>
References: <20110503160547.29251.84333.stgit@gitlad.jf.intel.com>
	 <20110503161226.29251.40838.stgit@gitlad.jf.intel.com>
	 <4DC08E7B.7070906@chelsio.com> <1304465684.2873.26.camel@bwh-desktop>
	 <4DC1883F.7050301@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8567 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab1EDRY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 13:24:56 -0400
In-Reply-To: <4DC1883F.7050301@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 10:09 -0700, Dimitris Michailidis wrote:
> On 05/03/2011 04:34 PM, Ben Hutchings wrote:
> > On Tue, 2011-05-03 at 16:23 -0700, Dimitris Michailidis wrote:
> >> I think RX_CLS_LOC_UNSPEC should be passed to the driver, where there is 
> >> enough knowledge to pick an appropriate slot.  So I'd remove the
> >>
> >>      if (loc == RX_CLS_LOC_UNSPEC)
> >>
> >> block above, let the driver pick a slot, and then pass the selected location 
> >> back for ethtool to report.
> > 
> > But first we have to specify this in the ethtool API.  So please propose
> > a patch to ethtool.h.
> 
> In the past we discussed that being able to specify the first available slot or 
> the last available would be useful, so something like the below?
>
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index 4194a20..909ef79 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -442,7 +442,8 @@ struct ethtool_flow_ext {
>    *	includes the %FLOW_EXT flag.
>    * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
>    *	if packets should be discarded
> - * @location: Index of filter in hardware table
> + * @location: Index of filter in hardware table, or %RX_CLS_FLOW_FIRST_LOC for
> + *	first available index, or %RX_CLS_FLOW_LAST_LOC for last available
[...]

I think that's reasonable.  We should also explicitly state that
location determines priority, i.e. if a packet matches two filters then
the one with the lower location wins.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

