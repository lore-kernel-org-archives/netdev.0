From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] vti: use right inner_mode for inbound inter address
 family policy checks
Date: Fri, 9 Sep 2016 10:36:42 +0200
Message-ID: <20160909083642.GA31137@gauss.secunet.com>
References: <20160904105713.3mqgszgqi7waxk5l@toau>
 <20160906111522.GG31137@gauss.secunet.com>
 <20160907184038.2neg44xtvlunlrmu@toau>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <thomas.zeitlhofer+lkml@ze-it.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60031 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752605AbcIIIgu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 04:36:50 -0400
Content-Disposition: inline
In-Reply-To: <20160907184038.2neg44xtvlunlrmu@toau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 08:40:38PM +0200, thomas.zeitlhofer+lkml@ze-it.at wrote:
> In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
> vti6), the inbound policy checks in vti_rcv_cb() and vti6_rcv_cb() are
> using the wrong address family. As a result, all inbound inter address
> family traffic is dropped.
> 
> Use the xfrm_ip2inner_mode() helper, as done in xfrm_input() (i.e., also
> increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error), to select the
> inner_mode that contains the right address family for the inbound policy
> checks.
> 
> Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
> ---
> 
> Notes:
>     v2: implement review comments from Steffen (thanks for the reply):
>     
>     	- return -EINVAL in case of error
>     
>     	- increment LINUX_MIB_XFRMINSTATEMODEERROR in case of error
>     
>     	  Just to point that out, in case there are arguments against it:
>     	  this is done in the namespace of skb->dev and not in the
>     	  t(unnel)?->net namespace.

This is ok because the states are configured in that namespace.

I've applied this to the ipsec tree, thanks a lot!
