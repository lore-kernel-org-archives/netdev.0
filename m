From: Thomas Graf <tgraf@suug.ch>
Subject: Re: 4.8.0-rc1: page allocation failure: order:3,
 mode:0x2084020(GFP_ATOMIC|__GFP_COMP)
Date: Fri, 12 Aug 2016 00:28:16 +0200
Message-ID: <20160811222816.GA21039@pox.localdomain>
References: <8bdcb66dc3eb2448e4b6f2baef2ad8ea@eikelenboom.it>
 <20160809122241.GA13060@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@eikelenboom.it, netdev@vger.kernel.org,
	netfilter@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34976 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcHKW2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 18:28:19 -0400
Received: by mail-wm0-f51.google.com with SMTP id f65so17116547wmi.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 15:28:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160809122241.GA13060@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/16 at 02:22pm, Florian Westphal wrote:
> Hmmm, seems this is coming from an attempt to allocate the bucket lock
> array (since actual table has __GFP_NOWARN).
> 
> I was about to just send a patch that adds a GPF_NOWARN in
> bucket_table_alloc/alloc_bucket_locks call.
> 
> However, I wonder if we really need this elaborate sizing logic.
> I think it makes more sense to always allocate a fixed size regardless
> of number of CPUs, i.e. get rid of locks_mul and all the code that comes
> with it.
> 
> Doing order-3 allocation for locks seems excessive to me.
> 
> The netfilter conntrack hashtable just uses a fixed array of 1024
> spinlocks (so on x86_64 we get on page of locks).
> 
> What do you think?

The code has been primarily derived from inet_ehash_locks_alloc()
so my initial suggestion would be to adjust it to after Eric's
latest fixes including the change to GFP_NOWARN.
