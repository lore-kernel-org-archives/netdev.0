From: Jeba Anandhan <jeba.anandhan@vaioni.com>
Subject: Re: SMP code / network stack
Date: Thu, 10 Jan 2008 15:26:59 +0000
Message-ID: <1199978819.29856.43.camel@vglwks010.vgl2.office.vaioni.com>
References: <1199973946.29856.27.camel@vglwks010.vgl2.office.vaioni.com>
	 <20080110154548.4b78ec7c.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matthew.hattersley@vaioni.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vglsrv002.office.vaioni.com ([84.19.35.12]:3427 "EHLO
	vglsrv02.vgl2.office.vaioni.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754254AbYAJP2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:28:37 -0500
In-Reply-To: <20080110154548.4b78ec7c.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
Thanks for the reply. I have one more doubt. For example, if we have 2
processor and 4 ethernet cards. Only CPU0 does all work through 8 cards.
If we set the affinity to each ethernet card as CPU number, will it be
efficient?.

Will this be default behavior?

# cat /proc/interrupts 
           CPU0       CPU1       
  0:   11472559   74291833    IO-APIC-edge  timer
  2:          0          0          XT-PIC  cascade
  8:          0          1    IO-APIC-edge  rtc
 81:          0          0   IO-APIC-level  ohci_hcd
 97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
 97: 3830012232        847   IO-APIC-level  ehci_hcd, eth1
 97: 5830052231        847   IO-APIC-level  ehci_hcd, eth2
 97: 6830032213        847   IO-APIC-level  ehci_hcd, eth3
#sleep 10

# cat /proc/interrupts 
           CPU0       CPU1       
  0:   11472559   74291833    IO-APIC-edge  timer
  2:          0          0          XT-PIC  cascade
  8:          0          1    IO-APIC-edge  rtc
 81:          0          0   IO-APIC-level  ohci_hcd
 97: 2031409801        847   IO-APIC-level  ehci_hcd, eth0
 97: 4813981390        847   IO-APIC-level  ehci_hcd, eth1
 97: 7123982139        847   IO-APIC-level  ehci_hcd, eth2
 97: 8030193010        847   IO-APIC-level  ehci_hcd, eth3


Instead of the above mentioned ,if we set the affinity for eth2 and
eth3.
the output will be

# cat /proc/interrupts 
           CPU0       CPU1       
  0:   11472559   74291833    IO-APIC-edge  timer
  2:          0          0          XT-PIC  cascade
  8:          0          1    IO-APIC-edge  rtc
 81:          0          0   IO-APIC-level  ohci_hcd
 97: 1830022231        847   IO-APIC-level  ehci_hcd, eth0
 97: 3830012232        847   IO-APIC-level  ehci_hcd, eth1
 97: 5830052231        923   IO-APIC-level  ehci_hcd, eth2
 97: 6830032213        1230   IO-APIC-level  ehci_hcd, eth3
#sleep 10

# cat /proc/interrupts 
           CPU0       CPU1       
  0:   11472559   74291833    IO-APIC-edge  timer
  2:          0          0          XT-PIC  cascade
  8:          0          1    IO-APIC-edge  rtc
 81:          0          0   IO-APIC-level  ohci_hcd
 97: 2300022231        847   IO-APIC-level  ehci_hcd, eth0
 97: 4010212232        847   IO-APIC-level  ehci_hcd, eth1
 97: 5830052231        1847   IO-APIC-level  ehci_hcd, eth2
 97: 6830032213        2337   IO-APIC-level  ehci_hcd, eth3

In this case, will the performance improves?.

Thanks
Jeba
On Thu, 2008-01-10 at 15:45 +0100, Eric Dumazet wrote:
