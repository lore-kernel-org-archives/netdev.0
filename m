From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Thu, 17 Oct 2013 13:01:49 +0200
Message-ID: <20131017110149.GA6747@unicorn.suse.cz>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131016123205.GA9982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49861 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753464Ab3JQLBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 07:01:52 -0400
Content-Disposition: inline
In-Reply-To: <20131016123205.GA9982@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 08:32:05PM +0800, Herbert Xu wrote:
> On Mon, Oct 14, 2013 at 06:03:34PM +0200, Michal Kubecek wrote:
> 
> > Add similar protection into ipcomp_decompress() as it can be
> > called from process context as well (even if such scenario seems
> > a bit artificial).
> 
> I don't think this is possible or otherwise xfrm_input will
> dead-lock.

When I was thinking about this, I came with two situations when this
might IMHO happen:

1. We are sending a packet to ourselves; this could mean not only a
local loop but also e.g. a packets between an LXC container and the host
or between two LXC containers. While it doesn't make much sense to use
compression in such case, it might happen while testing a solution which
is going to be used in a normal setup later.

2. The packet was passed to tun/tap device by a userspace application.

Am I wrong?

                                                        Michal Kubecek
