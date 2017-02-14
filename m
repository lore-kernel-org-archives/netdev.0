From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/if_pppol2tp.h userspace compilation
 errors
Date: Tue, 14 Feb 2017 14:37:23 -0500 (EST)
Message-ID: <20170214.143723.629330014459224649.davem@davemloft.net>
References: <20170214103353.GA8394@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752277AbdBNThZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:37:25 -0500
In-Reply-To: <20170214103353.GA8394@altlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Tue, 14 Feb 2017 13:33:53 +0300

> In file included from /usr/include/linux/l2tp.h:12:0,
>                  from /usr/include/linux/if_pppol2tp.h:21,
> /usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'

This is protected properly by __UAPI_DEF_IN_ADDR, so whichever gets
included first makes the definition.

This whole thing is designed so that if GLIBC headers are included
first, __UAPI_DEF_IN_ADDR will be defined to zero, therefore
linux/in.h won't try to make the definition.  Otherwise it will.

The facility should not be so fragile that we have to play all
kinds of header ordering games.  We would be imposing the same
strange rules on userspace applications including these headers
which is completely unacceptable.

So if the facility isn't working correctly, let's fix that instead
of fidgeting with include ordering all over the tree.

Thanks.
