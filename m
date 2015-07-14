From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 1/3] rhashtable: Add a function for in order
 insertion in buckets
Date: Wed, 15 Jul 2015 07:58:37 +0800
Message-ID: <20150714235837.GA29279@gondor.apana.org.au>
References: <1436834353-1851565-2-git-send-email-tom@herbertland.com>
 <20150714095721.GA22264@gondor.apana.org.au>
 <CALx6S34mGfzUbmPvsxTZDSJX7tehoh4j3nee3C33a57_FFnerw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58441 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbbGNX6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 19:58:49 -0400
Content-Disposition: inline
In-Reply-To: <CALx6S34mGfzUbmPvsxTZDSJX7tehoh4j3nee3C33a57_FFnerw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 09:42:49AM -0700, Tom Herbert wrote:
>
> Scored lookups can provides the same functionality, but requires that
> we scan all the elements so I see some overhead compared to doing
> ordered insertion. One way to resolve the rehash problem is search any
> future table after we find a hit in the first table to see if there
> are any entries that would precede the element already found. So in
> the common non-rehash case lookup happens as it does now except that
> we would always check for future_tbl.

There is another problem with this approach and that is it breaks
the logic for determining hash collission attack.  Since you're
intentionally inserting multiple elements with the same hash, the
chain length would be inflated.

The other reason I wanted to have this logic outside of rhashtable
is because for IPsec, the wildcards may in fact change after a
"rehash".  For example we may move from a /32 granularity to a
/31 granlarity at the requst of the admin.  In that case you can't
just mix the chain from the old table with the new.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
