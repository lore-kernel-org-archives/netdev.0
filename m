From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Sat, 25 Jul 2009 19:12:07 +0800
Message-ID: <20090725111207.GA518@gondor.apana.org.au>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local> <20090724083749.GA23521@gondor.apana.org.au> <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com> <20090725032436.GA30741@gondor.apana.org.au> <20090725110409.GA3086@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44465 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752685AbZGYLMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 07:12:18 -0400
Content-Disposition: inline
In-Reply-To: <20090725110409.GA3086@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 25, 2009 at 01:04:09PM +0200, Jarek Poplawski wrote:
> 
> It would be nice to establish what difference is made by each part of
> this patch. The check for stopped queue before each skb xmit was done
> earlier too, so it's not exactly multiqueue penalization.

No, but getting into qdisc_restart when we know that the queue is
stopped is just silly.  The only reason that is done right now is
because of the pathological case where a packet on qdisc X maps to
hardware queue Y.  This is something which almost nobody uses and
yet it penalises everybody.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
