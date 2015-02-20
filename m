From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] rhashtable: don't allocate ht structure on stack in
 test_rht_init
Date: Fri, 20 Feb 2015 20:16:19 +0000
Message-ID: <20150220201619.GF4586@casper.infradead.org>
References: <8e1d6d2ffb44eac6518f435a044dbc6c0fd754ae.1424463131.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54132 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbbBTUQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:16:20 -0500
Content-Disposition: inline
In-Reply-To: <8e1d6d2ffb44eac6518f435a044dbc6c0fd754ae.1424463131.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/15 at 09:14pm, Daniel Borkmann wrote:
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

Thanks for looking into this.

Acked-by: Thomas Graf <tgraf@suug.ch>
