From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Sat, 4 Jul 2009 17:09:10 +0800
Message-ID: <20090704090910.GA2185@gondor.apana.org.au>
References: <20090703075530.GA25190@gondor.apana.org.au> <20090703.200254.172991821.davem@davemloft.net> <20090704030830.GA32442@gondor.apana.org.au> <20090703.201347.146036232.davem@davemloft.net> <20090704074245.GA1615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53097 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751414AbZGDJJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 05:09:22 -0400
Content-Disposition: inline
In-Reply-To: <20090704074245.GA1615@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 04, 2009 at 03:42:45PM +0800, Herbert Xu wrote:
> 
> Here's an idea: We let the sender decide whether we need to enable
> notification.  This decision would be carried as a flag in the skb.
> For example, UDP would set this flag when its socket buffer is close
> to capacity.  Routing would set this flag per NAPI run, etc.

Actually it doesn't even matter for routing because only those
that are charged by the skb's or the pages care and they're the
only ones that would need to set this.

One potential problem is if the socket is constantly running
close to capacity, but that should only happen if the device
TX queue is also close to capacity which means that the qdisc
queue should be non-empty.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
