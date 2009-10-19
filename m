From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] myri10ge: improve port type reporting in ethtool output
Date: Mon, 19 Oct 2009 15:17:51 +0100
Message-ID: <1255961871.2782.15.camel@achroite>
References: <4ADBFA88.8030300@myri.com> <1255939929.3916.13.camel@localhost>
	 <4ADC5CB8.4010801@myri.com> <1255957384.2782.2.camel@achroite>
	 <4ADC69FF.5000109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <brice@myri.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55673 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195AbZJSORt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 10:17:49 -0400
In-Reply-To: <4ADC69FF.5000109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-19 at 09:30 -0400, Andrew Gallatin wrote:
> Ben Hutchings wrote:
> > On Mon, 2009-10-19 at 08:34 -0400, Andrew Gallatin wrote:
> >> Ben Hutchings wrote:
> >>
> >>> Lying about link modes is not an improvement.
> >> OK, so we're probably doing something wrong. I suspect we're not
> >> alone.  At least we don't set SUPPORTED_TP for CX4, like I've
> >> seen some NICs do.
> >>
> >> Can somebody suggest how we can tell ethtool that
> >> the NIC supports 10Gb only (no autoneg down to 1Gb or lower)
> >> for copper (10Gbase-CX4)?   How about for fiber (10Gbase-{S,L})R?
> > 
> > What's wrong with what you already do?  Customers expect to see
> > something on the supported line?
> 
> Exactly.  One has complained because drivers for
> other vendors NICs show this, even if they are fibre NICs
> or CX4 NICs, and don't actually support 10GbaseT.

Let's fix the other drivers then.  Labelling these NICs as supporting
10GBASE-T is liable to confuse more people (and tools) in the long run.

> I'm happy to back this part out, and resubmit the patch without
> it. There is still some fairly valuable stuff in the patch
> -- mainly updating the NIC detection logic for new NICs to
> detect fibre vs copper.

Sure.

You should also set port = PORT_OTHER for CX4 or KX4.  Currently it
looks like you don't set port, so it appears as 0 == PORT_TP.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

