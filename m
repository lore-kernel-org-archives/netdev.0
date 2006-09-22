From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 17:57:43 -0700
Message-ID: <20060922005743.GB27052@bougret.hpl.hp.com>
References: <44F356DF.9000000@linux.intel.com> <20060921190126.4d884c44@logostar.upir.cz> <1158865436.27546.23.camel@localhost.localdomain> <4512EC5C.1030807@linux.intel.com> <1158870634.5769.21.camel@localhost.localdomain> <4512F876.7000203@linux.intel.com> <20060922003844.6817f22b@logostar.upir.cz> <20060921225514.GA26850@bougret.hpl.hp.com> <20060922004235.GA7322@instant802.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, mabbas <mabbas@linux.intel.com>,
	Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:21958 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S932155AbWIVA7c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 20:59:32 -0400
To: Jouni Malinen <jkm@devicescape.com>
Content-Disposition: inline
In-Reply-To: <20060922004235.GA7322@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 05:42:35PM -0700, Jouni Malinen wrote:
> On Thu, Sep 21, 2006 at 03:55:14PM -0700, Jean Tourrilhes wrote:
> 
> > > Jean, are there any other possibilities?
> > 
> > 	Yes, dropping SIOCSIWAP (set) entirely, and keep only
> > SIOCGIWAP (get).
> 
> I don't think that this would be acceptable.

	I should have put smileys ;-) You know that's it's not my
style to rock the boat, so SIOCSIWAP won't go away anytime soon.
	And actually, I would be more likely to remove RTS/CTS and
Frag first ;-)

> > 	We need to be pragmatic. Very few people need to set a fixed
> > BSSID. I would even venture to say that in the case of most people
> > setting a fixed BSSID, it's an error and they should not do it (it
> > kills roaming, which is a desirable feature). I've yet to find a card
> > which scanning is broken to the point that you need to fudge the
> > BSSID.
> 
> Maybe very few _people_ use it directly, but please keep in mind that
> programs like wpa_supplicant may control roaming and do it by using this
> SIOCSIWAP.

	Yep, fully agree. And in the part of the e-mail you left out,
I described this kind of need and a solution for those specific apps
(catching SIOCSIWAP iwevents).
	Actually, I'm surprised that those apps don't make more use of
the SIOCS* events. They are a good way to monitor the user and other
apps doing change to the wireless config, and could be used to adapt
to that.

> In addition, being able to limit AP selection to one specific
> BSSID can be quite useful for number of uses.

	As I said, I've found very few cases where the end-user need
to play with those.

> > 	There are some drivers that don't support SIOCSIWAP (set), and
> > it's usually not a problem, users are not complaining about it. That's
> > why I claim we could drop the (set) support. Of course, we can't do it
> > because one PhD student at Berkeley need the feature ;-)
> 
> There's more than one PhD student needing this and I would be very much
> against removing it.

	Well, so make it one PhD student and one Linux driver hacker ;-)

> Jouni Malinen

	Have fun...

	Jean

