From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Mon, 07 Mar 2011 18:28:01 +0000
Message-ID: <1299522481.2522.24.camel@bwh-desktop>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>
	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>
	 <1298302841.2608.35.camel@bwh-desktop>  <4D642222.6050202@intel.com>
	 <1298939712.2569.43.camel@bwh-desktop>  <4D7138EF.7050606@intel.com>
	 <1299513430.2522.9.camel@bwh-desktop>  <4D751038.9040804@intel.com>
	 <1299520664.2522.21.camel@bwh-desktop>  <4D75225B.3010008@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29474 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab1CGS2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 13:28:04 -0500
In-Reply-To: <4D75225B.3010008@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-07 at 10:22 -0800, Dimitris Michailidis wrote:
> Ben Hutchings wrote:
> > On Mon, 2011-03-07 at 09:04 -0800, Alexander Duyck wrote:
> >> The only time where location really matters is if you are attempting to 
> >> overwrite an existing rule and I am not sure how that would be handled 
> >> in ntuple anyway since right now adding additional rules via ntuple for 
> >> ixgbe just results in duplicate rules being defined.
> > 
> > As I understand it, the location also determines the *priority* for the
> > rule.
> 
> This is true, at least for TCAMs.  But it's relevant only when multiple 
> filters would match a packet.  People often use non-overlapping filters, for 
> these adding the filter at any available slot is OK.

Right.  But ethtool would have to determine that the filter was non-
overlapping, before ignoring the location.  Also it cannot allow
deletion by location if it ever ignores the location on insertion.  We
should make the location optional at both the command-line and API
level, but never ignore it.

> > Which is why I wrote that "@fs.@location specifies the index to
> > use and must not be ignored."
> > 
> > To support hardware where the filter table is hash-based rather than a
> > TCAM, we would need some kind of flag or special value of location that
> > means 'wherever'.
> 
> I'd find the 'wherever' option useful for TCAMs too.  Maybe even have a few 
> of those, like 'first available', 'any', and 'last available'.  The last one 
> is quite useful for catch-all rules without requiring one to know the TCAM size.

Agreed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

