From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Fri, 01 Sep 2006 08:54:00 +0200
Message-ID: <1157093640.2878.26.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
	 <1157031138.16040.17.camel@ux156>
	 <20060831171258.GD11836@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
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
	Denis Vlasenko <vda@ilport.com.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:30084 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751214AbWIAGxu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 02:53:50 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060831171258.GD11836@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-31 at 10:12 -0700, Jean Tourrilhes wrote:

> 	And I strongly disagree with your disagrement ;-)

You're of course free to do that :) But let me explain.

> 	I'm sorry to say it like this, but I hope my work will not be
> impacted by vaporware. How many drivers are currently converted to
> nl80211 ?

None, I have to admit, of course. But I hope you realise that I can
impossibly convert all drivers at once and all by myself. I merely set
out a framework in which it is easy to add new features, new calls and
make things behave.

> 	The reason why those new features are good for you :
> 		o They give you a template on how you could implement
> those features in nl80211, saving you design time.

Gack. I'm inclined to not even respond to this, but I am convinced that
having all the unions and ill-defined semantics with one field having
multiple meanings is in no way saving me design time because it's part
of the problem I intend to completely avoid.

> 		o The goal is to replace private ioctls (driver
> specific) with standard ioctls. So, in other words, they actually
> *reduce* the historic baggage and make it easier to wrap around those
> functions if you want (I won't expect you to wrap around *every* WE).

Actually, trust me, you will. Once drivers can no longer handle WEs by
themselves because it's done centrally and over a shim layer in
cfg80211, you will.

> 	Personally, I still have not seen the point of nl80211, as the
> full Wireless Extension is already available over NetLink (have you
> tried it ?). 

Actually, no. But that's beside the point anyway. Actually, I think that
publishing WE over netlink was a mistake. See, my gripes with WE aren't
how the interface works. I could live with an ioctl based interface
forever, we have many of those and that's not really a problem. The real
problem with WE is, as I previously said, the ill-defined semantics of
both the user-space API and the in-kernel API. There are too many
special cases. Setting an ESSID to all-zeroes to disable something (or
was it all-ones to disable??) might have seemed like a good idea 10
years ago, but I certainly think that putting this implicit behaviour
into a modern interface is just asking for the kind of trouble that WE
has.

> But, I shut up my big mouth, and let you work freely on
> it, as a mark of respect for your work and intentions, and also
> because something good may come out of it.

:)

> 	Personally, I though that the plan that was more or less the
> consensus that the "new API" would be targeted mostly at the
> DeviceScape stack, as it seems difficult to offer the full feature set
> of that stack through WE. So, I would have expected the development of
> the "new API" to be somewhat in sync with the integration of the
> DeviceScape stack.

Not at all. I plan to support all drivers over nl80211, even those that
make no use of d80211. In fact, my current plan is to convert all
drivers to nl80211 and put WE as a shim layer. Yes, that'll rip out a
good part of your code, sorry about that.

> 	And if you look closely, you will realise the other features
> are also good for you ;-)

Not really. More ioctls aren't good. Even if they replace private ones.
Private ones were never really guaranteed anyway, so all the private
ones that generically make sense (and shouldn't just be in debugfs
instead...) shall be in nl80211 as well.

johannes
