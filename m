From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v2] bridge: do not expire mdb entry as long as
 bridge still uses it
Date: Fri, 26 Apr 2013 20:50:23 +0800
Message-ID: <20130426125023.GA4812@gondor.apana.org.au>
References: <1366878083-22797-1-git-send-email-amwang@redhat.com>
 <20130425083704.GA27420@gondor.apana.org.au>
 <1366884421.11488.4.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48184 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750939Ab3DZMua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 08:50:30 -0400
Content-Disposition: inline
In-Reply-To: <1366884421.11488.4.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 06:07:01PM +0800, Cong Wang wrote:
> On Thu, 2013-04-25 at 16:37 +0800, Herbert Xu wrote:
> > 
> > As you're saying the bridge interface's subscription is expiring
> > incorrectly, the question is why aren't we receiving those group
> > reports from ourselves, which should be sent out periodically if
> > we were subscribed to the group?
> 
> I thought IGMP report is optional as long as the multicast traffic is
> still running. If it is mandatory, I don't see any IGMP report sending
> out from guest, so the bug is in IPv4 multicast code rather than bridge
> code.
> 
> But this can't explain why guests can communicate with each other. :)

OK, if there is no querier in the network then our current default
behaviour is indeed broken because we won't get the reports needed
to sustain the subscriptions.

So we need to do two things:

1) Fix the group timeout mechanism to only arm the timer when a
corresponding query is received.
2) Resume sending queries when leave is received if the user makes
a querier.

Let me know if you'd like to work on this, otherwise I can take
a look at it next week.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
