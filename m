From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix out of bound access in dccp_v4_err()
Date: Thu, 03 Nov 2016 16:20:05 -0400 (EDT)
Message-ID: <20161103.162005.780023731830218450.davem@davemloft.net>
References: <1478138440.7065.419.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42542 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752485AbcKCUUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:20:06 -0400
In-Reply-To: <1478138440.7065.419.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 19:00:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> dccp_v4_err() does not use pskb_may_pull() and might access garbage.
> 
> We only need 4 bytes at the beginning of the DCCP header, like TCP,
> so the 8 bytes pulled in icmp_socket_deliver() are more than enough.
> 
> This patch might allow to process more ICMP messages, as some routers
> are still limiting the size of reflected bytes to 28 (RFC 792), instead
> of extended lengths (RFC 1812 4.3.2.3)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
