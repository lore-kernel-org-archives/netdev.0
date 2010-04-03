From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 03 Apr 2010 17:26:00 +0300
Message-ID: <4BB74FF8.2020303@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:38870 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab0DCO0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 10:26:03 -0400
Received: by ewy20 with SMTP id 20so765037ewy.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 07:26:02 -0700 (PDT)
In-Reply-To: <20100403141709.GA5165@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Apr 03, 2010 at 04:50:08PM +0300, Timo Ter=E4s wrote:
>> The flow cache is randomized every ten minutes. Thus all flow
>> cache entries get recreated regularly.
>=20
> Having rmmod <netdrv> block for up to ten minutes is hardly
> ideal.

Why would this block? The device down hook calls flow cache
flush. On flush all bundles with non-up devices get pruned
immediately (via stale_bundle check).

> Besides, in future we may want to get rid of the regular reseeding
> just like we did for IPv4 routes.

Right. It certainly sounds good. And needs a separate change
then.

If this is done, we will need to still have some sort of
periodic gc for flow cache, just like ipv4 routes have. The
gc would on each tick scan just some of the flow cache hash
chains.
