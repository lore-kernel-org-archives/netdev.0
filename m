From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] vti: fix NULL dereference in xfrm_input()
Date: Wed, 13 Sep 2017 12:44:16 +0200
Message-ID: <20170913104416.GG31384@secunet.com>
References: <1505217226-31817-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        "David Miller" <davem@davemloft.net>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36566 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751148AbdIMKoT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 06:44:19 -0400
Content-Disposition: inline
In-Reply-To: <1505217226-31817-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 02:53:46PM +0300, Alexey Kodanev wrote:
> Can be reproduced with LTP tests:
>   # icmp-uni-vti.sh -p ah -a sha256 -m tunnel -S fffffffe -k 1 -s 10
> 
> IPv4:
>   RIP: 0010:xfrm_input+0x7f9/0x870
>   ...
>   Call Trace:
>   <IRQ>
>   vti_input+0xaa/0x110 [ip_vti]
>   ? skb_free_head+0x21/0x40
>   vti_rcv+0x33/0x40 [ip_vti]
>   xfrm4_ah_rcv+0x33/0x60
>   ip_local_deliver_finish+0x94/0x1e0
>   ip_local_deliver+0x6f/0xe0
>   ? ip_route_input_noref+0x28/0x50
>   ...
> 
>   # icmp-uni-vti.sh -6 -p ah -a sha256 -m tunnel -S fffffffe -k 1 -s 10
> IPv6:
>   RIP: 0010:xfrm_input+0x7f9/0x870
>   ...
>   Call Trace:
>   <IRQ>
>   xfrm6_rcv_tnl+0x3c/0x40
>   vti6_rcv+0xd5/0xe0 [ip6_vti]
>   xfrm6_ah_rcv+0x33/0x60
>   ip6_input_finish+0xee/0x460
>   ip6_input+0x3f/0xb0
>   ip6_rcv_finish+0x45/0xa0
>   ipv6_rcv+0x34b/0x540
> 
> xfrm_input() invokes xfrm_rcv_cb() -> vti_rcv_cb(), the last callback
> might call skb_scrub_packet(), which in turn can reset secpath.
> 
> Fix it by adding a check that skb->sp is not NULL.
> 
> Fixes: 7e9e9202bccc ("xfrm: Clear RX SKB secpath xfrm_offload")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Patch applied, thanks Alexey!
