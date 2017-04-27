From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] driver/net: Fix possible memleaks when fail to
 register_netdevice
Date: Thu, 27 Apr 2017 16:15:59 +0800
Message-ID: <20170427081559.GA1058@gondor.apana.org.au>
References: <1493121710-27910-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        steffen.klassert@secunet.com, netdev@vger.kernel.org,
        Gao Feng <fgao@ikuai8.com>
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:50208 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754268AbdD0IS0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 04:18:26 -0400
Content-Disposition: inline
In-Reply-To: <1493121710-27910-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 08:01:50PM +0800, gfree.wind@foxmail.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> These drivers allocate kinds of resources in init routine, and free
> some resources in the destructor of net_device. It may cause memleak
> when some errors happen after register_netdevice invokes the init
> callback. Because only the uninit callback is invoked in the error
> handler of register_netdevice, but the destructor not. As a result,
> some resources are lost forever.
> 
> Now invokes the destructor instead of free_netdev somewhere, and free
> the left resources in the newlink func when fail to register_netdevice.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

This has the potential of creating future bugs, because there
is no guarantee that the ndo_init function has been invoked at
all.

Wouldn't it be safer to move the freeing from the destructors
into their ndo_uninit functions instead?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
