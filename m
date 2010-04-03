From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 03 Apr 2010 16:50:08 +0300
Message-ID: <4BB74790.7070109@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:61625 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab0DCNuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 09:50:17 -0400
Received: by ewy20 with SMTP id 20so760738ewy.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 06:50:15 -0700 (PDT)
In-Reply-To: <20100403083609.GA3654@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> With repsect to removing the cache flush upon policy removal,
> what takes care of the timely purging of the corresponding cache
> entries if no new traffic comes through?
> 
> The concern is that if they're not purged in the absence of new
> traffic, then we may hold references on all sorts of objects,
> leading to consequences such as the inability to unregister net
> devices.

The flow cache is randomized every ten minutes. Thus all flow
cache entries get recreated regularly.

> On Sat, Apr 03, 2010 at 11:38:57AM +0800, Herbert Xu wrote:
>> With repsect to removing the cache flush upon policy removal,
>> what takes care of the timely purging of the corresponding cache
>> entries if no new traffic comes through?
> 
> In fact this change would seem to render the existing bundle
> pruning mechanism when devices are unregistered ineffective.
> 
> xfrm_prune_bundles walks through active policy lists to find
> the bundles to purge.  However, if a policy has been deleted
> while a bundle referencing it is still in the cache, that bundle
> will not be pruned.

When policy is killed, the policy->genid is incremented which
makes xfrm_bundle_ok check fail and the bundle to get pruned
immediately on flush.
