From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Thu, 25 Aug 2011 08:29:45 -0700
Message-ID: <CA+mtBx8mb0pAqVH19WK=e9LuLeyvnNTybROOURD2Rg6UtYe+bw@mail.gmail.com>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<1312808784.17202.39.camel@mojatatu>
	<1312809524.4372.29.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:3897 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744Ab1HYP3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 11:29:47 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p7PFTku8019142
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:29:46 -0700
Received: from yxp4 (yxp4.prod.google.com [10.190.4.196])
	by wpaz17.hot.corp.google.com with ESMTP id p7PFSkYT007867
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:29:45 -0700
Received: by yxp4 with SMTP id 4so2143510yxp.7
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:29:45 -0700 (PDT)
In-Reply-To: <1312809524.4372.29.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, the wireless case is curious, and has a whole bunch of corner
> cases, since it's not necessarily PtP, it can be PtMP!
>
> But considering the most basic case of us being a client connecting to
> an AP first: yes, the bandwidth will change dynamically, I don't know
> what impact this has on BQL, Tom, maybe you can think about this a bit?
>
BQL is dynamic, and will increase the queue limit more aggressively
than decrease it.  So for instance, we can track the largest queue
needed over 30 seconds which should be stable in the presence even in
the presence of fluctuating bandwidth.  The thing that worries me is
rather the HW queues conform to the queue characteristics described in
the patch.  If transmit completions are random and not regular, BQL
probably can't function well.

If you'd like to bring this up on some wireless devices that would be
great, I don't have easy access to any right now, but I can try to
help otherwise.


> The second big challenge in wireless is the PtMP case: if we're acting
> as an AP, then we typically have four queues for any number of remote
> endpoints with varying bandwidth. I haven't found a good way to handle
> this, we can't have hardware queues per station (most HW is simply not
> capable of that many queues) but technically we would want to make the
> queue limits depend on the peer...
>
> Since I just returned from vacation I have tons of email to dig through
> I'll have to keep this short for now, but I'm definitely interested.
>
> johannes
>
>
