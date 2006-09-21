From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Fri, 22 Sep 2006 00:38:44 +0200
Message-ID: <20060922003844.6817f22b@logostar.upir.cz>
References: <44F356DF.9000000@linux.intel.com>
	<20060921190126.4d884c44@logostar.upir.cz>
	<1158865436.27546.23.camel@localhost.localdomain>
	<4512EC5C.1030807@linux.intel.com>
	<1158870634.5769.21.camel@localhost.localdomain>
	<4512F876.7000203@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:17856 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932080AbWIUWis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 18:38:48 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <4512F876.7000203@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Sep 2006 13:39:18 -0700, mabbas wrote:
> I can fix the patch to do just that if we agree on that.

Well, we need a flag indicating whether we are associated or not. I don't
know about such a flag in WE (hopefully we will have that in nl80211).

Now we have two possibilities:

(a) If a fixed BSSID is set (via SIOCSIWAP), return it from SIOCGIWAP. There
is no way to find out whether we are associated or not. The behaviour is
also inconsistent with the case when no fixed BSSID is set - SIOCGIWAP
returns all zeros or some (random from our POV) BSSID then. So, when you
get a BSSID from SIOCGIWAP, to determine what that means you need to know
if there was a fixed BSSID set. To do that you need to get a BSSID from
SIOCGIWAP. The chicken and egg problem?

(b) SIOCSIWAP returns zeros when we are not associated, BSSID otherwise.
There is no way to find out if you set a fixed BSSID or not. If you
accidentally set a fixed BSSID you will have a hard time finding out why
your card is not associating.

Jean, are there any other possibilities?

If not, (b) seems much more reasonable to me, because:
- The value returned from SIOCGIWAP has a well-defined meaning independent
  of the current configuration of the interface.
- Dan wants that.

 Jiri

-- 
Jiri Benc
SUSE Labs
