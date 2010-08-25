From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC patch (against wireless-next)] include/net/cfg80211.h:
 wiphy_<level> messages use dev_printk
Date: Wed, 25 Aug 2010 14:01:29 -0400
Message-ID: <20100825180129.GK2557@tuxdriver.com>
References: <1282245848.6724.261.camel@Joe-Laptop>
 <1282246784.4507.14.camel@jlt3.sipsolutions.net>
 <1282342439.1960.84.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56302 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706Ab0HYSOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 14:14:41 -0400
Content-Disposition: inline
In-Reply-To: <1282342439.1960.84.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 20, 2010 at 03:13:59PM -0700, Joe Perches wrote:
> On Thu, 2010-08-19 at 21:39 +0200, Johannes Berg wrote:
> > On Thu, 2010-08-19 at 12:24 -0700, Joe Perches wrote:
> > > Adding device to the wiphy logging messages could be useful.
> > >  #define wiphy_printk(level, wiphy, format, args...)		\
> > > -	printk(level "%s: " format, wiphy_name(wiphy), ##args)
> > > +	dev_printk(level, &wiphy->dev, "%s: " format, wiphy_name(wiphy), ##args)
> > what will that actually print?
> 
> As is, that'd print:
> 
> "<level>dev_driver_string(&wiphy->dev) dev_name(&wiphy->dev): wiphy_name(wiphy): " fmt, ##args
> 
> for instance:
> 
> [   41.261941] ieee80211 phy0: phy0: Selected rate control algorithm 'minstrel_ht'
> 
> ie: redundant.
> wiphy_name(wiphy) is an inline for dev_name(&wiphy->dev)
> 
> So it's appropriate to use:
> 
> #define wiphy_<level>(wiphy, fmt, arg...) dev_<level>(&wiphy->dev, fmt, ##arg) 
> 
> and the output becomes:
> 
> [   41.261941] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Everyone OK w/ this version?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
