From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 11:50:52 +0200
Message-ID: <4FE19CFC.8030408@profihost.ag>
References: <4FE0EA33.1000309@profihost.ag>  <1340141493.4604.773.camel@edumazet-glaptop>  <4FE17522.5050005@profihost.ag>  <1340176940.4604.801.camel@edumazet-glaptop>  <4FE1881B.7030800@profihost.ag>  <1340181676.4604.838.camel@edumazet-glaptop>  <4FE192A1.6000000@profihost.ag>  <4FE193FA.5030802@profihost.ag>  <1340183854.4604.847.camel@edumazet-glaptop>  <4FE196F4.3040900@profihost.ag>  <1340184528.4604.849.camel@edumazet-glaptop>  <4FE198FE.5050202@profihost.ag> <1340185645.4604.853.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:36870 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2FTJu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:50:59 -0400
In-Reply-To: <1340185645.4604.853.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.06.2012 11:47, schrieb Eric Dumazet:
> On Wed, 2012-06-20 at 11:33 +0200, Stefan Priebe - Profihost AG wrote:
>
>> Sure. In that case i get 4Gbit/s in both variants. I also tried two
>> other different machines same result.
>>
>
> So 3.5 on receiver is the problem, it seems ?
Yes.

> And you checked all the stuff about irq affinities, i presume, since a
> lot of things might have changed between 2.6.32 and 3.5 ?

It is a single core E5 Xeon - i've set the affinity like this:

eth2 mask=1 for /proc/irq/83/smp_affinity
eth2 mask=2 for /proc/irq/84/smp_affinity
eth2 mask=4 for /proc/irq/85/smp_affinity
eth2 mask=8 for /proc/irq/86/smp_affinity
eth2 mask=10 for /proc/irq/87/smp_affinity
eth2 mask=20 for /proc/irq/88/smp_affinity
eth2 mask=40 for /proc/irq/89/smp_affinity
eth2 mask=80 for /proc/irq/90/smp_affinity

> cat /proc/interrupts

# cat /proc/interrupts
             CPU0       CPU1       CPU2       CPU3       CPU4       CPU5 
       CPU6       CPU7
    0:        141          0          0          0          0          0 
          0          0   IO-APIC-edge      timer
    1:          1          8          0          0          0          0 
          0          0   IO-APIC-edge      i8042
    9:          0          0          0          0          0          0 
          0          0   IO-APIC-fasteoi   acpi
   12:          0          3          0          0          0          0 
          0          0   IO-APIC-edge      i8042
   14:          0          0          0          0          0          0 
          0          0   IO-APIC-edge      ide0
   15:          0          0          0          0          0          0 
          0          0   IO-APIC-edge      ide1
   16:          0          0         26          0          0          0 
          0          0   IO-APIC-fasteoi   ehci_hcd:usb1
   23:          0          0         30          0          0          0 
          0          0   IO-APIC-fasteoi   ehci_hcd:usb2
   64:          0          0          0      81979          0          0 
          0          0   PCI-MSI-edge      ahci
   65:          0          0          0          1          0          0 
          0          0   PCI-MSI-edge      eth0
   66:          0          0          0          0       1090          0 
          0          0   PCI-MSI-edge      eth0-TxRx-0
   67:          0          0          0          0        411          0 
          0          0   PCI-MSI-edge      eth0-TxRx-1
   68:          0          0          0          0        592          0 
          0          0   PCI-MSI-edge      eth0-TxRx-2
   69:          0          0          0          0        472          0 
          0          0   PCI-MSI-edge      eth0-TxRx-3
   70:          0          0          0          0          0       1196 
          0          0   PCI-MSI-edge      eth0-TxRx-4
   71:          0          0          0          0          0        374 
          0          0   PCI-MSI-edge      eth0-TxRx-5
   72:          0          0          0          0          0        405 
          0          0   PCI-MSI-edge      eth0-TxRx-6
   73:          0          0          0          0          0        468 
          0          0   PCI-MSI-edge      eth0-TxRx-7
   83:      31278          0          0         65          0          0 
          0          0   PCI-MSI-edge      eth2-TxRx-0
   84:          0      36311          0          0         61          0 
          0          0   PCI-MSI-edge      eth2-TxRx-1
   85:          0          0      46189          0         61          0 
          0          0   PCI-MSI-edge      eth2-TxRx-2
   86:          0          0          0      28712         67          0 
          0          0   PCI-MSI-edge      eth2-TxRx-3
   87:          0          0          0          0      28089          0 
          0          0   PCI-MSI-edge      eth2-TxRx-4
   88:          0          0          0          0          0      34982 
          0          0   PCI-MSI-edge      eth2-TxRx-5
   89:          0          0          0          0          0         61 
      32420          0   PCI-MSI-edge      eth2-TxRx-6
   90:          0          0          0          0          0         61 
          0      25922   PCI-MSI-edge      eth2-TxRx-7
   91:          0          0          0          0          0          3 
          0          0   PCI-MSI-edge      eth2
  NMI:         13         12         15         22          5          5 
          5          5   Non-maskable interrupts
  LOC:      58919      61420      65519      82647      35519      40489 
      27141      30228   Local timer interrupts
  SPU:          0          0          0          0          0          0 
          0          0   Spurious interrupts
  PMI:         13         12         15         22          5          5 
          5          5   Performance monitoring interrupts
  IWI:          0          0          0          0          0          0 
          0          0   IRQ work interrupts
  RTR:          6          0          0          0          0          0 
          0          0   APIC ICR read retries
  RES:      15116       4521       2418       1814       2375       1615 
       1488       1367   Rescheduling interrupts
  CAL:        134        148        100        162        170        172 
        172        172   Function call interrupts
  TLB:        422        486        415        483        460        460 
        476        398   TLB shootdowns
  TRM:          0          0          0          0          0          0 
          0          0   Thermal event interrupts
  THR:          0          0          0          0          0          0 
          0          0   Threshold APIC interrupts
  MCE:          0          0          0          0          0          0 
          0          0   Machine check exceptions
  MCP:          4          4          4          4          4          4 
          4          4   Machine check polls

> what kind of NIC it is ?

# lspci | grep 10-Giga
06:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)
06:00.1 Ethernet controller: Intel Corporation 82599EB 10-Gigabit 
SFI/SFP+ Network Connection (rev 01)

Stefan
