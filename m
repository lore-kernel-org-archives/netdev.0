From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 24 Sep 2008 08:14:11 +0300
Message-ID: <48D9CCA3.2040500@iki.fi>
References: <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au> <48D8E045.8040508@iki.fi> <20080923125615.GC29524@gondor.apana.org.au> <48D8E8A9.8050100@iki.fi> <20080923130709.GA29902@gondor.apana.org.au> <48D8EF5E.1060500@iki.fi> <20080923133234.GA30370@gondor.apana.org.au> <48D8F337.2050103@iki.fi> <20080924042349.GA5419@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:2318 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbYIXFOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 01:14:21 -0400
Received: by ey-out-2122.google.com with SMTP id 6so716681eyi.37
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 22:14:19 -0700 (PDT)
In-Reply-To: <20080924042349.GA5419@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 04:46:31PM +0300, Timo Ter=E4s wrote:
>> Ah, the other layers take it at least on _walk_init paths. But
>> _walk_done can be called from recv() syscalls. The af_key
>> implementation does not take xfrm_cfg_mutex there. I don't think
>> xfrm_user does that either as it does not pass cb_mutex to
>> netlink_kernel_create. So at least the _state_walk_done path
>> is unsafe as-is, I think.
>=20
> OK we'd need to fix that up.
>=20
> However, I've got a new idea :) Let's put the dumpers on the
> list directly and then we won't have to deal any of this crap
> about states going away.

Now this is an interesting idea... I like this a lot.

Only comment is that there really should be struct for the
shared stuff. Otherwise it's bound to break at some point.

Cheers,
  Timo
