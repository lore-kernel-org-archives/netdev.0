From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/3] rhashtable: Add a function for in order
 insertion in buckets
Date: Tue, 14 Jul 2015 17:59:53 -0700
Message-ID: <CALx6S37KRjff719DT_+f2EXoJ6ehdvX7P-jvgca9cTiHCSrkDg@mail.gmail.com>
References: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
	<20150714095721.GA22264@gondor.apana.org.au>
	<CALx6S34mGfzUbmPvsxTZDSJX7tehoh4j3nee3C33a57_FFnerw@mail.gmail.com>
	<20150714235837.GA29279@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38529 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbbGOA7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 20:59:53 -0400
Received: by iggf3 with SMTP id f3so25071472igg.1
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 17:59:53 -0700 (PDT)
In-Reply-To: <20150714235837.GA29279@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 4:58 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Jul 14, 2015 at 09:42:49AM -0700, Tom Herbert wrote:
>>
>> Scored lookups can provides the same functionality, but requires that
>> we scan all the elements so I see some overhead compared to doing
>> ordered insertion. One way to resolve the rehash problem is search any
>> future table after we find a hit in the first table to see if there
>> are any entries that would precede the element already found. So in
>> the common non-rehash case lookup happens as it does now except that
>> we would always check for future_tbl.
>
> There is another problem with this approach and that is it breaks
> the logic for determining hash collission attack.  Since you're
> intentionally inserting multiple elements with the same hash, the
> chain length would be inflated.
>
Conceptually, I agree with you, but I would point out that we've had
this model of intentional collisions for a while in socket lookup. I
would assume that it's a goal to use rhashtable for socket tables, so
we'll need some solution that works with that!

> The other reason I wanted to have this logic outside of rhashtable
> is because for IPsec, the wildcards may in fact change after a
> "rehash".  For example we may move from a /32 granularity to a
> /31 granlarity at the requst of the admin.  In that case you can't
> just mix the chain from the old table with the new.
>
Where ordering elements in the table can't be sustained, scoring would
be used (e.g. scoring function can be changed on the fly, but ordering
rules can't be).

Tom

> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
