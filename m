From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Mon, 18 May 2015 12:30:47 +0200
Message-ID: <20150518103045.GG8928@secunet.com>
References: <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
 <20150516123457.GB683@gondor.apana.org.au>
 <20150516.171328.1953881469617376252.davem@davemloft.net>
 <20150518070427.GC8928@secunet.com>
 <20150518083121.GA18195@gondor.apana.org.au>
 <20150518083843.GF8928@secunet.com>
 <20150518085908.GA18381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <alexander.duyck@gmail.com>,
	<alexander.h.duyck@redhat.com>, <netdev@vger.kernel.org>,
	<tgraf@suug.ch>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58562 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763AbbERKay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 May 2015 06:30:54 -0400
Content-Disposition: inline
In-Reply-To: <20150518085908.GA18381@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 04:59:08PM +0800, Herbert Xu wrote:
> On Mon, May 18, 2015 at 10:38:44AM +0200, Steffen Klassert wrote:
> > 
> > Yes, that's possible. We just did not restore it because it 
> > was cleared with skb_scrub_packet() right after the lookup.
> 
> OK I think we can still salvage this if we do the following:
> 
> 1) Restore the mark after the lookup so the effect is minimised.

Yes, we need this to fix it for now.

> 2) Create new flow lookup field for this.
> 3) Create tunnel flag that indicates new field should be used.

Or, maybe we can create new vti tunnel keys and some key
field in the xfrm_policy and xfrm_state. If the vti keys
are present at the tunnel, use the new flow lookup field
and match with the key field of the policy and state.
Otherwise, fallback to use gre keys and mark.
