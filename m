From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v3 PATCH 1/2] rhashtable: Add rhlist interface
Date: Mon, 19 Sep 2016 23:16:21 +0200
Message-ID: <20160919211621.GA20951@pox.localdomain>
References: <20160919105854.GA12892@gondor.apana.org.au>
 <E1blwIz-0003Mz-HD@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, tom@herbertland.com,
        Ben Greear <greearb@candelatech.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33078 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752124AbcISVQY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 17:16:24 -0400
Received: by mail-wm0-f44.google.com with SMTP id d66so15440141wmf.0
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 14:16:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <E1blwIz-0003Mz-HD@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/16 at 07:00pm, Herbert Xu wrote:
> The insecure_elasticity setting is an ugly wart brought out by
> users who need to insert duplicate objects (that is, distinct
> objects with identical keys) into the same table.
> 
> In fact, those users have a much bigger problem.  Once those
> duplicate objects are inserted, they don't have an interface to
> find them (unless you count the walker interface which walks
> over the entire table).
> 
> Some users have resorted to doing a manual walk over the hash
> table which is of course broken because they don't handle the
> potential existence of multiple hash tables.  The result is that
> they will break sporadically when they encounter a hash table
> resize/rehash.
> 
> This patch provides a way out for those users, at the expense
> of an extra pointer per object.  Essentially each object is now
> a list of objects carrying the same key.  The hash table will
> only see the lists so nothing changes as far as rhashtable is
> concerned.
> 
> To use this new interface, you need to insert a struct rhlist_head
> into your objects instead of struct rhash_head.  While the hash
> table is unchanged, for type-safety you'll need to use struct
> rhltable instead of struct rhashtable.  All the existing interfaces
> have been duplicated for rhlist, including the hash table walker.
> 
> One missing feature is nulls marking because AFAIK the only potential
> user of it does not need duplicate objects.  Should anyone need
> this it shouldn't be too hard to add.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Nice, I like how this simplifies users! Is this suitable for
ILA as well?

Acked-by: Thomas Graf <tgraf@suug.ch>
