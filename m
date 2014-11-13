From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Thu, 13 Nov 2014 10:37:23 +0000
Message-ID: <20141113103723.GO19157@casper.infradead.org>
References: <20141113101025.GA3728@gondor.apana.org.au>
 <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50658 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932174AbaKMKhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:37:24 -0500
Content-Disposition: inline
In-Reply-To: <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/14 at 06:11pm, Herbert Xu wrote:
> Currently mutex_is_held can only test locks in the that are global
> since it takes no arguments.  This prevents rhashtable from being
> used in places where locks are lock, e.g., per-namespace locks.
> 
> This patch adds a parent field to mutex_is_held and rhashtable_params
> so that local locks can be used (and tested).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Could you fix the documentation of rhashtable_init() as well?

[...]
 * struct rhashtable_params params = {
 *      .head_offset = offsetof(struct test_obj, node),
 *      .key_offset = offsetof(struct test_obj, key),
 *      .key_len = sizeof(int),
 *      .hashfn = arch_fast_hash,
 *      .mutex_is_held = &my_mutex_is_held,
 * };
[...]
