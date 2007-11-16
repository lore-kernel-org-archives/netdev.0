From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/5] udp: memory limitation by using udp_mem
Date: Fri, 16 Nov 2007 10:12:42 +0800
Message-ID: <20071116021241.GD32509@gondor.apana.org.au>
References: <473CBDAD.1010708@redhat.com> <473CBF16.8040001@redhat.com> <20071115.152353.100893781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: haoki@redhat.com, netdev@vger.kernel.org,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1809 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754475AbXKPCN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 21:13:29 -0500
Content-Disposition: inline
In-Reply-To: <20071115.152353.100893781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 03:23:53PM -0800, David Miller wrote:
>
> We don't have tests all over the place to see if a socket is TCP or
> DCCP or SCTP in order to implement memory accounting there, because we
> did it for connection oriented protocols cleanly, seperating things
> via callbacks etc.
> 
> I would like to see the datagram memory accounting work similarly.

I agree.  In fact if we adopt some of the conventions used by
stream protocols such as the use of sk_forward_alloc, we should
be able to share code with TCP accounting too.

As it is every packet updates a global counter, using sk_forward_alloc
would mean that for most packets you only update a per-socket counter
which then would feed into the global counter at points such as socket
creation and destruction.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
