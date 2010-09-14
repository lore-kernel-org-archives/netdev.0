From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Date: Tue, 14 Sep 2010 17:14:39 +0200
Message-ID: <20100914151439.GA13028@redhat.com>
References: <20100914142814.GA8744@redhat.com>
 <1284474988.3704.10.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7594 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752888Ab0INPVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 11:21:00 -0400
Content-Disposition: inline
In-Reply-To: <1284474988.3704.10.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 04:36:28PM +0200, Johannes Berg wrote:
> On Tue, 2010-09-14 at 16:28 +0200, Michael S. Tsirkin wrote:
> > I am running 2.6.36-rc4 on T60 with an iwlagn wireless card:
> > 03:00.0 Network controller: Intel Corporation PRO/Wireless 5100 AGN [Shiloh] Network Connection
> > 
> > I was compiling a large file which stressed the box heavily, and the
> > following warning in net/mac80211/scan.c triggered:
> > 
> >         /*
> >          * It's ok to abort a not-yet-running scan (that
> >          * we have one at all will be verified by checking
> >          * local->scan_req next), but not to complete it
> >          * successfully.
> >          */
> >         if (WARN_ON(!local->scanning && !aborted))
> >                 aborted = true;
> > 
> > dmesg below:
> > 
> > [84379.361297] ------------[ cut here ]------------
> > [84379.361307] WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed+0x43/0x17f()
> 
> > Should this happen? Does anyone care?
> > I am not sure how reproducible this is.
> 
> No, it shouldn't happen. But there are various races in iwlwifi that can
> cause this. Stanislaw has fixed them recently, but it's a fairly large
> patchset. I'm not sure, but I don't think this is really new in .36.
> 
> johannes

So ... get back to you after 2.6.37?

-- 
MST
