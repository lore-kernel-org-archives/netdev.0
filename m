From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Mon, 18 May 2015 10:38:44 +0200
Message-ID: <20150518083843.GF8928@secunet.com>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
 <20150516123457.GB683@gondor.apana.org.au>
 <20150516.171328.1953881469617376252.davem@davemloft.net>
 <20150518070427.GC8928@secunet.com>
 <20150518083121.GA18195@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <alexander.duyck@gmail.com>,
	<alexander.h.duyck@redhat.com>, <netdev@vger.kernel.org>,
	<tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56290 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988AbbERIiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 04:38:50 -0400
Content-Disposition: inline
In-Reply-To: <20150518083121.GA18195@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 04:31:21PM +0800, Herbert Xu wrote:
> On Mon, May 18, 2015 at 09:04:27AM +0200, Steffen Klassert wrote:
> >
> > The policy and state mark must match the tunnels i_key/o_key
> > on lookup. It is not required to set skb->mark, but we have
> > to make sure to use the tunnels gre keys as the mark when we
> > do a policy or state lookup.
> 
> So is it possible to restore the original mark after the lookups?

Yes, that's possible. We just did not restore it because it 
was cleared with skb_scrub_packet() right after the lookup.
