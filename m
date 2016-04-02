From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Fri, 01 Apr 2016 19:26:11 -0700
Message-ID: <1459563971.6473.308.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160402015709.GA19365@gondor.apana.org.au>
	 <1459563333.6473.302.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160402021917.GA19570@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:36691 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbcDBC0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:26:14 -0400
Received: by mail-yw0-f175.google.com with SMTP id g3so195732124ywa.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 19:26:14 -0700 (PDT)
In-Reply-To: <20160402021917.GA19570@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-02 at 10:19 +0800, Herbert Xu wrote:
> On Fri, Apr 01, 2016 at 07:15:33PM -0700, Eric Dumazet wrote:
> > On Sat, 2016-04-02 at 09:57 +0800, Herbert Xu wrote:
> > > 
> > > We could easily fix that by adding a feature bit to control this,
> > > something like SKB_GSO_TCP_FIXEDID.
> > 
> > I understood the patch allowed to aggregate 4 segments having
> > 
> > ID=12   ID=40   ID=80  ID=1000
> 
> Right.  But I haven't seen any justification that we should aggregate
> such packets at all.  The only valid case that I have seen is for
> the case of unchanging IDs, no?

Presumably repeats of "DF=1 ID=0" should be what we really need to
handle.

On my wish list, having some reordering logic in GRO would be far more
interesting than these minor details ;)
