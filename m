From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Fri, 1 Sep 2006 20:55:48 +0200
Message-ID: <200609012055.48799.mb@bu3sch.de>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156> <20060901163558.GB13815@bougret.hpl.hp.com>
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
	Denis Vlasenko <vda@ilport.com.ua>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:63698
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750745AbWIAS52
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 14:57:28 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060901163558.GB13815@bougret.hpl.hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 01 September 2006 18:35, Jean Tourrilhes wrote:
> On Fri, Sep 01, 2006 at 08:54:00AM +0200, Johannes Berg wrote:
> > On Thu, 2006-08-31 at 10:12 -0700, Jean Tourrilhes wrote:
> > 
> > > 	And I strongly disagree with your disagrement ;-)
> > 
> > You're of course free to do that :) But let me explain.
> 
> 	And my explanation is even more simple : let's not throw the
> baby with the bathwater. If things are broken in WE, let's just fix
> it. I've always worked with people working with me.

Fixing would require redesign of some parts, so incompatible ABI
changes. nl80211 actually _does_ fix it by rewriting the stuff.

> 	Note that one thing that worry me with your approach is
> footprint. I've used various embedded devices over the years, such as
> the Gumstix (4MB Flash), and this is why WE was optimised for
> footprint.

Can you please explain in more detail, how WE + the WE-netlink wrapper
has lower footprint than this netlink-only layer?

> > Actually, no. But that's beside the point anyway. Actually, I think that
> > publishing WE over netlink was a mistake.
> 
> 	I don't understand, in the last few years everybody was
> clamoring for a Netlink interface, and now that it is done, people say
> it is a stupid thing. Any specifics ?
> 
> > The real
> > problem with WE is, as I previously said, the ill-defined semantics of
> > both the user-space API and the in-kernel API.
> 
> 	I don't understand why you say it's ill defined, it 100%
> documented in the iwconfig man page.

It is horribly documented.
There is one big union and one magic "extra" parameter.
You have to guess (or look at other implementations) to find
out which element of the union or even if and how to use the extra
parameter. That's a real pain.
And after you found out which element to use, you have to figure
out somehow how to actually use that element. That's nontrivial,
escpecially because some flags (that are not documented) may
magically change the whole semantics of the contents.

In my opinion this
"One function signature fits all" design used in WE is simply
broken by design. It leads to exactly this big union, the
magic extra field and all the other magic flags here and there.
It is in no way clear from looking at the function signature
what to do. But it should be. nl80211 is designed much better here.

-- 
Greetings Michael.
