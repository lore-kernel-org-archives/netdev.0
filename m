From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec] xfrm: prevent ipcomp scratch buffer race condition
Date: Thu, 17 Oct 2013 11:55:02 +0200
Message-ID: <20131017095502.GD7660@secunet.com>
References: <20131014160334.BCCDDE8A31@unicorn.suse.cz>
 <20131016123205.GA9982@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57964 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab3JQJzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 05:55:04 -0400
Content-Disposition: inline
In-Reply-To: <20131016123205.GA9982@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 08:32:05PM +0800, Herbert Xu wrote:
> On Mon, Oct 14, 2013 at 06:03:34PM +0200, Michal Kubecek wrote:
> > In ipcomp_compress(), sortirq is enabled too early, allowing the
> > per-cpu scratch buffer to be rewritten by ipcomp_decompress()
> > (called on the same CPU in softirq context) between populating
> > the buffer and copying the compressed data to the skb.
> 
> Good catch.
> 
> > Add similar protection into ipcomp_decompress() as it can be
> > called from process context as well (even if such scenario seems
> > a bit artificial).
> 
> I don't think this is possible or otherwise xfrm_input will
> dead-lock.
> 

Michal, please incorporate the feedback from Herbert and Eric,
I'll take it into the ipsec tree then. Thanks!
