From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via
 ethtool
Date: Fri, 8 Mar 2013 09:57:32 -0500
Message-ID: <20130308145732.GA7606@gospo.rdu.redhat.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
 <1362601037.3126.20.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966Ab3CHPB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 10:01:59 -0500
Content-Disposition: inline
In-Reply-To: <1362601037.3126.20.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 06, 2013 at 08:17:17PM +0000, Ben Hutchings wrote:
> On Wed, 2013-03-06 at 13:39 -0500, Andy Gospodarek wrote:
> > This patch adds support for the get_settings ethtool op to the bonding
> > driver.  This was motivated by users who wanted to get the speed of the
> > bond and compare that against throughput to understand utilization.
> > The behavior before this patch was added was problematic when computing
> > line utilization after trying to get link-speed and throughput via SNMP.
> > 
> > The general plan for computing link-speed was as follows:
> > 
> > Mode                 Formula
> > ----                 -------
> > active-backup        speed of current active slave
> > broadcast            speed of first slave with known speed
> > all other modes      aggregate speed of all slaves with known speed
> > 
> > Output from ethtool looks like this for a round-robin bond:
> > 
> > Settings for bond0:
> > 	Supported ports: [ ]
> > 	Supported link modes:   Not reported
> > 	Supported pause frame use: No
> > 	Supports auto-negotiation: No
> > 	Advertised link modes:  Not reported
> > 	Advertised pause frame use: No
> > 	Advertised auto-negotiation: No
> > 	Speed: 11000Mb/s
> > 	Duplex: Full
> > 	Port: Twisted Pair
> 
> I think port should be PORT_OTHER.  Or perhaps you could ask the current
> slave, if using active-backup.  (Tricky since you can't do that while
> holding the bond rwlock.)
> 
> > 	PHYAD: 0
> 
> I don't think we have a properly defined 'not applicable' value for
> phy_address, though I've used 0xff in sfc.
> 
[...]
> 
> You must use ethtool_cmd_speed_set() instead of assigning just
> ecmd->speed.
> 
> (bonding appears to be the first driver that could report a value >
> 65535.)
> 

Thanks for the review, Ben.  I'll take a look at these suggestions for v2.

> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
