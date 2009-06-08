From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from
 untrusted sources
Date: Mon, 08 Jun 2009 10:04:47 -0700
Message-ID: <1244480687.18220.36.camel@w-sridhar.beaverton.ibm.com>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com>
	 <20090608051608.GA19748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	rusty@rustcorp.com.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:51964 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754203AbZFHREs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 13:04:48 -0400
In-Reply-To: <20090608051608.GA19748@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-08 at 15:16 +1000, Herbert Xu wrote:
> On Fri, Jun 05, 2009 at 05:16:31PM -0700, Sridhar Samudrala wrote:
> >
> > +	/* Software UFO is not yet supported */
> > +	segs = ERR_PTR(-EPROTONOSUPPORT);
> 
> Hmm, we need to fill this in before you start using it for virt.
> After all, it's very difficult for the guest to know whether the
> output device on the host is going to be able to do UFO or not.

OK. Can we use skb_segment() to do IP fragmentation of UDP packets?
Or does it only support TCP segementation?
The function itself looks protocol independent and if it is simply
splitting large skb into a list of mtu sized skb's, can we fixup the
ip header differently for UDP packets(id and frag_off) in inet_gso_segment
and ipv6_gso_segment?


Thanks
Sridhar

