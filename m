From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2] rhashtable: Warn if min_size or max_size
 are not a power of two
Date: Fri, 20 Mar 2015 10:57:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB0527A@AcuExch.aculab.com>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
 <20150319210239.GB9601@gondor.apana.org.au>
 <20150319211546.GA4190@casper.infradead.org>
 <20150319214933.GA11937@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:60923 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbCTK7I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:59:08 -0400
In-Reply-To: <20150319214933.GA11937@gondor.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> Sent: 19 March 2015 21:50
> On Thu, Mar 19, 2015 at 09:15:46PM +0000, Thomas Graf wrote:
> >
> > rht_grow_above_75() checks the old table size:
> >
> > (!ht->p.max_size || tbl->size < ht->p.max_size);
> >
> > If you specify max_size = 3, it grows the table to tbl->size = 4.
> > This can be avoided if max_size is a power of two.
> 
> OK let's fix the test then.  The easiest way would be to round
> max_size up to the next power of 2.

Isn't that round-up implicit in the test above, no reason to
change the user-supplied limit.

To round down just test tbl->size * 2 <= ht->p.max_size.

Maybe just document the fact that it will grow if the current size is
less than the requested maximum.

	David
