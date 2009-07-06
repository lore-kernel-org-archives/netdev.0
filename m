From: Andi Kleen <andi@firstfloor.org>
Subject: Re: >10% performance degradation since 2.6.18
Date: Mon, 6 Jul 2009 10:45:37 +0200
Message-ID: <20090706084537.GB28145@one.firstfloor.org>
References: <20090705040137.GA7747@gondor.apana.org.au> <4A5110B9.4030904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, andi@firstfloor.org,
	arjan@infradead.org, matthew@wil.cx, jens.axboe@oracle.com,
	linux-kernel@vger.kernel.org, douglas.w.styner@intel.com,
	chinang.ma@intel.com, terry.o.prickett@intel.com,
	matthew.r.wilcox@intel.com, Eric.Moore@lsi.com,
	DL-MPTFusionLinux@lsi.com, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41869 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbZGFIpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 04:45:34 -0400
Content-Disposition: inline
In-Reply-To: <4A5110B9.4030904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That seems to presume it is impossible to reprogram the NIC RX queue 
> selection rules?
> 
> If you can add a new 'flow' to a NIC hardware RX queue, surely you can 
> imagine a remove + add operation for a migrated 'flow'...  and thus, at 
> least on the NIC hardware level, flows can follow processes.

The standard on modern NIC hardware is stateless hashing: as in you
don't program in flows, but the hardware just uses a fixed hash
to map the header to a rx queue. You can't really significantly influence
the hash on a per flow basis there (in theory you could chose
specific local port numbers, but you can't do that for the remote
ports or for well known sockets)

There are a few highend NICs that optionally support arbitary flow matching,
but it typically only supports a very limited number of flows
(so you need some fallback anyways) and of course it would
be costly to reprogram the NIC on every socket state change.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
