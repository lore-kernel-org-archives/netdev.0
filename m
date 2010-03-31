From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] xfrm: increment genid before bumping state genids
Date: Wed, 31 Mar 2010 13:55:13 +0300
Message-ID: <4BB32A11.1030708@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi> <1270030626-16687-3-git-send-email-timo.teras@iki.fi> <20100331105023.GA12845@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:40098 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756605Ab0CaKzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:55:15 -0400
Received: by ewy20 with SMTP id 20so1826024ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 03:55:14 -0700 (PDT)
In-Reply-To: <20100331105023.GA12845@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Mar 31, 2010 at 01:17:03PM +0300, Timo Teras wrote:
>> __xfrm_state_bump_genids() is used to update the genid of all
>> matching xfrm_state's, so any bundle using the state would get
>> refreshed with the newly inserted state.
>>
>> However, since __xfrm_state_bump_genids() is called before the
>> __xfrm_state_insert() which actually bumps the genid counter,
>> it is possible that the genid was not updated at all (if there
>> was no state inserts previously).
>>
>> This is fixed by moving the genid incrementation to
>> __xfrm_state_bump_genids() so the older states are guaranteed
>> to get different genid.
>>
>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> 
> It would appear that not all xfrm_state_insert calls are preceded
> by xfrm_state_bump_genids so this patch isn't correct.

Yes, I noticed that there's one. But __xfrm_state_insert() is
called to replace an acquire in that case. Acquires are never
used in bundle, so this is good.

But maybe it'd be more explicit if the genid increment is done
before each __xfrm_state_insert()?
