From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 08:45:01 +0300
Message-ID: <48BE245D.3060905@iki.fi>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au> <48BE1B95.8000508@iki.fi> <20080903053935.GA8428@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:9485 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064AbYICFoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:44:55 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1328866eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 22:44:53 -0700 (PDT)
In-Reply-To: <20080903053935.GA8428@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 03, 2008 at 08:07:33AM +0300, Timo Ter=E4s wrote:
>> Right. Also alternatively the xfrm_state_all could be protected
>> by a different lock than xfrm_state_lock.
>=20
> Yes that's a good idea.  Here's a patch to do that for states.
> I'm still thinking about whether policy destruction should be
> restructured or not so I'm not patching that.
>=20
> ipsec: Move state dump list unlinking into GC
>=20
> This patch moves the unlinking of x->all (for dumping) into the
> GC and changes the lock to xfrm_cfg_mutex.

Shouldn't this also change the locking in all places where
x->all is used?
