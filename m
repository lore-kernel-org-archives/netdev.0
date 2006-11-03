From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Fri, 03 Nov 2006 09:42:46 +0100
Message-ID: <1162543366.2923.3.camel@ux156>
References: <20061102223854.692274000@sipsolutions.net>
	 <20061102230013.960383000@sipsolutions.net> >
	 <1162513367.3381.11.camel@johannes.berg>
	 <200611022128.29060.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55244 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751352AbWKCIlm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 03:41:42 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611022128.29060.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 21:28 -0500, Michael Wu wrote:

> That's because TX might fail for reasons other than not getting an ACK. I 
> can't say I've actually seen this happen, so it might just be something left 
> over from tulip that doesn't need to be there now. (or perhaps it only 
> happens when there's something really bad going on) However, what's so bad 
> about letting drivers update some statistics if it is possible? If you remove 
> ieee80211_dev_stats, please provide some other way for drivers to access 
> struct net_device_stats.

Well, you were only changing the master netdev's stats, which isn't
really useful because you want to change the device that transmitted the
frame. But you cannot, because you don't have access to it. In general,
the stack should be doing this, so if some other tx errors are possible
maybe we should add a flag to the tx status.

johannes
