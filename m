From: Frans Pop <elendil@planet.nl>
Subject: Re: Required sequence to set wireless parameters?
Date: Thu, 19 Mar 2009 20:24:27 +0100
Message-ID: <200903192024.30562.elendil@planet.nl>
References: <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com> <200903191602.58790.elendil@planet.nl> <1237481630.5100.92.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	jeff.chua.linux@gmail.com, mingo@elte.hu,
	torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, bunk@kernel.org,
	akpm@linux-foundation.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:58509 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754939AbZCSTYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 15:24:34 -0400
In-Reply-To: <1237481630.5100.92.camel@johannes.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 March 2009, Johannes Berg wrote:
> Wext is a mess, and we've known that for a long time... But no, the
> sequence should _not_ be required, it's just _easier_ for the kernel,
> and as such has a better probability of succeeding if there are
> problems, it should still work though.
>
> However, one thing that will _not_ work is this:
> iwconfig wlan0 essid xyz
> iwconfig wlan0 key s:xyz
>
> you still need:
> iwconfig wlan0 ap any
>
> or anything similar after setting the key to trigger the kernel to do
> something.

OK. Thanks for the info.

> > Reason I ask is that for example when writing wireless support for
> > e.g. a distro installation system, it seems most logical to *first*
> > ask the user what network (ESSID) he wants to connect to. Next to
> > check if we can connect to that network without additional
> > authentication and only then, if needed, ask for keys etc.
> > If it's not possible to set that info in that logical order that
> > seems rather restrictive to me and would probably mean that you'd
> > have to reset AP, ESSID and possibly other settings before each
> > incremental attempt.
>
> That's a pretty wrong argument, nothing says your software cannot
> collect all the information and then give it to the kernel at once
> later, I think... In fact, this is required anyway when you use RSN or
> WPA (wpa_supplicant needs all information at once), for example.

Well, the thing is that we'll already have tried just setting essid to 
check if it's an open network. However, I can see the point of needing to 
set the essid _again_ after asking the key info and setting that.

I can also see how you might have to unset some settings in some cases, 
for example if the NIC has already associated with the wrong network 
(e.g. because there's a totally open network in range).

Our current logic (in Debian Installer) definitely needs improving and 
these pointers will help. Thanks.
