From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Thu, 31 Aug 2006 19:57:28 +0200
Message-ID: <200608311957.29206.mb@bu3sch.de>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157031138.16040.17.camel@ux156> <20060831171258.GD11836@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Javier Achirica <achirica@gmail.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>, Pavel Roskin <proski@gnu.org>,
	"Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	Jeroen Vreeken <pe1rxq@amsat.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:55216
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932422AbWHaR60
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 13:58:26 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060831171258.GD11836@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 31 August 2006 19:12, Jean Tourrilhes wrote:
> On Thu, Aug 31, 2006 at 03:32:18PM +0200, Johannes Berg wrote:
> > On Tue, 2006-08-29 at 17:56 -0700, Jean Tourrilhes wrote:
> > > 		o modulation
> > > 		o long/short retry
> > > 		o relative power saving.
> > 
> > I strongly disagree to these.
> 
> 	And I strongly disagree with your disagrement ;-)
> 
> > What's the point of adding more ioctls that we'll be implementing them
> > as wrappers around nl80211? Right now, those new ioctls/options aren't
> > implemented in *any* driver at all so they're completely useless, and
> > just add more to the pile of historic baggage we end up carrying around.
> > If we add these to mainline now, it's another thing we'll have to carry
> > for a long time even though it currently has no users...
> 
> 	I'm sorry to say it like this, but I hope my work will not be
> impacted by vaporware. How many drivers are currently converted to
> nl80211 ?
> 	I hope you realised that we are all trying to make 802.11
> support progress, each through our own ways. And that all those
> efforts are not conflicting with each other.

Yes. Why don't all people pull at the same rope end?

> 	The reason why those new features are good for you :
> 		o They give you a template on how you could implement
> those features in nl80211, saving you design time.
> 		o The goal is to replace private ioctls (driver
> specific) with standard ioctls. So, in other words, they actually
> *reduce* the historic baggage and make it easier to wrap around those
> functions if you want (I won't expect you to wrap around *every* WE).

I can't see how adding API reduces historic baggage.
I don't think it's possible to reduce something by adding stuff
to it.

> 	Personally, I still have not seen the point of nl80211, as the
> full Wireless Extension is already available over NetLink (have you
> tried it ?). But, I shut up my big mouth, and let you work freely on
> it, as a mark of respect for your work and intentions, and also
> because something good may come out of it.

Wireless Extensions are _horrible_ to implement and, most important,
to get right. Yes, you say it's easy. But you implemented it. I also
say understanding bcm43xx code is very easy. But I am sure that most
people will strongly disagree here.
I don't say you misdesigned WE. It was a good solution back when you
designed it (1996?).
WE is simply showing its age and should be replaced by nl80211.

> > I'd much prefer merging nl80211 and putting any really *new* stuff into
> > it directly. Of course this fragments the user space API for a while
> > since you need to use two APIs then for the time being to configure all
> > things, but we can move over all the rest of the configuration gradually
> > and before we end up in mainline with the new API we can have that
> > finished.
> 
> 	Good luck with that plan, user-space is notorious to not like
> entropy...
> 	Personally, I though that the plan that was more or less the
> consensus that the "new API" would be targeted mostly at the
> DeviceScape stack, as it seems difficult to offer the full feature set
> of that stack through WE. So, I would have expected the development of
> the "new API" to be somewhat in sync with the integration of the
> DeviceScape stack.

It is. Nobody says different. I think with "mainline" Johannes meant
the wireless-dev tree. Merging nl80211 with softmac would indeed not
make sense to me, too.

-- 
Greetings Michael.
