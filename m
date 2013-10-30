From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 10:19:06 +0800
Message-ID: <20131030021905.GA2089@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.220253.1263087684709722001.davem@davemloft.net>
 <20131030020543.GA1925@gondor.apana.org.au>
 <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Dalton <mwdalton@google.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:38918 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751086Ab3J3CTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 22:19:11 -0400
Content-Disposition: inline
In-Reply-To: <CAPshTCgykFMa=4rnQ3TKa2cfgWYj4TgByO2GbzLzq71Y_=oc=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 07:13:50PM -0700, Jerry Chu wrote:
> On Tue, Oct 29, 2013 at 7:05 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> > If we are indeed able to do that, I doubt we would even need
> > the sysctl patch since the GRO performance should be vastly
> > superior to the non-GRO case, even for a router/bridge.
> 
> Probably not the case for the simple forwarding case. See my
> test result of some small (5-8%) CPU+throughput penalty from
> GRO (over GRE tunnel) posted previously. But I can believe
> the number may be very different if the forwarding path involves
> more work (NAT, iptables filtering,...,etc) resulting in a higher per
> pkt cost.

Your numbers are with Eric's current patch that just linearises
the packet, what I'm saying is that you don't need to linearise
these packets since the packet boundaries are still there, just
hidden inside each frag_list.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
