From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: new NAPI interface broken for POWER architecture?
Date: Wed, 12 Sep 2007 15:10:08 +0200
Message-ID: <OF2D6ED296.BDB04FBF-ONC1257354.00473703-C1257354.0048406C@de.ibm.com>
References: <200709071137.02801.ossthema@de.ibm.com> <20070912.055004.88490155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	ossthema@linux.vnet.ibm.com, shemminger@linux-foundation.org,
	Arnd Bergmann <ARNDB@de.ibm.com>,
	Paul Mackerras <pmac@au1.ibm.com>,
	Michael Ellerman <ellerman@au1.ibm.com>,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:14737 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbXILNWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 09:22:47 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8CDMku9043018
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 13:22:46 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CDMkp31859648
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:22:46 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CDMjL7017536
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 15:22:46 +0200
In-Reply-To: <20070912.055004.88490155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



David Miller <davem@davemloft.net> wrote on 12.09.2007 14:50:04:

> From: Jan-Bernd Themann <ossthema@de.ibm.com>
> Date: Fri, 7 Sep 2007 11:37:02 +0200
>
> > 2) On SMP systems: after netif_rx_complete has been called on CPU1
> >    (+interruts enabled), netif_rx_schedule could be called on CPU2
> >    (irq handler) before net_rx_action on CPU1 has checked
NAPI_STATE_SCHED.
> >    In that case the device would be added to poll lists of CPU1 and
CPU2
> >    as net_rx_action would see NAPI_STATE_SCHED set.
> >    This must not happen. It will be caught when netif_rx_complete is
> >    called the second time (BUG() called)
> >
> > This would mean we have a problem on all SMP machines right now.
>
> This is not a correct statement.
>
> Only on your platform do network device interrupts get moved
> around, no other platform does this.
>
> Sparc64 doesn't, all interrupts stay in one location after
> the cpu is initially choosen.
>
> x86 and x86_64 specifically do not move around network
> device interrupts, even though other device types do
> get dynamic IRQ cpu distribution.
>
> That's why you are the only person seeing this problem.
>
> I agree that it should be fixed, but we should also fix the IRQ
> distribution scheme used on powerpc platforms which is totally
> broken in these cases.

This is definitely not something we can change in the HEA device driver
alone.
It could also affect any other networking cards on POWER (e1000,s2io...).

Paul, Michael, Arndt, what is your opinion here?

Gruss / Regards
Christoph Raisch

