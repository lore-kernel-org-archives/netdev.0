From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 15:55:14 -0700
Message-ID: <20060921225514.GA26850@bougret.hpl.hp.com>
References: <44F356DF.9000000@linux.intel.com> <20060921190126.4d884c44@logostar.upir.cz> <1158865436.27546.23.camel@localhost.localdomain> <4512EC5C.1030807@linux.intel.com> <1158870634.5769.21.camel@localhost.localdomain> <4512F876.7000203@linux.intel.com> <20060922003844.6817f22b@logostar.upir.cz>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mabbas <mabbas@linux.intel.com>, Dan Williams <dcbw@redhat.com>,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:48070 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S932098AbWIUW6d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 18:58:33 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060922003844.6817f22b@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 12:38:44AM +0200, Jiri Benc wrote:
> On Thu, 21 Sep 2006 13:39:18 -0700, mabbas wrote:
> > I can fix the patch to do just that if we agree on that.
> 
> Well, we need a flag indicating whether we are associated or not. I don't
> know about such a flag in WE (hopefully we will have that in nl80211).

	SIOCSIWAP is that flag.
	Sorry, but the way "struct sockaddr" is designed did not allow
for having an explicit flag, otherwise I would have done it like for
every other commands.

> Now we have two possibilities:
> 
> (a) If a fixed BSSID is set (via SIOCSIWAP), return it from SIOCGIWAP. There
> is no way to find out whether we are associated or not. The behaviour is
> also inconsistent with the case when no fixed BSSID is set - SIOCGIWAP
> returns all zeros or some (random from our POV) BSSID then. So, when you
> get a BSSID from SIOCGIWAP, to determine what that means you need to know
> if there was a fixed BSSID set. To do that you need to get a BSSID from
> SIOCGIWAP. The chicken and egg problem?
> 
> (b) SIOCSIWAP returns zeros when we are not associated, BSSID otherwise.
> There is no way to find out if you set a fixed BSSID or not. If you
> accidentally set a fixed BSSID you will have a hard time finding out why
> your card is not associating.
> 
> Jean, are there any other possibilities?

	Yes, dropping SIOCSIWAP (set) entirely, and keep only
SIOCGIWAP (get).

> If not, (b) seems much more reasonable to me, because:
> - The value returned from SIOCGIWAP has a well-defined meaning independent
>   of the current configuration of the interface.
> - Dan wants that.

	(b) is the correct answer ;-)
	We need to be pragmatic. Very few people need to set a fixed
BSSID. I would even venture to say that in the case of most people
setting a fixed BSSID, it's an error and they should not do it (it
kills roaming, which is a desirable feature). I've yet to find a card
which scanning is broken to the point that you need to fudge the
BSSID.
	There are some drivers that don't support SIOCSIWAP (set), and
it's usually not a problem, users are not complaining about it. That's
why I claim we could drop the (set) support. Of course, we can't do it
because one PhD student at Berkeley need the feature ;-)
	If a program like NetworkManager want to play advanced tricks
with the BSSID and want to know if the user has set a fixed BSSID, it
can monitor SIOCSIWAP events and remember the state.

>  Jiri

	Regards,

	Jean
