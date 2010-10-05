From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook
	in xfrm_input()
Date: Tue, 5 Oct 2010 14:27:32 +0800
Message-ID: <20101005062732.GA27337@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org> <20101004084041.GB17939@gondor.apana.org.au> <87vd5h7kbh.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56927 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab0JEG1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 02:27:44 -0400
Content-Disposition: inline
In-Reply-To: <87vd5h7kbh.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 10:51:46PM +0200, Arnaud Ebalard wrote:
> 
> Either I don't understand the sentence or this is not feasible: the
> thing is there is nothing in the packet to demultiplex like nh for
> RH2/HAO. Here, we only lookup for a remapping state when there is a
> mismatch in the source/destination addresses expected for the SA.
> 
> That's the reason IRO remapping states only apply to IPsec traffic.

I see.

The thing that bugs me is that you've added an indirect call for
all IPsec traffic when only MIPv6 users would ever need this.

With your remapping, would it be possible to add dummy xfrm_state
objects with the remapped destination address that could then call
xfrm6_input_addr?

That way normal IPsec users would not be affected at all while
preserving your new functionality.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
