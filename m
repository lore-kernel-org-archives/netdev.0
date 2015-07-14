From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/3] rhashtable: Add a function for in order
 insertion in buckets
Date: Tue, 14 Jul 2015 09:42:49 -0700
Message-ID: <CALx6S34mGfzUbmPvsxTZDSJX7tehoh4j3nee3C33a57_FFnerw@mail.gmail.com>
References: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
	<20150714095721.GA22264@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:34870 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084AbbGNQmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 12:42:50 -0400
Received: by iecuq6 with SMTP id uq6so15376595iec.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 09:42:49 -0700 (PDT)
In-Reply-To: <20150714095721.GA22264@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 2:57 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Tom Herbert <tom@herbertland.com> wrote:
>> The obj_orderfn function may be specified in the parameters for a
>> rhashtable. When inserting an element this function is used to order
>> objects in a bucket list (greatest to least ordering value).This
>> allows entries to have wild card fields, where entries with
>> more specific information match are placed first in the bucket.
>> When a lookup is done, the first match found will contain
>> the most specific match.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
Hi Herbert,

> I think this is fundamentally broken with respect to rehashing.
> During a rehash you're going to have some elements in the old table
> and some in the new table.  At which point all your ordering
> guarantees go out of the window.
>
Yes, good observation.

> I actually need something quite similar for IPsec.  What I was
> planning on doing is have the actual objects hang off an ordered
> list object.  The ordered list would then be the thing that you
> insert into rhashtable.  This means that during rehashing they
> get moved atomically.
>
Hmm, I do like the simplicity of a flat linear search.

Scored lookups can provides the same functionality, but requires that
we scan all the elements so I see some overhead compared to doing
ordered insertion. One way to resolve the rehash problem is search any
future table after we find a hit in the first table to see if there
are any entries that would precede the element already found. So in
the common non-rehash case lookup happens as it does now except that
we would always check for future_tbl.

Tom

> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
