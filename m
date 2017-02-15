From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] uapi: fix linux/if_pppol2tp.h userspace compilation
 errors
Date: Tue, 14 Feb 2017 22:18:27 -0500 (EST)
Message-ID: <20170214.221827.1737017127401316605.davem@davemloft.net>
References: <20170214.143723.629330014459224649.davem@davemloft.net>
        <20170214202950.GB17325@altlinux.org>
        <20170215022326.GA21493@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: asbjorn@asbjorn.st, jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdBODSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 22:18:40 -0500
In-Reply-To: <20170215022326.GA21493@altlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Wed, 15 Feb 2017 05:23:26 +0300

> Because of <linux/libc-compat.h> interface limitations, <netinet/in.h>
> provided by libc cannot be included after <linux/in.h>, therefore any
> header that includes <netinet/in.h> cannot be included after <linux/in.h>.
> 
> Change uapi/linux/l2tp.h, the last uapi header that includes
> <netinet/in.h>, to include <linux/in.h> and <linux/in6.h> instead of
> <netinet/in.h> and use __SOCK_SIZE__ instead of sizeof(struct sockaddr)
> the same way as uapi/linux/in.h does, to fix linux/if_pppol2tp.h userspace
> compilation errors like this:
> 
> In file included from /usr/include/linux/l2tp.h:12:0,
>                  from /usr/include/linux/if_pppol2tp.h:21,
> /usr/include/netinet/in.h:31:8: error: redefinition of 'struct in_addr'
> 
> Fixes: 47c3e7783be4 ("net: l2tp: deprecate PPPOL2TP_MSG_* in favour of L2TP_MSG_*")
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> ---
> v2: change uapi/linux/l2tp.h to fix <linux/if_pppol2tp.h>

This looks a lot better.

Applied and queued up for -stable, thanks.
