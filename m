From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/6] rhashtable: Move seed init into bucket_table_alloc
Date: Fri, 13 Mar 2015 11:33:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAFE8C4@AcuExch.aculab.com>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Herbert Xu' <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:53233 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbbCMLeg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 07:34:36 -0400
In-Reply-To: <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu
> It seems that I have already made every rehash redo the random
> seed even though my commit message indicated otherwise :)
> 
> Since we have already taken that step, this patch goes one step
> further and moves the seed initialisation into bucket_table_alloc.

If the decision to resize a hash table is based on the length
of the hash chains, then changing the hash function might either
make that unnecessary or make an immediate resize be needed.

Not that I'm convinced you can get a good enough hash function
to avoid one or two long chains when the has table is large.
I've not played with the hashes used for network 'stuff' but
I remember playing with the elf symbol table hash. Whatever I
did one or two chains would end up with more elements than
you might have hoped.

	David
