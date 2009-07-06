From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: >10% performance degradation since 2.6.18
Date: Mon, 6 Jul 2009 09:19:39 +0800
Message-ID: <20090706011939.GD15156@gondor.apana.org.au>
References: <20090705040137.GA7747@gondor.apana.org.au> <4A5110B9.4030904@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, arjan@infradead.org, matthew@wil.cx,
	jens.axboe@oracle.com, linux-kernel@vger.kernel.org,
	douglas.w.styner@intel.com, chinang.ma@intel.com,
	terry.o.prickett@intel.com, matthew.r.wilcox@intel.com,
	Eric.Moore@lsi.com, DL-MPTFusionLinux@lsi.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32887 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751709AbZGFBUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jul 2009 21:20:33 -0400
Content-Disposition: inline
In-Reply-To: <4A5110B9.4030904@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 05, 2009 at 04:44:41PM -0400, Jeff Garzik wrote:
>
> Efficient power usage means scaling _down_ when activity decreases.  A  
> blind "distribute network activity across all CPUs" policy does not  
> appear to be responsive to that type of situation.

I didn't suggest distributing network activity across all CPUs.
It should be distributed across all active CPUs.

> Consider two competing CPU hogs:  a kernel with tons of netfilter tables  
> and rules, plus an application that uses a lot of CPU.
>
> Can you not reach a threshold where it makes more sense to split kernel  
> and userland work onto different CPUs?

In that case the best split would be split the application into
different threads which can then move onto different CPUs.  Doing
what you said above will probably work assuming the CPUs share
cache, otherwise it will suck.

> That seems to presume it is impossible to reprogram the NIC RX queue  
> selection rules?
>
> If you can add a new 'flow' to a NIC hardware RX queue, surely you can  
> imagine a remove + add operation for a migrated 'flow'...  and thus, at  
> least on the NIC hardware level, flows can follow processes.

Right, that would work as long as you can add a rule for each socket
you cared about.  Though it's interesting to know whether the number
of rules can keep up with the number of sockets that we usually
encounter on busy servers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
