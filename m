From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Tue, 06 Apr 2010 16:26:28 +0300
Message-ID: <4BBB3684.8070807@iki.fi>
References: <20100405091228.GA17059@gondor.apana.org.au> <1270486884-10905-1-git-send-email-timo.teras@iki.fi> <20100406123404.GA24294@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:35626 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755847Ab0DFN0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 09:26:37 -0400
Received: by ewy20 with SMTP id 20so470267ewy.1
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 06:26:35 -0700 (PDT)
In-Reply-To: <20100406123404.GA24294@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Mon, Apr 05, 2010 at 08:01:24PM +0300, Timo Teras wrote:
>> This allows to validate the cached object before returning it.
>> It also allows to destruct object properly, if the last reference
>> was held in flow cache. This is also a prepartion for caching
>> bundles in the flow cache.
>>
>> In return for virtualizing the methods, we save on:
>> - not having to regenerate the whole flow cache on policy removal:
>>   each flow matching a killed policy gets refreshed as the getter
>>   function notices it smartly.
>> - we do not have to call flow_cache_flush from policy gc, since the
>>   flow cache now properly deletes the object if it had any references
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks a lot for the patch!

As noticed in review of 2/4, this needs to be fixed by calling
flow object delete() unconditionally if genid is outdated. I'll
repost with this fixed for next iteration.

