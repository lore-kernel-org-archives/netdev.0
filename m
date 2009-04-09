From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per device
Date: Thu, 9 Apr 2009 12:39:14 +0200
Message-ID: <200904091239.14630.borntraeger@de.ibm.com>
References: <200904090952.01175.borntraeger@de.ibm.com> <20090409093817.GA5760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:45788 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934029AbZDIKjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 06:39:19 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.1/8.13.1) with ESMTP id n39AdGfp004012
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 10:39:16 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n39AdGJO4190284
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 12:39:16 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n39AdGxr024559
	for <netdev@vger.kernel.org>; Thu, 9 Apr 2009 12:39:16 +0200
In-Reply-To: <20090409093817.GA5760@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Thursday 09 April 2009 11:38:17 schrieb Herbert Xu:
> On Thu, Apr 09, 2009 at 09:52:01AM +0200, Christian Borntraeger wrote:
> > with my kvm test scenario on s390 I get the following oops:
> > Unable to handle kernel pointer dereference at virtual kernel address
> > 0000000400000000 Oops: 003b [#1] SMP
> > Modules linked in: kvm dm_multipath sunrpc qeth_l2 dm_mod qeth ccwgroup
> > CPU: 0 Not tainted 2.6.29-kvm-06607-ga317a1e-dirty #8
> > Process kuli (pid: 14827, task: 00000000b3df8138, ksp: 00000000b4703a98)
> > Krnl PSW : 0404e00180000000 0000000000171278
> > (__lock_acquire+0x3d4/0x191c)
>
> This is weird.  It looks like it's dying on the wake_up_interruptible_sync
> in tun_sock_write_space.  However, I can't see how that can cause this.
>
> Were you in the middle of removing the tun module?
>
> Cheers,

No, I was booting up a guest and the guest sent its first packet (arp). I 
forgot to mention, that the tap device is persistent and attached to a 
bridge. Does that give a clue?

Christian
