From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next v2] bridge: do not expire mdb entry as long as
 bridge still uses it
Date: Thu, 25 Apr 2013 16:37:04 +0800
Message-ID: <20130425083704.GA27420@gondor.apana.org.au>
References: <1366878083-22797-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46281 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756122Ab3DYIhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:37:11 -0400
Content-Disposition: inline
In-Reply-To: <1366878083-22797-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 04:21:23PM +0800, Cong Wang wrote:
> This bug can be observed in virt environment, when a KVM guest
> communicates with the host via multicast. After some time (should
> be 260 sec, I didn't measure), the multicast traffic suddenly
> terminates.
> 
> This is due to the mdb entry for bridge itself expires automatically,
> it should not expire as long as the bridge still generates multicast
> traffic. It should expire when the bridge leaves the multicast group,
> OR when there is no multicast traffic on this bridge.
> 
> I fix this by adding another bool which is set when there is
> multicast traffic goes to the bridge, cleared in the expire timer and
> when IGMP leave is received. I ran omping for 15 minutes, everything
> looks good now.
> 
> This might not be the best fix, but might be the simplest fix.
> 
> (Adam, this problem is probably different with your problem,
> at least this problem can _not_ be workarounded by setting
> querier to 1.)

Sorry, your patch still makes no sense to me.  All you're doing
is extending the bridge interface's subscription status every
time a multicast packet for that group is sent to to the bridge.

We should only be extending the status if we get a group report.

As you're saying the bridge interface's subscription is expiring
incorrectly, the question is why aren't we receiving those group
reports from ourselves, which should be sent out periodically if
we were subscribed to the group?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
