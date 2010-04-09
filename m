From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 09 Apr 2010 11:11:48 +0300
Message-ID: <4BBEE144.8070600@iki.fi>
References: <20100409080907.GA2029@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:40498 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab0DIILt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 04:11:49 -0400
Received: by ey-out-2122.google.com with SMTP id d26so272203eyd.19
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 01:11:48 -0700 (PDT)
In-Reply-To: <20100409080907.GA2029@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Timo Ter=E4s <timo.teras@iki.fi> wrote:
>> Happens because CONFIG_XFRM_SUB_POLICY is not enabled, and one of
>> the helper functions I used did unexpected things in that case.
>>
>> Try the following:
>=20
> Ugh, can we fix this some other way?
>=20
> The policy array should really only exist if SUB_POLICY is defined.

The problem was that my code could call it with zero polcies
assuming it'd do the right thing.

It's still really misleading to have generic function that does not
do the expected thing based on some config. Compiler should know
how to optimize the for loop away if it's being called with fixed
array size.

