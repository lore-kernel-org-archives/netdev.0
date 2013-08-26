From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for
 xfrm tunnel mode callback
Date: Mon, 26 Aug 2013 13:35:59 +0200
Message-ID: <20130826113559.GM26773@secunet.com>
References: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: saurabh.mohan@vyatta.com, herbert@gondor.hengli.com.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51048 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524Ab3HZLgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 07:36:01 -0400
Content-Disposition: inline
In-Reply-To: <1377240424-11758-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 02:47:04PM +0800, Fan Du wrote:
> Some thoughts on IPv4 VTI implementation:
> 
> The connection between VTI receiving part and xfrm tunnel mode input process
> is hardly a "xfrm_tunnel", xfrm_tunnel is used in places where, e.g ipip/sit
> and xfrm4_tunnel, acts like a true "tunnel" device.
> 
> In addition, IMHO, VTI doesn't need vti_err to do something meaningful, as all
> VTI needs is just a notifier to be called whenever xfrm_input ingress a packet
> to update statistics.
> 
> So this patch introduce xfrm_tunnel_notifier and meanwhile wipe out vti_erri
> code.

Btw. who calls vti_err()? I don't see a hook which would call the vti
error handler. I'm still not absolutely sure whether we need it or not,
but we should either remove it or add a hook to call it.
