From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Fri, 3 Jul 2009 15:55:30 +0800
Message-ID: <20090703075530.GA25190@gondor.apana.org.au>
References: <20090602.171418.186096253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49382 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752486AbZGCHzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 03:55:47 -0400
Content-Disposition: inline
In-Reply-To: <20090602.171418.186096253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
>> I think I'll do this in the driver for now, and let's revisit doing it 
>> generically later?
> 
> That might be the best course of action for the time being.
> This whole area is a rat's nest.

Calling skb_orphan like this should be forbidden.  Apart from the
problems already raised, it is a sign that the driver is trying to
paper over a more serious issue of not cleaning up skb's timely.

Yes skb_orphan will work for the cases where calling the skb
destructor allows forward progress, but for the cases where you
really need to the skb to be freed (e.g., iSCSI or Xen), this
simply doesn't work.

So anytime someone tries to propose such a solution it is a sign
that they have bigger problems.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
