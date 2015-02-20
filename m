From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rhashtable: don't allocate ht structure on stack
 in test_rht_init
Date: Fri, 20 Feb 2015 16:34:07 -0500 (EST)
Message-ID: <20150220.163407.2037909158415351477.davem@davemloft.net>
References: <8e1d6d2ffb44eac6518f435a044dbc6c0fd754ae.1424463131.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbbBTVeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 16:34:09 -0500
In-Reply-To: <8e1d6d2ffb44eac6518f435a044dbc6c0fd754ae.1424463131.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 20 Feb 2015 21:14:21 +0100

> With object runtime debugging enabled, the rhashtable test suite
> will rightfully throw a warning "ODEBUG: object is on stack, but
> not annotated" from rhashtable_init().
> 
> This is because run_work is (correctly) being initialized via
> INIT_WORK(), and not annotated by INIT_WORK_ONSTACK(). Meaning,
> rhashtable_init() is okay as is, we just need to move ht e.g.,
> into global scope.
> 
> It never triggered anything, since test_rhashtable is rather a
> controlled environment and effectively runs to completion, so
> that stack memory is not vanishing underneath us, we shouldn't
> confuse any testers with it though.
> 
> Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
