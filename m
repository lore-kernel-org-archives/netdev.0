From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per
	device
Date: Thu, 9 Apr 2009 17:38:17 +0800
Message-ID: <20090409093817.GA5760@gondor.apana.org.au>
References: <200904090952.01175.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36514 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754939AbZDIJiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 05:38:24 -0400
Content-Disposition: inline
In-Reply-To: <200904090952.01175.borntraeger@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 09, 2009 at 09:52:01AM +0200, Christian Borntraeger wrote:
> 
> with my kvm test scenario on s390 I get the following oops:
> Unable to handle kernel pointer dereference at virtual kernel address 0000000400000000
> Oops: 003b [#1] SMP
> Modules linked in: kvm dm_multipath sunrpc qeth_l2 dm_mod qeth ccwgroup
> CPU: 0 Not tainted 2.6.29-kvm-06607-ga317a1e-dirty #8
> Process kuli (pid: 14827, task: 00000000b3df8138, ksp: 00000000b4703a98)
> Krnl PSW : 0404e00180000000 0000000000171278 (__lock_acquire+0x3d4/0x191c)

This is weird.  It looks like it's dying on the wake_up_interruptible_sync
in tun_sock_write_space.  However, I can't see how that can cause this.

Were you in the middle of removing the tun module?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
