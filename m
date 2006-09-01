From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Sat, 2 Sep 2006 00:27:21 +0200
Message-ID: <20060901222721.GC10285@p15091797.pureserver.info>
References: <20060830005655.GA8405@bougret.hpl.hp.com> <1157093640.2878.26.camel@ux156> <20060901163558.GB13815@bougret.hpl.hp.com> <200609012055.48799.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, "John W. Linville" <linville@tuxdriver.com>,
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
Received: from deine-taler.de ([217.160.107.63]:46035 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750978AbWIAW1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 18:27:22 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200609012055.48799.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-09-01 20:55 Michael Buesch wrote:

> > > The real
> > > problem with WE is, as I previously said, the ill-defined semantics of
> > > both the user-space API and the in-kernel API.
> > 
> > 	I don't understand why you say it's ill defined, it 100%
> > documented in the iwconfig man page.
> 
> It is horribly documented.

Jean, you have certainly done more for wireless support in Linux
than most of us and definitely for a much longer time. However I
have to admit that Michael has a point here. The iwconfig manual
page doesn't reference a single IO control macro, the big union or
a single flag. Reading source code doesn't make things a lot
easier, because the drivers do things quite differently or not at
all. I had to check by trial and error, what the right semantics
of controls might be. For example I spent hours for the controls
SIOCGIWFREQ and SIOCSIWFREQ, because I had no idea what the exact
semantics of IW_FREQ_FIXED and IW_FREQ_AUTO are and whether it's
only a SIOCGIWFREQ issue or not.

I fear that user space programmers are facing the same issues.
This might be the reason, why we don't have a larger number of
graphical widgets that show signal strength and support AP
selection.

Jean, you could do us all a favour, if you could start to write
down, what you know about the wireless extensions. This would help
us folks, who do not have your long experience, a lot.

> In my opinion this
> "One function signature fits all" design used in WE is simply
> broken by design. It leads to exactly this big union, the
> magic extra field and all the other magic flags here and there.

I second this. Simple special structs for the control pairs would
have made the task of understanding the interface much more easier
and even simpler to document. From my point of view it's a
fundamental issue, which could be mitigated by documentation a
little bit. But in my opinion it might be about time to put the
wireless extension API to rest and replace it by something better.
Johannes actually tries to do this. I have also trouble to
understand, how adding new controls to the old API should help
here. It actually increases the footprint for the compatibility
layer and there has not exactly been a lot of pressure to
introduce these controls right now.

Ciao,

Uli

-- 
VGER BF report: U 0.5
