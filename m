From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Thu, 31 Aug 2006 15:32:18 +0200
Message-ID: <1157031138.16040.17.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
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
	Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
	Michael Buesch <mbuesch@freenet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43165 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932298AbWHaNc1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 09:32:27 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060830005655.GA8405@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-29 at 17:56 -0700, Jean Tourrilhes wrote:
> 		o modulation
> 		o long/short retry
> 		o relative power saving.

I strongly disagree to these.

What's the point of adding more ioctls that we'll be implementing them
as wrappers around nl80211? Right now, those new ioctls/options aren't
implemented in *any* driver at all so they're completely useless, and
just add more to the pile of historic baggage we end up carrying around.
If we add these to mainline now, it's another thing we'll have to carry
for a long time even though it currently has no users...

I'd much prefer merging nl80211 and putting any really *new* stuff into
it directly. Of course this fragments the user space API for a while
since you need to use two APIs then for the time being to configure all
things, but we can move over all the rest of the configuration gradually
and before we end up in mainline with the new API we can have that
finished.

Or putting it the other way round, I'm ok with
 * cleaning up the ssid mess
 * adding RCPI (we'll probably be using it in nl80211 anyway, so it's
   easier if we add it now and declare no support for other things)
 * getting rid of get_wireless_stats (good one!)
   [actually, I plan to get rid of wireless_handlers too]

johannes
