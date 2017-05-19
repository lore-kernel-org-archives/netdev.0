From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: fix state migration replay sequence numbers
Date: Fri, 19 May 2017 11:59:37 +0200
Message-ID: <20170519095937.GB22049@secunet.com>
References: <20170518143953.GA64905@AntonyAntony.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        Richard Guy Briggs <rgb@tricolour.ca>
To: Antony Antony <antony@phenome.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58366 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750805AbdESJ7k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 05:59:40 -0400
Content-Disposition: inline
In-Reply-To: <20170518143953.GA64905@AntonyAntony.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 04:39:53PM +0200, Antony Antony wrote:
> During xfrm migration replay and preplay sequence numbers are not 
> copied from the previous state. 
> 
> Here is tcpdump output showing the problem.
> 10.0.10.46 is running vanilla kernel, IKE/IPsec responder.
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
> The attached patch fix it by copying replay and preplay.

The patch looks ok, but please do a v2 and put the above
informations into the commit message. This is usefull
information that we would loose otherwise.

Thanks!
