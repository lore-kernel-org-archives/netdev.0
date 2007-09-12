From: Arnd Bergmann <ARNDB@de.ibm.com>
Subject: Re: new NAPI interface broken for POWER architecture?
Date: Wed, 12 Sep 2007 17:18:36 +0200
Message-ID: <200709121718.37820.ARNDB@de.ibm.com>
References: <200709071137.02801.ossthema@de.ibm.com> <20070912.055004.88490155.davem@davemloft.net>  <OF2D6ED296.BDB04FBF-ONC1257354.00473703-C1257354.0048406C@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>, netdev@vger.kernel.org,
	ossthema@linux.vnet.ibm.com, shemminger@linux-foundation.org,
	Paul Mackerras <pmac@au1.ibm.com>,
	Michael Ellerman <ellerman@au1.ibm.com>,
	linuxppc-dev@ozlabs.org
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:33333 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933205AbXILPVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 11:21:55 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8CFLt9b019842
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:21:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CFLsDC546824
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:21:54 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CFLrf2016494
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:21:54 -0400
In-Reply-To: <OF2D6ED296.BDB04FBF-ONC1257354.00473703-C1257354.0048406C@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 September 2007, Christoph Raisch wrote:
> David Miller <davem@davemloft.net> wrote on 12.09.2007 14:50:04:
>
> > I agree that it should be fixed, but we should also fix the IRQ
> > distribution scheme used on powerpc platforms which is totally
> > broken in these cases.
> 
> This is definitely not something we can change in the HEA device driver
> alone.
> It could also affect any other networking cards on POWER (e1000,s2io...).
> 
> Paul, Michael, Arndt, what is your opinion here?

The situation on Cell with the existing south bridge chips is that
interrupts _never_ get moved around, but are routed to specific
SMT threads by the firmware, while Linux does not interfere with
this.

We have been thinking about changing this so we can distribute
interrupts over all SMT threads in a given NUMA node, or even
over all logical CPUs in the system by reprogramming the
interrupt controller after each interrupt, but the current Axon bridge
chip will always have all devices routed to the same target CPU,
so it's unclear whether that is even an advantage.

	Arnd <><
