From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 9 Jan 2009 14:14:08 +1100
Message-ID: <20090109031408.GB11336@gondor.apana.org.au>
References: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Speedster <speedster@haveacry.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33139 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753073AbZAIDOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 22:14:21 -0500
Content-Disposition: inline
In-Reply-To: <e7c4531f0901081558n429f7275w717774dbe9ccd895@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 05:58:11PM -0600, John Dykstra wrote:
> 
> I haven't unscrambled where the drop occurs in the PPPoE driver, but that's
> presumably what changed in 2.6.27.  It seems to me that the drop is proper.
> What's wrong is trimming the sk_buff to match the IP header while ignoring
> the L2 header, and that's apparently been that way for a while (if I
> understand what the reporter is running where).
> 
> Or have I screwed up my first posting to netdev?

You've hit the nail on the head :)

The bridge netfilter is just one huge pile of crap that should
be deleted.

The least we should do is delete the VLAN/PPPOE parts of it because
it's simply bogus.  What if two VLANs/PPPOE sessions use the same
IP address pairs? They'll be treated as a single flow which is just
insane.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
