From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: fix state migration copy replay sequence numbers
Date: Fri, 19 May 2017 13:19:07 +0200
Message-ID: <20170519111906.GH22049@secunet.com>
References: <20170518143953.GA64905@AntonyAntony.local>
 <1495190820-14657-1-git-send-email-antony@phenome.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Richard Guy Briggs <rgb@tricolour.ca>,
        "Herbert Xu" <herbert@gondor.apana.org.au>
To: Antony Antony <antony@phenome.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:32892 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdESLTL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 07:19:11 -0400
Content-Disposition: inline
In-Reply-To: <1495190820-14657-1-git-send-email-antony@phenome.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 12:47:00PM +0200, Antony Antony wrote:
> During xfrm migration copy replay and preplay sequence numbers
> from the previous state.
> 
> Here is a tcpdump output showing the problem.
> 10.0.10.46 is running vanilla kernel, is the IKE/IPsec responder.
> After the migration it sent wrong sequence number, reset to 1.
> The migration is from 10.0.0.52 to 10.0.0.53.
> 
> IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7cf), length 136
> IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7cf), length 136
> IP 10.0.0.52.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d0), length 136
> IP 10.0.10.46.4500 > 10.0.0.52.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x7d0), length 136
> 
> IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
> IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]
> IP 10.0.0.53.4500 > 10.0.10.46.4500: NONESP-encap: isakmp: child_sa  inf2[I]
> IP 10.0.10.46.4500 > 10.0.0.53.4500: NONESP-encap: isakmp: child_sa  inf2[R]
> 
> IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d1), length 136
> 
> NOTE: next sequence is wrong 0x1
> 
> IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x1), length 136
> IP 10.0.0.53.4500 > 10.0.10.46.4500: UDP-encap: ESP(spi=0x43ef462d,seq=0x7d2), length 136
> IP 10.0.10.46.4500 > 10.0.0.53.4500: UDP-encap: ESP(spi=0xca1c282d,seq=0x2), length 136
> 
> Signed-off-by: Antony Antony <antony@phenome.org>

Applied, thanks Antony!
