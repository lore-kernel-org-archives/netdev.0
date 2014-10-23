From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: md5: percpu tcp_md5sig_pool must not span pages
Date: Thu, 23 Oct 2014 12:34:09 -0700
Message-ID: <1414092849.20845.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	David Ahern <dsahern@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:48758 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbaJWTeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 15:34:11 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1654804pab.38
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 12:34:10 -0700 (PDT)
In-Reply-To: <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 09:33 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> percpu tcp_md5sig_pool contains memory blobs that ultimately
> go through sg_set_buf().
> 
> -> sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));
> 
> This requires that whole area is in a physically contiguous portion
> of memory.
> 
> Given that alloc_percpu() can use vmalloc() areas, we need to make sure
> tcp_md5sig_pool is allocated from a single page.
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 765cf9976e93 ("tcp: md5: remove one indirection level in tcp_md5sig_pool")
> Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>
> ---

Self Nack, we definitely need to avoid vmalloc() in the first place.
