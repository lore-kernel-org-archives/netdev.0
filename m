From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: bnx2/5709: Strange interrupts spread
Date: Fri, 2 Jul 2010 17:33:00 -0300
Message-ID: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48605 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754289Ab0GBUdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 16:33:02 -0400
Received: by wwb24 with SMTP id 24so603299wwb.1
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 13:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I hope I am posting to the correct place...

I am facing a strange issue on a HP DL 360.

I have 2 internal ethernet cards (the one that came by default with
the server) and 2 additional ethernet cards for a total for 4 ethernet
cards.

The 2 internal cards are running fine as of interrupts (for example eth1):
           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
      CPU6       CPU7

  71:        604      11933         40       1537          0
0          0       6043   PCI-MSI-edge      eth1-0
  72:      24805       9795       3606          0        128
0       3365          0   PCI-MSI-edge      eth1-1
  73:          0        279          0        429         38
16540          0      30843   PCI-MSI-edge      eth1-2
  74:          0          0      25365        267          0
0         89      15541   PCI-MSI-edge      eth1-3
  75:       7244      24108          0          0      16488
0        240          0   PCI-MSI-edge      eth1-4
  76:      21378       3628       7726          0         49
247       2871          0   PCI-MSI-edge      eth1-5
  77:          0          0      47199        459         13
46      63064         18   PCI-MSI-edge      eth1-6
  78:          0       6230         67        283        259
82       7846      27130   PCI-MSI-edge      eth1-7

On eth2 (external card) all interrupts goes to CPU0
           CPU0       CPU1       CPU2       CPU3       CPU4       CPU5
      CPU6       CPU7
  80:   46973077          0          0            0            0
   0          0   PCI-MSI-edge      eth2-0
  81:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-1
  82:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-2
  83:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-3
  84:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-4
  85:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-5
  86:          0          0       2445          0         37
0       8463         13   PCI-MSI-edge      eth2-6
  87:          0          0          0          0          0
0          0          0   PCI-MSI-edge      eth2-7

If I understand correctly the RSS hash is used to dispatch the packets
into the different queues running on the different CPU.

Why then my internal cards are running fine but the additional cards
(eth2 and eth3) are presenting this behavior where all interrupts goes
to one CPU?

Thanks for your help in understanding this. (see below for config details)

Christophe.

All are detected correctly at boot:
Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.8e (April 13, 2010)
bnx2 0000:02:00.0: PCI INT A -> GSI 31 (level, low) -> IRQ 31
bnx2 0000:02:00.0: setting latency timer to 64
eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
at mem f4000000, IRQ 31, node addr f4:ce:46:86:a1:00
bnx2 0000:02:00.1: PCI INT B -> GSI 39 (level, low) -> IRQ 39
bnx2 0000:02:00.1: setting latency timer to 64
eth1: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
at mem f2000000, IRQ 39, node addr f4:ce:46:86:a1:02
bnx2 0000:07:00.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
bnx2 0000:07:00.0: setting latency timer to 64
eth2: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
at mem fa000000, IRQ 24, node addr 00:26:55:87:17:98
bnx2 0000:07:00.1: PCI INT B -> GSI 34 (level, low) -> IRQ 34
bnx2 0000:07:00.1: setting latency timer to 64
eth3: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
at mem f8000000, IRQ 34, node addr 00:26:55:87:17:9a

Kernel is 2.6.31-13
Broadcom driver bnx2 v2.0.8e

eth0 is a normal interface with an Ip address
eth1 is a normal interface with an Ip address
eth2 belongs to a bridge interface without an ip address, running tc (htb)
eth3 belongs to the same bridge interface without an ip address
