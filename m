From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] vti6: fix input path
Date: Wed, 21 Sep 2016 12:19:43 +0200
Message-ID: <20160921101943.GJ31137@gauss.secunet.com>
References: <1474294677-1232-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Alexey Kodanev <alexey.kodanev@oracle.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37475 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754035AbcIUKTs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 06:19:48 -0400
Content-Disposition: inline
In-Reply-To: <1474294677-1232-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 04:17:57PM +0200, Nicolas Dichtel wrote:
> Since commit 1625f4529957, vti6 is broken, all input packets are dropped
> (LINUX_MIB_XFRMINNOSTATES is incremented).
> 
> XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 is set by vti6_rcv() before calling
> xfrm6_rcv()/xfrm6_rcv_spi(), thus we cannot set to NULL that value in
> xfrm6_rcv_spi().
> 
> A new function xfrm6_rcv_tnl() that enables to pass a value to
> xfrm6_rcv_spi() is added, so that xfrm6_rcv() is not touched (this function
> is used in several handlers).
> 
> CC: Alexey Kodanev <alexey.kodanev@oracle.com>
> Fixes: 1625f4529957 ("net/xfrm_input: fix possible NULL deref of tunnel.ip6->parms.i_key")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied to the ipsec tree, thanks Nicolas!
