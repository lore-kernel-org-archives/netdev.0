From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Wed, 25 Feb 2015 15:41:28 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAED36D@AcuExch.aculab.com>
References: <cover.1424877322.git.daniel@iogearbox.net>
 <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "tgraf@suug.ch" <tgraf@suug.ch>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:55226 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbbBYPml convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 10:42:41 -0500
In-Reply-To: <cd3e70163920753c7f1a492e6df253cff9b1b080.1424877322.git.daniel@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann
> Currently, all real users of rhashtable default their grow and shrink
> decision functions to rht_grow_above_75() and rht_shrink_below_30(),
> so that there's currently no need to have this explicitly selectable.
> 
> It can/should be generic and private inside rhashtable until a real
> use case pops up. Since we can make this private, we'll save us this
> additional indirection layer and can improve insertion/deletion time
> as well.
...
> +static bool rht_grow_above_75(const struct rhashtable *ht, size_t new_size)
>  {
>  	/* Expand table when exceeding 75% load */
>  	return atomic_read(&ht->nelems) > (new_size / 4 * 3) &&
>  	       (!ht->p.max_shift || atomic_read(&ht->shift) < ht->p.max_shift);
>  }

Why not cache the 'number of items before we need to expand' value
after each expansion, setting it to 'infinite' when expansion is disabled.
Then the above check is a simple comparison.
You probably don't even need an atomic_read() - provided something is
double checked once the first test determines that an expansion is needed.

	David
