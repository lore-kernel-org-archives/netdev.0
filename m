From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Required sequence to set wireless parameters? (was:
	2.6.29-rc8: Reported regressions from 2.6.28)
Date: Thu, 19 Mar 2009 11:24:41 -0400
Message-ID: <20090319152441.GB3587@tuxdriver.com>
References: <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu> <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com> <1237317742.31814.28.camel@johannes.local> <b6a2187b0903181958ke11abe7tdcbc4efeb950954d@mail.gmail.com> <b6a2187b0903182149x77e416ecuf73be2970173c601@mail.gmail.com> <1237455534.5100.56.camel@johannes.local> <1237455534.5100.56.camel@johannes.local> <20090319141311.GA3587@tuxdriver.com> <200903191602.58790.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, jeff.chua.linux@gmail.com,
	mingo@elte.hu, torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38941 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753763AbZCSPaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 11:30:52 -0400
Content-Disposition: inline
In-Reply-To: <200903191602.58790.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 19, 2009 at 04:02:56PM +0100, Frans Pop wrote:
> John W. Linville wrote:
> > On Thu, Mar 19, 2009 at 10:38:54AM +0100, Johannes Berg wrote:
> >> On Thu, 2009-03-19 at 12:49 +0800, Jeff Chua wrote:
> >> > # this needs patch to work ...
> >> > iwconfig wlan0 mode Managed
> >> > ifconfig wlan0 up
> >> > iwconfig wlan0 essid xxx
> >> > iwconfig wlan0 key restricted xxx
> >> > iwconfig wlan0 ap auto channel auto
> >> 
> >> If you swap the key and essid lines, it will probably always work. But
> >> I've yet to analyse your data to see why it doesn't in the other case.
> > 
> > That is what I was going to suggest.  I go so far as to say that you
> > should set everything else before doing the "iwconfig wlan0 essid
> > xxx" bit.
> 
> Mostly just curious, but is that actually required by some wireless 
> standard? If not, is it really reasonable to ask userland to do things in 
> that particular order?
> 
> Reason I ask is that for example when writing wireless support for e.g. a 
> distro installation system, it seems most logical to *first* ask the user 
> what network (ESSID) he wants to connect to. Next to check if we can 
> connect to that network without additional authentication and only then, 
> if needed, ask for keys etc.
> If it's not possible to set that info in that logical order that seems 
> rather restrictive to me and would probably mean that you'd have to reset 
> AP, ESSID and possibly other settings before each incremental attempt.

You can ask the user for the data in whatever order you like, but
when you are done collecting it you should issue the "iwconfig wlan0
essid xxx" command (or execute the SIOCSIWESSID ioctl) last.  IMHO,
it is silly to even bother setting the SSID before you have set any
required key or (if you so choose) selecting an AP or channel.

This is a limitation of the wireless extensions API -- nothing in
the API really defines when an association should be triggered.
The mac80211 component uses the setting of the SSID as the trigger
for association.  AFAIK, this ordering should work with all other
drivers as well.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
