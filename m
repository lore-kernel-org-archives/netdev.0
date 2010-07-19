From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Mon, 19 Jul 2010 12:55:57 -0300
Message-ID: <AANLkTikfEED5Hvt80G6EnMwPBByMuw4r1Xg2ITjuZ0eV@mail.gmail.com>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39043 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936159Ab0GSPz7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 11:55:59 -0400
Received: by wwb39 with SMTP id 39so338730wwb.1
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 08:55:57 -0700 (PDT)
In-Reply-To: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

So i've been able to do some test today:
If I put the 2 interface in a bridge with no IP adress, the interrupts
are on 1 CPU
If I put the 2 interface in a bridge with IP adress, the interrupts
are still on 1 CPU
If I put the 2 interface outside the bridge with IP address,
everything works fine the interrupts get spread on the CPU

So the conclusion seems to be that when the bnx2 is put into
promiscuous mode by the bridge, the RSS hash stop to work even if
traffic is IP in nature.

Best regards,
Christophe.

On Fri, Jul 2, 2010 at 5:33 PM, Christophe Ngo Van Duc
<cngovanduc@gmail.com> wrote:
> Dear list,
>
> I hope I am posting to the correct place...
>
> I am facing a strange issue on a HP DL 360.
>
> I have 2 internal ethernet cards (the one that came by default with
> the server) and 2 additional ethernet cards for a total for 4 etherne=
t
> cards.
>
> The 2 internal cards are running fine as of interrupts (for example e=
th1):
> =A0 =A0 =A0 =A0 =A0 CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 =A0 CPU2 =A0 =A0 =A0=
 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5
> =A0 =A0 =A0CPU6 =A0 =A0 =A0 CPU7
>
> =A071: =A0 =A0 =A0 =A0604 =A0 =A0 =A011933 =A0 =A0 =A0 =A0 40 =A0 =A0=
 =A0 1537 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 6043 =A0 PCI-MSI-edge =A0 =A0 =A0e=
th1-0
> =A072: =A0 =A0 =A024805 =A0 =A0 =A0 9795 =A0 =A0 =A0 3606 =A0 =A0 =A0=
 =A0 =A00 =A0 =A0 =A0 =A0128
> 0 =A0 =A0 =A0 3365 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0e=
th1-1
> =A073: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0279 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0429 =A0 =A0 =A0 =A0 38
> 16540 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A030843 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth1-2
> =A074: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A025365 =A0=
 =A0 =A0 =A0267 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 89 =A0 =A0 =A015541 =A0 PCI-MSI-edge =A0 =A0 =A0eth=
1-3
> =A075: =A0 =A0 =A0 7244 =A0 =A0 =A024108 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A016488
> 0 =A0 =A0 =A0 =A0240 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0=
eth1-4
> =A076: =A0 =A0 =A021378 =A0 =A0 =A0 3628 =A0 =A0 =A0 7726 =A0 =A0 =A0=
 =A0 =A00 =A0 =A0 =A0 =A0 49
> 247 =A0 =A0 =A0 2871 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0=
eth1-5
> =A077: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A047199 =A0=
 =A0 =A0 =A0459 =A0 =A0 =A0 =A0 13
> 46 =A0 =A0 =A063064 =A0 =A0 =A0 =A0 18 =A0 PCI-MSI-edge =A0 =A0 =A0et=
h1-6
> =A078: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 6230 =A0 =A0 =A0 =A0 67 =A0 =A0=
 =A0 =A0283 =A0 =A0 =A0 =A0259
> 82 =A0 =A0 =A0 7846 =A0 =A0 =A027130 =A0 PCI-MSI-edge =A0 =A0 =A0eth1=
-7
>
> On eth2 (external card) all interrupts goes to CPU0
> =A0 =A0 =A0 =A0 =A0 CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 =A0 CPU2 =A0 =A0 =A0=
 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5
> =A0 =A0 =A0CPU6 =A0 =A0 =A0 CPU7
> =A080: =A0 46973077 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A00
> =A0 0 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0eth2-0
> =A081: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-1
> =A082: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-2
> =A083: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-3
> =A084: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-4
> =A085: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-5
> =A086: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 2445 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 37
> 0 =A0 =A0 =A0 8463 =A0 =A0 =A0 =A0 13 =A0 PCI-MSI-edge =A0 =A0 =A0eth=
2-6
> =A087: =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =
=A0eth2-7
>
> If I understand correctly the RSS hash is used to dispatch the packet=
s
> into the different queues running on the different CPU.
>
> Why then my internal cards are running fine but the additional cards
> (eth2 and eth3) are presenting this behavior where all interrupts goe=
s
> to one CPU?
>
> Thanks for your help in understanding this. (see below for config det=
ails)
>
> Christophe.
>
> All are detected correctly at boot:
> Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v2.0.8e (April 13,=
 2010)
> bnx2 0000:02:00.0: PCI INT A -> GSI 31 (level, low) -> IRQ 31
> bnx2 0000:02:00.0: setting latency timer to 64
> eth0: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
> at mem f4000000, IRQ 31, node addr f4:ce:46:86:a1:00
> bnx2 0000:02:00.1: PCI INT B -> GSI 39 (level, low) -> IRQ 39
> bnx2 0000:02:00.1: setting latency timer to 64
> eth1: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
> at mem f2000000, IRQ 39, node addr f4:ce:46:86:a1:02
> bnx2 0000:07:00.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
> bnx2 0000:07:00.0: setting latency timer to 64
> eth2: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
> at mem fa000000, IRQ 24, node addr 00:26:55:87:17:98
> bnx2 0000:07:00.1: PCI INT B -> GSI 34 (level, low) -> IRQ 34
> bnx2 0000:07:00.1: setting latency timer to 64
> eth3: Broadcom NetXtreme II BCM5709 1000Base-T (C0) PCI Express found
> at mem f8000000, IRQ 34, node addr 00:26:55:87:17:9a
>
> Kernel is 2.6.31-13
> Broadcom driver bnx2 v2.0.8e
>
> eth0 is a normal interface with an Ip address
> eth1 is a normal interface with an Ip address
> eth2 belongs to a bridge interface without an ip address, running tc =
(htb)
> eth3 belongs to the same bridge interface without an ip address
>
