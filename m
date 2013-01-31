From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: avoid "wdev_id may be used uninitialized"
Date: Thu, 31 Jan 2013 21:51:37 +0100
Message-ID: <1359665497.8415.102.camel@jlt4.sipsolutions.net>
References: <1359504662-23561-1-git-send-email-swarren@wwwdotorg.org>
	  (sfid-20130130_011118_335925_03B80596) <1359532679.8010.1.camel@jlt4.sipsolutions.net>
	 <51094F10.60605@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stephen Warren <swarren@nvidia.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56309 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734Ab3AaUv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 15:51:26 -0500
In-Reply-To: <51094F10.60605@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-30 at 09:49 -0700, Stephen Warren wrote:
> On 01/30/2013 12:57 AM, Johannes Berg wrote:
> > On Tue, 2013-01-29 at 17:11 -0700, Stephen Warren wrote:
> >> From: Stephen Warren <swarren@nvidia.com>
> >>
> >> Silence the following:
> >> net/wireless/nl80211.c: In function '__cfg80211_wdev_from_attrs.clone.119':
> >> net/wireless/nl80211.c:57:6: warning: 'wdev_id' may be used uninitialized in this function
> >>
> >> ... by always initializing wdev_id to zero. I assume that wiphy_idx and
> >> ifidx are set to -1 for similar reasons, so this change simply propagates
> >> the same workaround.
> >>
> >> In practice, this warning is false, since wdev_id is both set and used
> >> under the condition if (have_wdev_id). However, at least my compiler
> >> can't be coerced into realizing this; almost any code between the if
> >> blocks that set and use the variable causes this warning.
> > 
> > I don't see this warning? What compiler are you using?
> 
> I'm using gcc-4.5.3 for ARM. I checked with gcc-4.6.3 and gcc-4.7.2 and
> indeed I don't see the warning there.

Interesting. So should I keep it or remove it? I guess in this
particular instance it doesn't matter all that much. In other cases I'd
be more against changing it I guess.

johannes
