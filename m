From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Fri, 23 Jan 2009 08:18:33 +0200
Message-ID: <49796139.3090605@iki.fi>
References: <49780AA9.9050508@iki.fi>	<20090121.220304.211246256.davem@davemloft.net>	<49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:49300 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761921AbZAWGSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 01:18:38 -0500
Received: by fk-out-0910.google.com with SMTP id f33so1070409fkf.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 22:18:36 -0800 (PST)
In-Reply-To: <20090121.222112.245293949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
>> David Miller wrote:
>>> From: Timo Ter=E4s <timo.teras@iki.fi>
>>>> Is there any particular reason why setting NAT-OA info should/
>>>> must be done using netlink? Or is this just a way to try to
>>>> put more pressure for the change to happen?
>>> Because it isn't deprecated if we keep adding features to it.
>> I would not consider this a new feature. It just makes pfkey
>> act consistently. If you don't want it supported, it'd make
>> more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
>> the verification code already present than to silently
>> ignore it. Make kernel return an error if some tried using it.
>=20
> Fair enough, sounds like a reasonable argument.
>=20
> Herbert what do you think?  The proposal is that we just reflect the
> value we get, rather than acting upon it.

Going back to the original patch. Knowing that it's bad idea to
use it for my other purposes, I have no strong feelings to push
for this.

Then again, since as discussed earlier, encap_oa is not used for
anything (and never will be). It's just stored and given back if
requested, so this patch adds nothing new; it just stores and
gives the attribute back if the SA is dumped.

Do note that currently pfkey_msg2xfrm_state() currently allocates
xfrm_encap_tmpl with kmalloc() and leaves encap_oa uninitialized,
thus all SAs with NAT-T created via pfkey currently show random
crap in encap_oa when dumped via "ip xfrm state".

Also the patch I sent first should memset() the encap_oa if
SADB_X_EXT_NAT_T_OA is not present.

If you still consider that the copying of that extension is
inappropriate then maybe memset():ing the encap_oa to zero
would be acceptable?

Cheers,
  Timo

