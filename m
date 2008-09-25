From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Thu, 25 Sep 2008 15:36:04 +0300
Message-ID: <48DB85B4.10104@iki.fi>
References: <20080924062138.GA6764@gondor.apana.org.au> <48D9EC4B.4050804@iki.fi> <20080924075441.GA7391@gondor.apana.org.au> <48DA3E2D.4070909@iki.fi> <20080924140819.GA10022@gondor.apana.org.au> <48DB29A9.2090204@iki.fi> <20080925075715.GA18101@gondor.apana.org.au> <48DB4EE7.2030109@iki.fi> <20080925085634.GA18853@gondor.apana.org.au> <48DB536A.7020209@iki.fi> <20080925094905.GA19180@gondor.apana.org.au> <48DB801E.90500@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:11228 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbYIYMgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 08:36:09 -0400
Received: by fk-out-0910.google.com with SMTP id 18so398924fkq.5
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 05:36:07 -0700 (PDT)
In-Reply-To: <48DB801E.90500@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> Thanks! I've got some other work to do so feel free to post this
>> tomorrow.
>=20
> It was simpler than I thought (and I thought I would be more busy
> with other things). Anyway, here goes. This is a single patch that
> modifies both xfrm_state and xfrm_policy dumping. This was to get
> af_key patch nicer (the final skb patching/sending is common code).

One more thing I noticed. If the af_key socket is closed while
dumping is ongoing the current code can leak stuff. We should call
the .done. And also in the new patch, release the stored skb.

The right place to do that would be pfkey_release, I assume?

- Timo

