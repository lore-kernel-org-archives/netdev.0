From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] ethtool: Warn if we cannot set the advertising
 mask for specified speed/duplex
Date: Fri, 18 Feb 2011 20:08:57 +0000
Message-ID: <1298059737.2570.43.camel@bwh-desktop>
References: <1297969576.2637.33.camel@bwh-desktop>
	 <1298044598.2570.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	Naveen Chouksey <nchouksey@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59846 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757412Ab1BRUJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 15:09:00 -0500
In-Reply-To: <1298044598.2570.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-02-18 at 15:56 +0000, Ben Hutchings wrote:
> On Thu, 2011-02-17 at 19:06 +0000, Ben Hutchings wrote:
> > When autonegotiation is enabled, drivers must determine link speed and
> > duplex through the autonegotiation process and will generally ignore
> > the speed and duplex specified in struct ethtool_cmd.  If the user
> > specifies a recognised combination of speed and duplex, we set the
> > advertising mask to include only the matching mode.  Otherwise, we
> > advertise all supported modes.  We should really limit the advertised
> > modes separately by speed and duplex, but for now we just warn.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This is a longstanding bug in ethtool which people keep getting bitten
> > by.  Naveen was just the latest to report it.  I have been working on
> > some changes to improve link advertising and reporting, but until those
> > are ready I'm adding this warning.
> 
> That patch fixes an additional bug: we will now update the advertising
> mask based on speed/duplex when autoneg is already on.  Unfortunately it
> introduces a bug: we will update advertising even if none of autoneg,
> speed or duplex are specified!
> 
> Here's a second version which I think will do the right thing in all
> cases, though I haven't tested it yet.  I'll include this in ethtool
> 2.6.38 if no-one can spot a flaw.
[...]
> +			if (autoneg_wanted == AUTONEG_ENABLE &&
> +			    advertising_wanted == 0) {
> +				ecmd.advertising = ecmd.supported &
> +					(ADVERTISED_10baseT_Half |
> +					 ADVERTISED_10baseT_Full |
> +					 ADVERTISED_100baseT_Half |
> +					 ADVERTISED_100baseT_Full |
> +					 ADVERTISED_1000baseT_Half |
> +					 ADVERTISED_1000baseT_Full |
> +					 ADVERTISED_2500baseX_Full |
> +					 ADVERTISED_10000baseT_Full);
> +			} else if (advertising_wanted != -1) {

This condition should be (advertising_wanted > 0).  With that last
change, ethtool seems to do the right thing.

Ben.

> +				ecmd.advertising = advertising_wanted;
>  			}
>  
>  			/* Try to perform the update. */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

