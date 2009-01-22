From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 08:39:35 +0200
Message-ID: <497814A7.3060302@iki.fi>
References: <49780AA9.9050508@iki.fi> <20090121.220304.211246256.davem@davemloft.net> <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:49695 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753929AbZAVGjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 01:39:48 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2044340fgg.17
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 22:39:46 -0800 (PST)
In-Reply-To: <20090122063206.GA11818@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Jan 21, 2009 at 10:21:12PM -0800, David Miller wrote:
>>> I would not consider this a new feature. It just makes pfkey
>>> act consistently. If you don't want it supported, it'd make
>>> more sense to not #define SADB_X_EXT_NAT_T_OA and drop all of
>>> the verification code already present than to silently
>>> ignore it. Make kernel return an error if some tried using it.
>> Fair enough, sounds like a reasonable argument.
>>
>> Herbert what do you think?  The proposal is that we just reflect the
>> value we get, rather than acting upon it.
> 
> The only references to SADB_X_EXT_NAT_T_OA in our kernel currently
> are for the user => kernel direction.  This patch does kernel =>
> user so I don't see a connection.
>
> In any case I just grabbed the latest ipsec-tools source and it
> doesn't use this stuff at all so IMO this is a new feature.

There hasn't been new release for ipsec-tools for a while.
It's been in ipsec-tools CVS since 2007-12-12. And I know many
who are using the CVS code in production.

Again, my argument is that the code does not modify any headers,
add/modify structures, extensions or messages. So in kernel
point of view it's not a new feature. From userland point of
view it makes kernel act consistently as now the kernel claims
to support something (by having the defines, checking it,
validating it) but just ignores it silently.

Now the split is artificial: the pfkey code knows about nat-oa
but silently ignores it instead of passing it to xfrm. It made
more sense if it was properly or not knowing at all about it.

- Timo
