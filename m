From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix reader/rehash race
Date: Fri, 13 Mar 2015 10:54:35 +0000
Message-ID: <20150313105435.GA17829@casper.infradead.org>
References: <20150312110749.GA19285@gondor.apana.org.au>
 <20150312133749.GB21620@casper.infradead.org>
 <20150312214944.GA20117@gondor.apana.org.au>
 <20150313103259.GC11089@casper.infradead.org>
 <20150313103615.GB1559@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56094 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbbCMKyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 06:54:37 -0400
Content-Disposition: inline
In-Reply-To: <20150313103615.GB1559@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 09:36pm, Herbert Xu wrote:
> rhashtable_remove is fine because the rehasher has to take the
> same lock to move things over.  That's what guarantees the new
> future_tbl to be visible if it moved the to-be-removed object
> over to the new table.
> 
> IOW if rhashtable_remove couldn't see the future_tbl then that
> can only mean that the rehasher has yet to take the lock on that
> bucket which implies that the object if it existed at all is still
> in that bucket.

Ah, it works because the future_tbl load can't be reordered in
front of the acquire. Thanks for the explanation.
