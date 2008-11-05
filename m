From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] linux-2.6.28-rc3 regression: IRQ smp_affinities not respected
Date: Wed, 05 Nov 2008 09:09:44 +0100
Message-ID: <491154C8.3040401@cosmosbay.com>
References: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: ut <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38823 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbYKEIJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 03:09:57 -0500
In-Reply-To: <C27F8246C663564A84BB7AB343977242151F4B18B5@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan a =E9crit :
> Eric Dumazet wrote:
>=20
>> Hi all
>>
>> One more problem it seems on 2.6.28-rc3
>>
>> I wanted to get maximal throughput from my machine on a
>> network bench with 3 Gigabit
>> links delivering 600.000 packets per second, so I tried to
>> play with smp_affinity to
>> dedicate one CPU for each NIC.
>>
>> It worked with 2.6.27, so there is a regression on this part.
>=20
> I believe this may be the patch that broke it:
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dce6fce4295ba727b36fdc73040e444bd1aae64cd
>=20
> I don't remember all the details, but the Broadcom 5708 chip is
> affected because it does not support MSI per-vector masking.
>=20
> One way to get around is to disable MSI with bnx2 parameter
> disable_msi=3D1.
>=20

Thanks Michael for your fast answer


I tried this MSI disabling and yes, it now works.

 16:      42726        128        105        106         89         89 =
       145        152   IO-APIC-fasteoi   uhci_hcd:usb1, eth0, eth1

But I now have same interrupt used on two NIC, so I cannot split the lo=
ad on two CPUS, unless
using a smp_affinity with 2 CPUS on it. Not exactly what I wanted to do=
=2E.

Do you know if BCM5715S (tg3 driver) have same problem ?

03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S=
 Gigabit Ethernet (rev 12)
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunct=
ion Gigabit Server Adapter
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 16
        Memory at f6000000 (64-bit, non-prefetchable) [size=3D32M]
        [virtual] Expansion ROM at d1300000 [disabled] [size=3D16K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/0 Enable-

07:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S=
 Gigabit Ethernet (rev 12)
        Subsystem: Hewlett-Packard Company NC373i Integrated Multifunct=
ion Gigabit Server Adapter
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 16
        Memory at fa000000 (64-bit, non-prefetchable) [size=3D32M]
        [virtual] Expansion ROM at d1000000 [disabled] [size=3D16K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/0 Enable-

14:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)
        Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapte=
r
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 46
        Memory at fdff0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fdfe0000 (64-bit, non-prefetchable) [size=3D64K]
        [virtual] Expansion ROM at d1200000 [disabled] [size=3D128K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/3 Enable+

14:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5715S Gi=
gabit Ethernet (rev a3)
        Subsystem: Hewlett-Packard Company NC326m PCIe Dual Port Adapte=
r
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 16
        Memory at fdfd0000 (64-bit, non-prefetchable) [size=3D64K]
        Memory at fdfc0000 (64-bit, non-prefetchable) [size=3D64K]
        [virtual] Expansion ROM at d1220000 [disabled] [size=3D128K]
        Capabilities: [40] PCI-X non-bridge device.
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/3 Enable-

