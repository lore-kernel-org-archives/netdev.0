From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Is netif_tx_lock() SMP PREEMPT safe?
Date: Fri, 15 Feb 2008 17:01:03 +0100
Message-ID: <47B5B73F.9050904@cosmosbay.com>
References: <200802151725.05424.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marin Mitov <mitov@issp.bas.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.27]:49598 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210AbYBOQBB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 11:01:01 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2007.orange.fr (SMTP Server) with ESMTP id 426271C000B6
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 17:00:59 +0100 (CET)
In-Reply-To: <200802151725.05424.mitov@issp.bas.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marin Mitov a =E9crit :
> Hi all,
>
> As in: include/linux/netdevice.h (kernel-2.6.24.2) one finds:
>
> static inline void __netif_tx_lock(struct net_device *dev, int cpu)
> {
>         spin_lock(&dev->_xmit_lock);
>         dev->xmit_lock_owner =3D cpu;
> }
>
> static inline void netif_tx_lock(struct net_device *dev)
> {
>         __netif_tx_lock(dev, smp_processor_id());
> }
>
> Does netif_tx_lock(struct net_device *dev) expands into:
>
> cpu =3D smp_processor_id();=20
> <preempt & shift to another cpu (bogus)>
> spin_lock(&dev->_xmit_lock);
> dev->xmit_lock_owner =3D cpu; /* cpu is not the lock owner */
>
> Or to:
>
> spin_lock(&dev->_xmit_lock);
> dev->xmit_lock_owner =3D smp_processor_id();
>
> which is correct?
>
>  =20
Hi Marin

This expands to the first version, but netif_tx_lock() is allways calle=
d=20
with preemption disabled.

(Or checks in smp_processor_id() would just trigger)


Eric
(Cced netdev for network related stuff)





