From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 08 Aug 2011 15:18:44 +0200
Message-ID: <1312809524.4372.29.camel@jlt3.sipsolutions.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	 <1312808784.17202.39.camel@mojatatu> (sfid-20110808_150704_677066_57A7292F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:59986 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab1HHNSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 09:18:48 -0400
In-Reply-To: <1312808784.17202.39.camel@mojatatu> (sfid-20110808_150704_677066_57A7292F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the Cc Jamal.

On Mon, 2011-08-08 at 09:06 -0400, jamal wrote:

> The challenge is going to be with wireless where the underlying
> bandwidth changes (and therefore the optimal queue size varies
> more frequently). The problem with active queue management is
> getting the feedback loop to be more accurate and i think there
> will be challenges with wired devices.
> I notice that you dont have any wireless devices;
> but it would be nice for someone to check this out on wireless.
> CCing Johannes - maybe he has some insight.

Well, the wireless case is curious, and has a whole bunch of corner
cases, since it's not necessarily PtP, it can be PtMP!

But considering the most basic case of us being a client connecting to
an AP first: yes, the bandwidth will change dynamically, I don't know
what impact this has on BQL, Tom, maybe you can think about this a bit?

The second big challenge in wireless is the PtMP case: if we're acting
as an AP, then we typically have four queues for any number of remote
endpoints with varying bandwidth. I haven't found a good way to handle
this, we can't have hardware queues per station (most HW is simply not
capable of that many queues) but technically we would want to make the
queue limits depend on the peer...

Since I just returned from vacation I have tons of email to dig through
I'll have to keep this short for now, but I'm definitely interested.

johannes

