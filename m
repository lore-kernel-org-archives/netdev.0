From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 23:50:10 +0100
Message-ID: <20090109225010.GB4819@1wt.eu>
References: <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com> <20090109221744.GA4819@1wt.eu> <20090109224258.GA10257@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1359 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbZAIWum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:50:42 -0500
Content-Disposition: inline
In-Reply-To: <20090109224258.GA10257@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 10, 2009 at 01:42:58AM +0300, Evgeniy Polyakov wrote:
> On Fri, Jan 09, 2009 at 11:17:44PM +0100, Willy Tarreau (w@1wt.eu) wrote:
> > However I'm OK for the !timeo before release_sock/lock_sock. I just
> > don't know if we can put the rest of the if above or not. I don't
> > know what changes we're supposed to collect by doing release_sock/
> > lock_sock before the if().
> 
> Not to interrupt the discussion, but for the clarification, that
> release_sock/lock_sock is used to process the backlog accumulated while
> socket was locked. And while dropping additional pair before the final
> release is ok, but moving this itself should be thought of twice.

Nice, thanks Evgeniy. So it makes sense to move only the !timeo test
above since it's not dependant on the socket, and leave the rest of
the test where it currently is. That's what Eric has proposed in his
latest patch.

Well, I'm now trying to educate myself on the send part. It's still
not very clear to me and I'd like to understand a little bit better
why we have this corruption problem and why there is a difference
between sending segments from memory and sending them from another
socket where they were already waiting.

I think I'll put printks everywhere and see what I can observe.
Knowing about the GSO/SG workaround already helps me enable/disable
the bug.

Regards,
Willy

