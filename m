From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [RFC] Alternate WE-21 support (core API)
Date: Wed, 6 Sep 2006 14:30:53 -0700
Message-ID: <20060906213053.GA21719@bougret.hpl.hp.com>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831135112.GA6097@jm.kir.nu> <1157032805.16040.21.camel@ux156> <20060906205538.GA29767@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jouni Malinen <jkmaline@cc.hut.fi>, netdev@vger.kernel.org,
	Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:20735 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1751669AbWIFVld
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 17:41:33 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060906205538.GA29767@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2006 at 04:55:44PM -0400, John W. Linville wrote:
> On Thu, Aug 31, 2006 at 04:00:05PM +0200, Johannes Berg wrote:
> > On Thu, 2006-08-31 at 06:51 -0700, Jouni Malinen wrote:
> > 
> > > I don't know about the others, but long/short retry limits have users
> > > (e.g., Host AP driver) and these drivers are currently forced to use a
> > > hack to do this without this cleanup. Furthermore, this part does not
> > > add a new ioctl.
> > 
> > It does, however, add new parameters and things that'd need to be
> > translated in the compat layer later. Hence, even there, I'd prefer to
> > add them directly into nl80211. However, the compat code for that
> > shouldn't be that bad, so I can see that as a softer target :) But I
> > don't want to see new ioctls for sure.
> 
> OK, I think we all agree that there are good parts to Jean's WE-21
> patch.  Below I've made an attempt to separate the wheat from the chaff
> (or to cut the baby in half)...

	Wow, some progress instead of empty talks ! I fully appreciate
your effort in moving forward on this issue...
	Is there anything I can do to help you ? The driver patches
should be straighforward as they don't use any of the features you
dropped (those patches using the new features were not sent to you to
be more precise).

> Is this patch acceptable to the group?  Does it make things better?
> Or worse?  Did I leave-out anything that should still go in?  Did I
> take too much?
> 
> Let me know what you think...?

	As far as I can see, your patch looks technically correct.

> John

> + * V20 to V21
> + * ----------
> + *	- Remove (struct net_device *)->get_wireless_stats()
> + *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
> + *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
> + *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI

	Personally, I would also add this :

+ *	- Power/Retry relative values no longer * 100000

	Three reason :
		1) It's a cleanup and does not add any new feature
		2) It does not change the rest of the patches
		3) Userspace part has already gone in distro, not
including this bit would mean breaking userspace.

	The other bits can be included at a later time ;-)
	Thanks, and have fun...

	Jean
