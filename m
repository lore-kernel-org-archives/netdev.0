From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Wed, 17 Mar 2010 18:32:53 +0200
Message-ID: <4BA10435.9050300@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f209.google.com ([209.85.219.209]:55340 "EHLO
	mail-ew0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755818Ab0CQQc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 12:32:57 -0400
Received: by ewy1 with SMTP id 1so607812ewy.38
        for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 09:32:55 -0700 (PDT)
In-Reply-To: <4BA0FBB6.10208@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
>>> Also. With this and your recent flowi patch, I'm seeing pmtu
>>> issues. Seems like xfrm_bundle_ok uses the original dst which
>>> resulted in the creation of the bundle. Somehow that dst
>>> does not get updated with pmtu... but the new dst used in
>>> next xfrm_lookup for same target does have proper mtu.
>>> I'm debugging right now why this is happening. Any ideas?
>>
>> The dynamic MTU is always maintained in a normal dst object in
>> the IPv4 routing cache.  Each xfrm_dst points to such a dst
>> through xdst->route.
>>
>> If you were looking at the xfrm_dst's own MTU then that may well
>> cause problems.
>=20
> I figured the root cause. The original dst gets expired
> rt_genid goes old. But xfrm_dst does not notice that so it
> won't create a new bundle. xfrm_bundle_ok calls dst_check,
> but dst->obsolete =3D 0, and ipv4_dst_check is a no-op anyway.
>=20
> Somehow the rtable object should be able to tell back to
> xfrm that the dst is not good anymore. Any ideas?

Checked ipv6, it does like xfrm: sets obsolote to -1 and
on dst_check checks the genid. We need to do same in for
ipv4. I just wrote an hack, and tested it. It solves the
pmtu issues.

I will post a proper patch soon.

- Timo
