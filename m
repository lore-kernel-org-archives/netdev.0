From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2 net-next 2/3] rhashtable: Add a function for in order
 insertion and lookup in buckets
Date: Wed, 15 Jul 2015 12:46:45 -0700
Message-ID: <CALx6S34+f83R6R2uo2rcE27QMyRpgHtFD_NUD3+xocKVmSvMMg@mail.gmail.com>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
	<1436917549-3666965-3-git-send-email-tom@herbertland.com>
	<20150715055411.GA31926@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35279 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbbGOTqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 15:46:46 -0400
Received: by igcqs7 with SMTP id qs7so115482859igc.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 12:46:45 -0700 (PDT)
In-Reply-To: <20150715055411.GA31926@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 10:54 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Tue, Jul 14, 2015 at 04:45:48PM -0700, Tom Herbert wrote:
>> The obj_orderfn function may be specified in the parameters for a
>> rhashtable. When inserting an element this function is used to order
>> objects in a bucket list (greatest to least ordering value).This
>> allows entries to have wild card fields, where entries with
>> more specific information match are placed first in the bucket.
>> When a lookup is done, the first match found will contain
>> the most specific match.
>>
>> In order to maintain ordering guarantees during rehash, the
>> rhashtable_lookup_ordered_cmpfn was added. This function will check
>> future tables for matches that would have a greater insertion order
>> than a match found in an older table.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> There is another problem with exposing rhashtable directly to these
> duplicate entries.  It breaks the logic on when to resize.  In the
> worst case on a server with a single port you can end up with a
> large hash table where everything is stored in a single chain.
>
> Granted you can work around this by teaching rhashtable to count
> identical entries as a single entry.  But I really think it's much
> easier to just have this logic sit on top of rhashtable instead of
> inside it.
>
> The memory cost is merely 8 bytes per local port, is it really too
> much?
>
Okay, it looks like there is already an additional hlist_node in
skc_common that can be used for a secondary hash. It's conceivable
this can be generalized and used in the TCP listeners also in
combination with rhashtable.

Tom

> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
