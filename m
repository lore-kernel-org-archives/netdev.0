From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] lib: test_rhashtable: fix for large entry counts
Date: Mon, 24 Jul 2017 11:18:41 +0800
Message-ID: <20170724031840.GA25786@gondor.apana.org.au>
References: <20170721145131.25542-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
        Manuel Messner <mm@skelett.io>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:41002 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751853AbdGXDTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 23:19:15 -0400
Content-Disposition: inline
In-Reply-To: <20170721145131.25542-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 21, 2017 at 04:51:31PM +0200, Phil Sutter wrote:
> During concurrent access testing, threadfunc() concatenated thread ID
> and object index to create a unique key like so:
> 
> | tdata->objs[i].value = (tdata->id << 16) | i;
> 
> This breaks if a user passes an entries parameter of 64k or higher,
> since 'i' might use more than 16 bits then. Effectively, this will lead
> to duplicate keys in the table.
> 
> Fix the problem by introducing a struct holding object and thread ID and
> using that as key instead of a single integer type field.
> 
> Fixes: f4a3e90ba5739 ("rhashtable-test: extend to test concurrency")
> Reported by: Manuel Messner <mm@skelett.io>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
