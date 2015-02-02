From: Thomas Graf <tgraf@suug.ch>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Mon, 2 Feb 2015 09:48:19 +0000
Message-ID: <20150202094819.GA22611@casper.infradead.org>
References: <20150131093637.GA29106@gondor.apana.org.au>
 <54CF44B0.4040205@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58735 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbbBBJsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 04:48:22 -0500
Content-Disposition: inline
In-Reply-To: <54CF44B0.4040205@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/15 at 05:34pm, Ying Xue wrote:
> On 01/31/2015 05:36 PM, Herbert Xu wrote:
> > The current being_destroyed check in rhashtable_expand is not
> > enough since if we start a shrinking process after freeing all
> > elements in the table that's also going to crash.
> > 
> 
> Sorry, I cannot understand the scenario.
> 
> When we free the table in rhashtable_destroy(), we call
> cancel_work_sync() to synchronously cancel the work. So, why does your
> described crash still happen?

It's nft_hash specific. nft_hash frees all entries under ht->mutex without
unlinking them upon destroy and sets being_destroyed before doing. Therefore
it must be ensured that a resize is not started afterwards because the table
contains freed entries.
