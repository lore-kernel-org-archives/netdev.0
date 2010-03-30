From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 16:33:52 +0300
Message-ID: <4BB1FDC0.5020200@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <20100330121427.GD5731@gondor.apana.org.au> <4BB1ECBF.50000@iki.fi> <20100330122301.GG5731@gondor.apana.org.au> <4BB1F15E.3030402@iki.fi> <20100330124815.GA6378@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:37738 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213Ab0C3Ndz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 09:33:55 -0400
Received: by ewy20 with SMTP id 20so1247920ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 06:33:53 -0700 (PDT)
In-Reply-To: <20100330124815.GA6378@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 30, 2010 at 03:41:02PM +0300, Timo Ter=E4s wrote:
>> So it'd make more sense to nuke the hashes entirely for
>> per-socket policies?
>=20
> Absolutely.

I checked now the xfrm_user, and mostly it seems to prevent
modification to per-socket policies.

The only exception is XFRM_MSG_POLEXPIRE handler
xfrm_add_pol_expire(). It calls xfrm_policy_byid() without
verifying the direction, and can thus complete successfully on
a per-socket policy. This can actually result in per-socket
policy deletion via netlink.

I guess the proper thing is to add the direction check there.

It also seems that the by-index hash is also used when
generating new index. It's to double check that the index
is unique. So deleting the by-index hash from per-socket
policies seems tricky.

Removing bydst hashing should be trivial.
