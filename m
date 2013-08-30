From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next] {ipv4,xfrm}: Introduce xfrm_tunnel_notifier
 for xfrm tunnel mode callback
Date: Fri, 30 Aug 2013 09:38:01 +0200
Message-ID: <20130830073801.GH7660@secunet.com>
References: <1377673780-9778-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.hengli.com.au, saurabh.mohan@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:48014 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab3H3HiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 03:38:06 -0400
Content-Disposition: inline
In-Reply-To: <1377673780-9778-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 28, 2013 at 03:09:40PM +0800, Fan Du wrote:
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
> A IPsec protected packet is first handled by protocol handlers, e.g AH/ESP,
> to check packet authentication or encryption rightness. PMTU update is taken
> care of in this stage by protocol error handler.
> 
> Then the packet is rearranged properly depending on whether it's transport
> mode or tunnel mode packed by mode "input" handler. The VTI handler code
> takes effects in this stage in tunnel mode only. So it neither need propagate
> PMTU, as it has already been done if necessary, nor the VTI handler is
> qualified as a xfrm_tunnel. 
> 
> So this patch introduces xfrm_tunnel_notifier and meanwhile wipe out vti_err
> code.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: David S. Miller <davem@davemloft.net>
> Reviewed-by: Saurabh Mohan <saurabh.mohan@vyatta.com>

Applied to ipsec-next, thanks a lot!
