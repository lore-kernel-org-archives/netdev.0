From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] strparser: initialize all callbacks
Date: Thu, 24 Aug 2017 21:58:27 -0700 (PDT)
Message-ID: <20170824.215827.1642146539202794550.davem@davemloft.net>
References: <20170824213851.57601-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ebiggers@google.com, dvyukov@google.com, tom@quantonium.net
To: ebiggers3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHYE62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:58:28 -0400
In-Reply-To: <20170824213851.57601-1-ebiggers3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Biggers <ebiggers3@gmail.com>
Date: Thu, 24 Aug 2017 14:38:51 -0700

> From: Eric Biggers <ebiggers@google.com>
> 
> commit bbb03029a899 ("strparser: Generalize strparser") added more
> function pointers to 'struct strp_callbacks'; however, kcm_attach() was
> not updated to initialize them.  This could cause the ->lock() and/or
> ->unlock() function pointers to be set to garbage values, causing a
> crash in strp_work().
> 
> Fix the bug by moving the callback structs into static memory, so
> unspecified members are zeroed.  Also constify them while we're at it.
> 
> This bug was found by syzkaller, which encountered the following splat:
 ...
> Fixes: bbb03029a899 ("strparser: Generalize strparser")
> Signed-off-by: Eric Biggers <ebiggers@google.com>

This commit is only in net-next, so that is where I am applying
this patch.

Thanks.
