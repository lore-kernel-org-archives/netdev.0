From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Fri, 22 Sep 2006 10:05:30 -0400
Message-ID: <1158933931.2624.8.camel@localhost.localdomain>
References: <44F356DF.9000000@linux.intel.com>
	 <20060921190126.4d884c44@logostar.upir.cz>
	 <1158865436.27546.23.camel@localhost.localdomain>
	 <4512EC5C.1030807@linux.intel.com>
	 <1158870634.5769.21.camel@localhost.localdomain>
	 <1158913937.5368.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mabbas <mabbas@linux.intel.com>, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:14513 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932501AbWIVOEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 10:04:30 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1158913937.5368.10.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-22 at 10:32 +0200, Johannes Berg wrote:
> On Thu, 2006-09-21 at 16:30 -0400, Dan Williams wrote:
> 
> > That's kind a hole in the WE API.  In this case, I think, SIOCGIWAP
> > should always return the BSSID of the current association, or none if
> > there is no association.
> 
> I was never sure if it was a hole or just a lack of clearly defined
> semantics (duh, I should probably look at the iwconfig code......)
> 
> > Doing an iwconfig ap xx:xx:xx:xx:xx:xx should make the driver internally
> > locked to that BSSID, such that until you clear that lock, SIOCGIWAP
> > should only show either that BSSID or 00:00:00:00:00:00.  SIOCGIWAP
> > should not return a valid BSSID when there is no association.
> > 
> > Hopefully nl80211 can fix this omission in WE.
> 
> I think I have addressed this already.
> 
> +       /* set access point BSSID for userspace roaming */
> +       NL80211_CMD_SET_BSSID,
> ...
> +
> +       /* BSSID to associate to, only used when roaming control
> +        * is in userspace */
> +       NL80211_ATTR_BSSID,
> +
> ...
> 
> +       /* get current association information, if not associated then
> +        * the BSSID attribute is not present in response */
> +       NL80211_CMD_GET_ASSOCIATION,
> 
> as well as in the compatibility document:
> 
> +SIOCSIWAP
> +  -> if bssid is all-ones: set roaming to kernel, reassociate
> +  -> if bssid is all-zeroes: set roaming to kernel
> +  -> otherwise: set roaming to userspace, set bssid
> +
> +SIOCGIWAP
> +  -> get association parameters and fill return bssid appropriately
> 
> 
> I think that should do what you need, no?

Looks like it, yes.  As long as there are separate mechanisms for the
getting/setting a 'locked' BSSID, and a separate attribute for the
currently associated access point (if any).  Which this looks like it
would provide.

Thanks!
Dan


