From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 14:54:31 +0200
Message-ID: <4BA4C587.60504@iki.fi>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi> <20100320123247.GB1930@gondor.apana.org.au> <4BA4C29A.8000806@iki.fi> <20100320124919.GA2243@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:54899 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718Ab0CTMyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:54:32 -0400
Received: by ewy8 with SMTP id 8so237392ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 05:54:30 -0700 (PDT)
In-Reply-To: <20100320124919.GA2243@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Mar 20, 2010 at 02:42:02PM +0200, Timo Ter=E4s wrote:
>> But even if we have the gc_thresh back to 1024 or similar size,
>> it is still a good thing to do some basic gc on xfrm bundles so
>> that the underlaying rtable dst's can be freed before they end up
>> in the dst core list.
>=20
> But I'm not sure if a timer-based one really makes sense though.
>=20
> If you're worried about stale entries preventing IPv4/IPv6 rt
> entries from being collected, perhaps we should invoke the xfrm
> GC process from the IPv4/IPv6 GC function?

Those are more or less timer based too. I guess it would be
better to put to dst core's function then. It can see hanging
refs, and call xfrm gc in that case.

To even minimize that it would help a lot if xfrm_bundle_ok
could release (or swap to dummies) the referenced dst->route
and dst->child entries. xfrm_bundle_ok is mostly called for
all bundles regularly by xfrm_find_bundle before new ones are
created.

- Timo

