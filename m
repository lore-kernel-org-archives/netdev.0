From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: fix ip6gre_err() invalid reads
Date: Sun, 05 Feb 2017 17:23:39 -0500 (EST)
Message-ID: <20170205.172339.2110599060625403300.davem@davemloft.net>
References: <1486279135.7793.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751923AbdBEWXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:23:40 -0500
In-Reply-To: <1486279135.7793.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Feb 2017 23:18:55 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov reported out of bound accesses in ip6gre_err()
> 
> If GRE flags contains GRE_KEY, the following expression
> *(((__be32 *)p) + (grehlen / 4) - 1)
> 
> accesses data ~40 bytes after the expected point, since
> grehlen includes the size of IPv6 headers.
> 
> Let's use a "struct gre_base_hdr *greh" pointer to make this
> code more readable. 
> 
> p[1] becomes greh->protocol.
> grhlen is the GRE header length.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

So the bug is that we include offset twice in the calculation.

Applied and queued up for -stable, thanks.
