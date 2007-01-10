From: James Morris <jmorris@namei.org>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Wed, 10 Jan 2007 09:15:15 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0701100913050.8582@d.namei>
References: <20070110072251.GA27030@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:44970 "EHLO
	mail5.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964874AbXAJOPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 09:15:18 -0500
To: Herbert Xu <herbert.xu@redhat.com>
In-Reply-To: <20070110072251.GA27030@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007, Herbert Xu wrote:

> Hi:
> 
> [IPSEC] flow: Cache negative security checks

We did some work in this part of the code a few months back -- IIRC it was 
resolved correctly from a security point of view.

(cc'ing Venkat & Paul for review).

> 
> This patch causes security policy denials to be cached instead of
> causing a relookup every time.  This is OK because we already cache
> positive security policy results which is strictly worse as far as
> security is concerned.  In particular, if the security system (not
> IPsec policies but the rules under security/) changes such that a
> positive result turns negative (denial), we will ignore it and
> continue to allow traffic through based on the cached policy.
> 
> So if the security folks actually care about this, they'd need to
> flush the flow cache whenever a relevant change is made to the
> security database.  Whether this is done or not does not affect
> this patch.
> 
> Given that we do want to cache positive results even in the presence
> of SELinux (otherwise we might as well disable flow.c entirely), it
> is natural to cache negative results too.
> 
> This patch also happens to fix a nasty bug where if an expiring
> flow entry that's not at the head happens to trigger a security
> denial, all entries before it are removed from the cache and
> leaked.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Cheers,
> 

-- 
James Morris
<jmorris@namei.org>
