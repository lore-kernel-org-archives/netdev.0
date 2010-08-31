From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] net/ipv4: push IP options to CB in
	ip_fragment
Date: Tue, 31 Aug 2010 20:36:41 +0800
Message-ID: <20100831123641.GA31017@gondor.apana.org.au>
References: <20100830200917.GA10754@stratus.com> <1283204118.2405.32.camel@edumazet-laptop> <20100830232147.GB10754@stratus.com> <1283232031.2405.38.camel@edumazet-laptop> <20100831082444.GB29281@gondor.apana.org.au> <1283246271.2550.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bandan Das <bandan.das@stratus.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283246271.2550.35.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2010 at 11:17:51AM +0200, Eric Dumazet wrote:
>
> Once again, the IP stack -> bridge -> IP stack flow bites us,
> because bridge likes to dirty IPCB.

OK, so we're talking about a locally transmitted packet, with
IP options leaving the IP stack, entering bridging, and then
reentering the IP stack?

In that case the packet should no longer be treated as an IP
packet when it enters the bridge.  So if it did have options
and we want to support that in bridging then we need to parse
IP options there as my comment suggested.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
