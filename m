From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/12] [IPSEC]: Remove xfrmX_tunnel_check_size
Date: Tue, 16 Oct 2007 23:17:38 +0800
Message-ID: <20071016151738.GA13166@gondor.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au> <E1IhnHJ-0003A4-00@gondolin.me.apana.org.au> <4714CCCC.2040504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3239 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758886AbXJPPRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 11:17:44 -0400
Content-Disposition: inline
In-Reply-To: <4714CCCC.2040504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 04:38:04PM +0200, Patrick McHardy wrote:
>
> Thats true, but for the first case we actually have something in the
> stack doing that, which is NAT and routing by fwmark. Maybe netfilter
> should just send an ICMP error back, that would also solve the problem
> of silently dropped packets when rerouting to an unreachable
> destination.

Crap, NAT is now bane :)

OK Dave, please scratch everything starting from patch 7.
The first 6 patches should be OK though, unless something
else comes up :)

Patrick, my plan to solve this is to move the POST_ROUTING
calls up one-level.  So we'd call them from ip_forward_finish
and where we currently call dst_output.

Let me play with this and see how it turns out.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
