From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] GRO: fix merging a paged skb after non-paged skbs
Date: Tue, 08 Feb 2011 15:04:44 +0000
Message-ID: <1297177484.3325.1.camel@bwh-desktop>
References: <20110124184752.1d0947dd@delilah>
	 <1295918675.4105.5.camel@localhost> <1297111160.4077.14.camel@bwh-desktop>
	 <20110208084928.GA27505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42350 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab1BHPEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 10:04:48 -0500
In-Reply-To: <20110208084928.GA27505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-08 at 19:49 +1100, Herbert Xu wrote:
> On Mon, Feb 07, 2011 at 08:39:20PM +0000, Ben Hutchings wrote:
> > 
> > That is indeed the case; commit da3bc07171dff957906cbe2ad5abb443eccf57c4
> > made the following deletions:
> > 
> > -       /* Both our generic-LRO and SFC-SSR support skb and page based
> > -        * allocation, but neither support switching from one to the
> > -        * other on the fly. If we spot that the allocation mode has
> > -        * changed, then flush the LRO state.
> > -        */
> > -       if (unlikely(channel->rx_alloc_pop_pages != (rx_buf->page != NULL))) {
> > -               efx_flush_lro(channel);
> > -               channel->rx_alloc_pop_pages = (rx_buf->page != NULL);
> > -       }
> 
> Oops, sorry about that.
> 
> How about changing skb_gro_receive to detect such switches and
> simply return an error, which should have the same effect as
> flushing that flow?

That would work, though it looks like Michal has managed to make it
tolerate switches.  (I haven't yet tested the result myself.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

