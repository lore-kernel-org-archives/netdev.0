From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Sat, 4 Jul 2009 15:42:45 +0800
Message-ID: <20090704074245.GA1615@gondor.apana.org.au>
References: <20090703075530.GA25190@gondor.apana.org.au> <20090703.200254.172991821.davem@davemloft.net> <20090704030830.GA32442@gondor.apana.org.au> <20090703.201347.146036232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39326 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752729AbZGDHnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 03:43:04 -0400
Content-Disposition: inline
In-Reply-To: <20090703.201347.146036232.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 03, 2009 at 08:13:47PM -0700, David Miller wrote:
>
> NIU
> 
> I basically can't defer interrupts because the chip supports
> per-TX-desc interrupt indications but it lacks an "all TX queue sent"
> event.  So if, say, tell it to interrupt every 1/4 of the TX queue
> then up to 1/4 of the queue can have packets "stuck" in there
> if TX activity all of a sudden ceases.

Here's an idea: We let the sender decide whether we need to enable
notification.  This decision would be carried as a flag in the skb.
For example, UDP would set this flag when its socket buffer is close
to capacity.  Routing would set this flag per NAPI run, etc.

Of course you'd ignore this flag completely if the qdisc queue is
non-empty.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
