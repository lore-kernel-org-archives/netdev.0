From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v1 PATCH 10/14] rhashtable: Rip out obsolete compare interface
Date: Mon, 16 Mar 2015 09:35:10 +0000
Message-ID: <20150316093510.GD10896@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX627-0005oh-Le@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41818 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbCPJfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:35:11 -0400
Content-Disposition: inline
In-Reply-To: <E1YX627-0005oh-Le@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/15 at 09:44pm, Herbert Xu wrote:
> Now that the only user of rhashtable_lookup_compare_insert and
> rhashtable_lookup_compare (i.e., netlink) has switched over to
> the new obj_hashfn based interface, we can rip them out safely.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

As pointed out in the previous patch, I think we should keep this
API but convert it to a macro for inlining. rhashtable_lookup() would
then just be a user of this macro.

It might even be worth to hardcode rhashtable_lookup() to jhash
and require users which require a different hash function to
use rhashtable_lookup_compare().
