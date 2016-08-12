From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] net/xfrm_input: fix possible NULL deref of
 tunnel.ip6->parms.i_key
Date: Fri, 12 Aug 2016 09:16:56 +0200
Message-ID: <20160812071656.GH5710@gauss.secunet.com>
References: <1470826497-3931-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <vasily.isaenko@oracle.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60082 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbcHLHRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 03:17:06 -0400
Content-Disposition: inline
In-Reply-To: <1470826497-3931-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 01:54:57PM +0300, Alexey Kodanev wrote:
> Running LTP 'icmp-uni-basic.sh -6 -p ipcomp -m tunnel' test over
> openvswitch + veth can trigger kernel panic:
> 
>   BUG: unable to handle kernel NULL pointer dereference
>   at 00000000000000e0 IP: [<ffffffff8169d1d2>] xfrm_input+0x82/0x750
>   ...
>   [<ffffffff816d472e>] xfrm6_rcv_spi+0x1e/0x20
>   [<ffffffffa082c3c2>] xfrm6_tunnel_rcv+0x42/0x50 [xfrm6_tunnel]
>   [<ffffffffa082727e>] tunnel6_rcv+0x3e/0x8c [tunnel6]
>   [<ffffffff8169f365>] ip6_input_finish+0xd5/0x430
>   [<ffffffff8169fc53>] ip6_input+0x33/0x90
>   [<ffffffff8169f1d5>] ip6_rcv_finish+0xa5/0xb0
>   ...
> 
> It seems that tunnel.ip6 can have garbage values and also dereferenced
> without a proper check, only tunnel.ip4 is being verified. Fix it by
> adding one more if block for AF_INET6 and initialize tunnel.ip6 with NULL
> inside xfrm6_rcv_spi() (which is similar to xfrm4_rcv_spi()).
> 
> Fixes: 049f8e2 ("xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input")
> 
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied to the ipsec tree, thanks a lot for the fix!
