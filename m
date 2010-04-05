From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon, 05 Apr 2010 11:53:07 +0300
Message-ID: <4BB9A4F3.9050003@iki.fi>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-2-git-send-email-timo.teras@iki.fi> <20100405083302.GA16636@gondor.apana.org.au> <4BB9A113.30601@iki.fi> <20100405084422.GB16788@gondor.apana.org.au> <20100405084902.GA16912@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:38445 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab0DEIxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:53:10 -0400
Received: by ewy20 with SMTP id 20so992259ewy.1
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 01:53:09 -0700 (PDT)
In-Reply-To: <20100405084902.GA16912@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Apr 05, 2010 at 04:44:22PM +0800, Herbert Xu wrote:
>>> It might actually make more sense to pass struct flow_cache_object**
>>> so the resolver can twiddle the flow_cache_entry's object. Then it'd
>>> be more explicit that the resolver is replacing entries.
>> Yes that sounds good.
> 
> Alternatively you can pass in a struct flow_cache_entry *.
> 
> Yet another way would be to keep it the same but move the NULL
> setting before the resolver call:
> 
> 	flo = NULL;
> 	if (fle) {
> 		flo = fle->object;
> 		fle->object = NULL;
> 	}
> 	flo = resolver(..., flo, ...);
> 
> This way it's obvious that we've given the reference over to
> the resolver.

Right. I'm fine either way. Is there any preference?
