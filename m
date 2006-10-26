From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] [PATCH 0/3] Add Regulatory Domain support to d80211
Date: Thu, 26 Oct 2006 16:43:35 +0200
Message-ID: <1161873815.2866.39.camel@ux156>
References: <20061024140212.GB17543@devicescape.com>
	 <C86180A8C204554D8A3323D8F6B0A29F018523A5@dhost002-46.dex002.intermedia.net>
	 <43e72e890610241503r692975dfx65b2eab987ffbb3d@mail.gmail.com>
	 <200610241853.03135.flamingice@sourmilk.net>
	 <43e72e890610251043y22fb9ce6ne5e036dd58f36505@mail.gmail.com>
	 <1161813628.8884.14.camel@johannes.berg>
	 <1161873333.2927.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Simon Barber <simon@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jean Tourrilhes <jt@hpl.hp.com>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44194 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1423539AbWJZOmo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 10:42:44 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1161873333.2927.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-10-26 at 10:35 -0400, Dan Williams wrote:

> >  - I'd like to see a header cleanup, it's necessary. Part of the problem
> >    here is all the sub-ioctl WE foo. Clean that up by moving them into
> >    cfg80211 as required, there's basically one user, wpa_supplicant (and
> >    maybe hostapd), screw the others if there are any

Oh, right, by sub-ioctl I was referring to the mess of the private
ioctls d80211 has for WE, including sub-items again.

> While wpa_supplicant is certainly the main client for stuff directly
> related to setting up a connection, there are quite a few other users of
> general WE calls to pull information out of the card, or to receive scan
> events. 

Of course.

> So if you want maximum compatibility for a limited amount of
> work, you can probably consider wpa_supplicant the only client of
> 
> (s = set, g = get)
> 
> 1) [s|g] ENCODEEXT
> 2) [s|g] AUTH
> 3) [s|g] MLME
> 4) [s] RATE
> 5) [s] FREQ
> 6) [s] SENS
> 7) [s] AP
> 8) [s|g] RTS
> 9) [s|g] FRAG
> 10)[s|g] GENIE
> 11)[s|g] PMKSA

Sounds about right to me. I did actually intend to keep these intact but
drop the private ones with the 10xx sub-numbers.

> 4) [s|g] POWER (power management does this, not wpa_supplicant)

Does it work for any card?

johannes
