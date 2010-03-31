From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 3/7] flow: allocate hash table for online cpus only
Date: Wed, 31 Mar 2010 16:27:36 +0300
Message-ID: <4BB34DC8.7080903@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-4-git-send-email-timo.teras@iki.fi> <20100330121255.GC5731@gondor.apana.org.au> <201003312302.51683.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:39972 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757686Ab0CaN1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:27:41 -0400
Received: by ewy20 with SMTP id 20so28535ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 06:27:39 -0700 (PDT)
In-Reply-To: <201003312302.51683.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Tue, 30 Mar 2010 10:42:55 pm Herbert Xu wrote:
>> On Mon, Mar 29, 2010 at 05:12:40PM +0300, Timo Teras wrote:
>>> Instead of unconditionally allocating hash table for all possible
>>> cpu's, allocate it only for online cpu's and release related
>>> memory if cpu goes down.
>>>
>>> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>> Hmm that's where we started but then Rusty changed it back in 2004:
>>
>> So I'd like to hear his opinion on changing it back again.
> 
> It was pretty unique at the time, it no longer is, so the arguments are less
> compelling IMHO.
> 
> However, we can now use a dynamic percpu variable and get it as a real
> per-cpu thing (which currently means it *will* be for every available cpu,
> not just online ones).  Haven't thought about it, but that change might be
> worth considering instead?

I did convert most of the static percpu variables to a struct which
is allocated dynamically using alloc_percpu. See:
 http://marc.info/?l=linux-netdev&m=127003066905912&w=2

This patch is on top of that, to avoid allocating the larger hash
table unconditionally as amount of possible cpu's can be large.
If you take a look at the actual patch to add back the hash allocation
for only 'online' cpu's, it's not that complicated IMHO:
 http://marc.info/?l=linux-netdev&m=126987200927472&w=2

