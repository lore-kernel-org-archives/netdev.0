From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: md5: do not use alloc_percpu()
Date: Sat, 25 Oct 2014 16:11:09 -0400 (EDT)
Message-ID: <20141025.161109.291627513614647003.davem@davemloft.net>
References: <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, cdleonard@gmail.com, netdev@vger.kernel.org,
	jtoppins@cumulusnetworks.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaJYULO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 16:11:14 -0400
In-Reply-To: <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Oct 2014 12:58:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> percpu tcp_md5sig_pool contains memory blobs that ultimately
> go through sg_set_buf().
> 
> -> sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));
> 
> This requires that whole area is in a physically contiguous portion
> of memory. And that @buf is not backed by vmalloc().
> 
> Given that alloc_percpu() can use vmalloc() areas, this does not
> fit the requirements.
> 
> Replace alloc_percpu() by a static DEFINE_PER_CPU() as tcp_md5sig_pool
> is small anyway, there is no gain to dynamically allocate it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 765cf9976e93 ("tcp: md5: remove one indirection level in tcp_md5sig_pool")
> Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>

Applied and queued up for -stable, thanks Eric.

Longer term we should do a proper shash/ahash conversion of the tcp md5
code, using the rules provided by Herbert Xu.

Thanks.
