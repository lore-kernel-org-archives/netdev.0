From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: SMP code / network stack
Date: Thu, 10 Jan 2008 15:46:57 -0200
Message-ID: <20080110174657.GL22437@ghostprotocols.net>
References: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com> <20080110154548.4b78ec7c.dada1@cosmosbay.com> <1199978819.29856.43.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	matthew.hattersley@vaioni.com
To: Jeba Anandhan <jeba.anandhan@vaioni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756437AbYAJRrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 12:47:37 -0500
Content-Disposition: inline
In-Reply-To: <1199978819.29856.43.camel@vglwks010.vgl2.office.vaioni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 10, 2008 at 03:26:59PM +0000, Jeba Anandhan escreveu:
> Hi Eric,
> Thanks for the reply. I have one more doubt. For example, if we have 2
> processor and 4 ethernet cards. Only CPU0 does all work through 8 cards.
> If we set the affinity to each ethernet card as CPU number, will it be
> efficient?.
> 
> Will this be default behavior?
> 
> # cat /proc/interrupts 
>            CPU0       CPU1       
>   0:   11472559   74291833    IO-APIC-edge  timer
>   2:          0          0          XT-PIC  cascade
>   8:          0          1    IO-APIC-edge  rtc
>  81:          0          0   IO-APIC-level  ohci_hcd
>  97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
>  97: 3830012232        847   IO-APIC-level  ehci_hcd, eth1
>  97: 5830052231        847   IO-APIC-level  ehci_hcd, eth2
>  97: 6830032213        847   IO-APIC-level  ehci_hcd, eth3
> #sleep 10
> 
> # cat /proc/interrupts 
>            CPU0       CPU1       
>   0:   11472559   74291833    IO-APIC-edge  timer
>   2:          0          0          XT-PIC  cascade
>   8:          0          1    IO-APIC-edge  rtc
>  81:          0          0   IO-APIC-level  ohci_hcd
>  97: 2031409801        847   IO-APIC-level  ehci_hcd, eth0
>  97: 4813981390        847   IO-APIC-level  ehci_hcd, eth1
>  97: 7123982139        847   IO-APIC-level  ehci_hcd, eth2
>  97: 8030193010        847   IO-APIC-level  ehci_hcd, eth3
> 
> 
> Instead of the above mentioned ,if we set the affinity for eth2 and
> eth3.
> the output will be
> 
> # cat /proc/interrupts 
>            CPU0       CPU1       
>   0:   11472559   74291833    IO-APIC-edge  timer
>   2:          0          0          XT-PIC  cascade
>   8:          0          1    IO-APIC-edge  rtc
>  81:          0          0   IO-APIC-level  ohci_hcd
>  97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
>  97: 3830012232        847   IO-APIC-level  ehci_hcd, eth1
>  97: 5830052231        923   IO-APIC-level  ehci_hcd, eth2
>  97: 6830032213        1230   IO-APIC-level  ehci_hcd, eth3
> #sleep 10
> 
> # cat /proc/interrupts 
>            CPU0       CPU1       
>   0:   11472559   74291833    IO-APIC-edge  timer
>   2:          0          0          XT-PIC  cascade
>   8:          0          1    IO-APIC-edge  rtc
>  81:          0          0   IO-APIC-level  ohci_hcd
>  97: 2300022231        847   IO-APIC-level  ehci_hcd, eth0
>  97: 4010212232        847   IO-APIC-level  ehci_hcd, eth1
>  97: 5830052231        1847   IO-APIC-level  ehci_hcd, eth2
>  97: 6830032213        2337   IO-APIC-level  ehci_hcd, eth3
> 
> In this case, will the performance improves?.

ps ax | grep irqbalance

tells what?

If it is enabled please try:

service irqbalance stop
chkconfig irqbalance off

Then reset the smp_affinity entries to ff so and try again.

http://www.irqbalance.org/

- Arnaldo
