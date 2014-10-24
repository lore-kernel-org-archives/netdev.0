From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net] tcp: md5: do not use alloc_percpu()
Date: Thu, 23 Oct 2014 21:45:28 -0600
Message-ID: <5449CB58.40100@gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>	 <5448A72D.1050806@cumulusnetworks.com>	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com> <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:44557 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002AbaJXDpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 23:45:31 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so670588pdj.41
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 20:45:31 -0700 (PDT)
In-Reply-To: <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/14, 1:58 PM, Eric Dumazet wrote:
> From: Eric Dumazet<edumazet@google.com>
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
> Signed-off-by: Eric Dumazet<edumazet@google.com>
> Fixes: 765cf9976e93 ("tcp: md5: remove one indirection level in tcp_md5sig_pool")
> Reported-by: Crestez Dan Leonard<cdleonard@gmail.com>

Too much time (and too many changes) has passed for this to apply easily 
to v3.4 kernels.

David
