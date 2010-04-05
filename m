From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon, 05 Apr 2010 11:36:35 +0300
Message-ID: <4BB9A113.30601@iki.fi>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-2-git-send-email-timo.teras@iki.fi> <20100405083302.GA16636@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:48190 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab0DEIgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:36:39 -0400
Received: by ewy20 with SMTP id 20so990290ewy.1
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 01:36:37 -0700 (PDT)
In-Reply-To: <20100405083302.GA16636@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Apr 05, 2010 at 10:00:21AM +0300, Timo Teras wrote:
>> @@ -219,33 +222,32 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
>> +	flo = resolver(net, key, family, dir, fle ? fle->object : NULL, ctx);
>> +	if (fle) {
>> +		fle->genid = atomic_read(&flow_cache_genid);
>> +		if (IS_ERR(flo)) {
>> +			fle->genid--;
>> +			fle->object = NULL;
> 
> Shouldn't we call fle->object->ops->delete here?

The resolver function releases the old object.

It might actually make more sense to pass struct flow_cache_object**
so the resolver can twiddle the flow_cache_entry's object. Then it'd
be more explicit that the resolver is replacing entries.

