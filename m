From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch net-next 2/3] bridge: only expire the mdb entry when
 query is received
Date: Tue, 30 Apr 2013 11:22:21 +0800
Message-ID: <20130430032221.GA20471@gondor.apana.org.au>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
 <1367220392-17496-2-git-send-email-amwang@redhat.com>
 <1367291857.3216.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:54746 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755527Ab3D3DW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 23:22:26 -0400
Content-Disposition: inline
In-Reply-To: <1367291857.3216.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 11:17:37AM +0800, Cong Wang wrote:
> 
> One problem with this solution is that the temp mdb entry will no longer
> be expired automatically any more, since no query no timer.
> 
> I am wondering if we should find other way to fix it, for example,
> touching the timer as long as there is multicast traffic (non-IGMP).

mdb entries represent group subscriptions.  So what you're saying
is that group subscriptions aren't expiring.

Which isn't a problem at all since if there is no querier then group
subscriptions shouldn't expire.  There has to be at least one querier
in the network for this thing to work.  Otherwise it just degenerates
into a non-snooping switch, which is OK.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
