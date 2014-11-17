From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Mon, 17 Nov 2014 12:46:58 +0800
Message-ID: <20141117044657.GA30723@gondor.apana.org.au>
References: <20141116022227.GA24541@gondor.apana.org.au>
 <7DA2F716-1E87-4AC8-A18F-CE5BFB6E6F81@joshtriplett.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	paulmck@linux.vnet.ibm.com
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37901 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbaKQErO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 23:47:14 -0500
Content-Disposition: inline
In-Reply-To: <7DA2F716-1E87-4AC8-A18F-CE5BFB6E6F81@joshtriplett.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 15, 2014 at 06:37:26PM -0800, Josh Triplett wrote:
> On November 15, 2014 6:22:27 PM PST, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >Josh Triplett <josh@joshtriplett.org> wrote:
> >>
> >> - Set up the new empty table with the new set of hash parameters.
> >> - synchronize_rcu().  Readers will now search both old and new
> >tables.
> >> - Peel nodes off the ends of the old hash table and add them to the
> >new
> >
> >We currently use a singly linked list in rhashtable.  Peeling nodes
> >off the end would mean upgrading to a doubly linked list, which is
> >no different than keeping two lists in terms of cache footprint, no?
> 
> No, since each pass just handles one set of nodes from each bucket anyway, you can just do a bit more work in the rehasher instead.

OK let me see if I could implement something like that in rhashtable.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
