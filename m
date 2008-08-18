From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: forcedeth 10de:0373 doesn't work on resume
Date: Mon, 18 Aug 2008 13:48:14 -0700
Message-ID: <20080818134814.136105c9.akpm@linux-foundation.org>
References: <4898AA28.8000507@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org, ranma+kernel@tdiedrich.de,
	jgarzik@redhat.com
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60499 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753503AbYHRUtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 16:49:19 -0400
In-Reply-To: <4898AA28.8000507@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Aug 2008 20:29:44 +0100
Simon Arlott <simon@fire.lp0.eu> wrote:
>

[two weeks pass...]

> My NIC stops working after resuming from standby, it's not receiving any interrupts:
> [    0.618266] pci 0000:00:08.0: supports D1
> [    0.618267] pci 0000:00:08.0: supports D2
> [    0.618269] pci 0000:00:08.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.618382] pci 0000:00:08.0: PME# disabled
> [    0.618513] pci 0000:00:09.0: supports D1
> [    0.618523] pci 0000:00:09.0: supports D2
> [    0.618532] pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.618632] pci 0000:00:09.0: PME# disabled
> [    0.629767] PM: Adding info for pci:0000:00:08.0
> [    0.630304] PM: Adding info for pci:0000:00:09.0
> [    0.866667] pci 0000:00:08.0: Enabling HT MSI Mapping
> [    0.866804] pci 0000:00:09.0: Enabling HT MSI Mapping
> [    1.847264] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.61.
> [    1.847918] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI 21 (level, low) -> IRQ 21
> [    1.848121] forcedeth 0000:00:08.0: setting latency timer to 64
> [    1.849363] forcedeth 0000:00:08.0: ifname eth2, PHY OUI 0x5043 @ 16, addr 00:e0:81:4d:2b:ec
> [    1.849553] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
> [    1.850212] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 20 (level, low) -> IRQ 20
> [    1.850405] forcedeth 0000:00:09.0: setting latency timer to 64
> [    1.851684] forcedeth 0000:00:09.0: ifname eth3, PHY OUI 0x5043 @ 17, addr 00:e0:81:4d:2b:ed
> [    1.851873] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
> [  913.928604] forcedeth 0000:00:08.0: preparing suspend, may wakeup
> [  913.928607] forcedeth 0000:00:09.0: preparing suspend, may wakeup
> [  916.388326] forcedeth 0000:00:09.0: suspend, may wakeup
> [  916.388704] forcedeth 0000:00:09.0: PME# enabled
> [  916.388711] forcedeth 0000:00:09.0: wake-up capability enabled by ACPI
> [  916.388714] forcedeth 0000:00:09.0: PCI INT A disabled
> [  916.398995] forcedeth 0000:00:08.0: suspend, may wakeup
> [  916.399741] forcedeth 0000:00:08.0: PME# enabled
> [  916.399767] forcedeth 0000:00:08.0: wake-up capability enabled by ACPI
> [  916.399786] forcedeth 0000:00:08.0: PCI INT A disabled
> [  917.255261] forcedeth 0000:00:09.0: LATE suspend, may wakeup
> [  917.255263] forcedeth 0000:00:08.0: LATE suspend, may wakeup
> [  917.256004] forcedeth 0000:00:08.0: EARLY resume
> [  917.256004] forcedeth 0000:00:09.0: EARLY resume
> [  918.015874] forcedeth 0000:00:08.0: resume
> [  918.026369] forcedeth 0000:00:08.0: restoring config space at offset 0xf (was 0x14010100, writing 0x1401010a)
> [  918.026395] forcedeth 0000:00:08.0: restoring config space at offset 0x7 (was 0x0, writing 0xfdffa400)
> [  918.026417] forcedeth 0000:00:08.0: restoring config space at offset 0x6 (was 0x0, writing 0xfdffa800)
> [  918.026428] forcedeth 0000:00:08.0: restoring config space at offset 0x5 (was 0x1, writing 0x9401)
> [  918.026436] forcedeth 0000:00:08.0: restoring config space at offset 0x4 (was 0x0, writing 0xfdff6000)
> [  918.026443] forcedeth 0000:00:08.0: restoring config space at offset 0x1 (was 0xb00000, writing 0xb00007)
> [  918.026465] forcedeth 0000:00:08.0: wake-up capability disabled by ACPI
> [  918.026471] forcedeth 0000:00:08.0: PME# disabled
> [  918.027446] forcedeth 0000:00:09.0: resume
> [  918.037096] forcedeth 0000:00:09.0: restoring config space at offset 0xf (was 0x14010100, writing 0x1401010b)
> [  918.037115] forcedeth 0000:00:09.0: restoring config space at offset 0x7 (was 0x0, writing 0xfdff4c00)
> [  918.037120] forcedeth 0000:00:09.0: restoring config space at offset 0x6 (was 0x0, writing 0xfdffa000)
> [  918.037125] forcedeth 0000:00:09.0: restoring config space at offset 0x5 (was 0x1, writing 0x9081)
> [  918.037131] forcedeth 0000:00:09.0: restoring config space at offset 0x4 (was 0x0, writing 0xfdff5000)
> [  918.037137] forcedeth 0000:00:09.0: restoring config space at offset 0x1 (was 0xb00000, writing 0xb00007)
> [  918.037160] forcedeth 0000:00:09.0: wake-up capability disabled by ACPI
> [  918.037174] forcedeth 0000:00:09.0: PME# disabled
> [  925.810837] forcedeth 0000:00:09.0: completing resume
> [  925.810841] forcedeth 0000:00:08.0: completing resume
> 
> Commit 25d90810ff49d2a63475776f24c74c6bb49b045f ([netdrvr] forcedeth: reorder suspend/resume code) 
> introduces pci_disable_device to nv_suspend, but there's no corresponding pci_enable_device in 
> nv_resume - so I added one (copied from e1000):
> 
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 01b38b0..db4f875 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -5922,6 +5922,13 @@ static int nv_resume(struct pci_dev *pdev)
>  
>  	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
> +	rc = pci_enable_device(pdev);
> +	if (rc) {
> +		printk(KERN_ERR "forcedeth: Cannot enable PCI device from suspend\n");
> +		return rc;
> +	}
> +	pci_set_master(pdev);
> +
>  	/* ack any pending wake events, disable PME */
>  	pci_enable_wake(pdev, PCI_D0, 0);
>  

That seems like a sensible change.

> This results in interrupts being re-enabled after suspend:
> [    0.619558] pci 0000:00:08.0: supports D1
> [    0.619560] pci 0000:00:08.0: supports D2
> [    0.619561] pci 0000:00:08.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.619684] pci 0000:00:08.0: PME# disabled
> [    0.619826] pci 0000:00:09.0: supports D1
> [    0.619828] pci 0000:00:09.0: supports D2
> [    0.619837] pci 0000:00:09.0: PME# supported from D0 D1 D2 D3hot D3cold
> [    0.619952] pci 0000:00:09.0: PME# disabled
> [    0.631145] PM: Adding info for pci:0000:00:08.0
> [    0.631699] PM: Adding info for pci:0000:00:09.0
> [    0.870662] pci 0000:00:08.0: Enabling HT MSI Mapping
> [    0.870809] pci 0000:00:09.0: Enabling HT MSI Mapping
> [    1.853343] forcedeth: Reverse Engineered nForce ethernet driver. Version 0.61.
> [    1.854016] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI 21 (level, low) -> IRQ 21
> [    1.854217] forcedeth 0000:00:08.0: setting latency timer to 64
> [    1.855468] forcedeth 0000:00:08.0: ifname eth2, PHY OUI 0x5043 @ 16, addr 00:e0:81:4d:2b:ec
> [    1.855658] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
> [    1.856332] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 20 (level, low) -> IRQ 20
> [    1.856528] forcedeth 0000:00:09.0: setting latency timer to 64
> [    1.857815] forcedeth 0000:00:09.0: ifname eth3, PHY OUI 0x5043 @ 17, addr 00:e0:81:4d:2b:ed
> [    1.858015] forcedeth 0000:00:09.0: highdma csum vlan pwrctl mgmt timirq gbit lnktim msi desc-v3
> [   42.310803] forcedeth 0000:00:08.0: preparing suspend, may wakeup
> [   42.310807] forcedeth 0000:00:09.0: preparing suspend, may wakeup
> [   44.468801] forcedeth 0000:00:09.0: suspend, may wakeup
> [   44.469181] forcedeth 0000:00:09.0: PME# enabled
> [   44.469191] forcedeth 0000:00:09.0: wake-up capability enabled by ACPI
> [   44.469196] forcedeth 0000:00:09.0: PCI INT A disabled
> [   44.479247] forcedeth 0000:00:08.0: suspend, may wakeup
> [   44.479981] forcedeth 0000:00:08.0: PME# enabled
> [   44.480014] forcedeth 0000:00:08.0: wake-up capability enabled by ACPI
> [   44.480025] forcedeth 0000:00:08.0: PCI INT A disabled
> [   45.311781] forcedeth 0000:00:09.0: LATE suspend, may wakeup
> [   45.311784] forcedeth 0000:00:08.0: LATE suspend, may wakeup
> [   45.312005] forcedeth 0000:00:08.0: EARLY resume
> [   45.312005] forcedeth 0000:00:09.0: EARLY resume
> [   46.067593] forcedeth 0000:00:08.0: resume
> [   46.077904] forcedeth 0000:00:08.0: restoring config space at offset 0xf (was 0x14010100, writing 0x1401010a)
> [   46.077931] forcedeth 0000:00:08.0: restoring config space at offset 0x7 (was 0x0, writing 0xfdffa400)
> [   46.077949] forcedeth 0000:00:08.0: restoring config space at offset 0x6 (was 0x0, writing 0xfdffa800)
> [   46.077962] forcedeth 0000:00:08.0: restoring config space at offset 0x5 (was 0x1, writing 0x9401)
> [   46.077973] forcedeth 0000:00:08.0: restoring config space at offset 0x4 (was 0x0, writing 0xfdff6000)
> [   46.077987] forcedeth 0000:00:08.0: restoring config space at offset 0x1 (was 0xb00000, writing 0xb00007)
> [   46.078026] forcedeth 0000:00:08.0: PCI INT A -> Link[LMAC] -> GSI 21 (level, low) -> IRQ 21
> [   46.078031] forcedeth 0000:00:08.0: setting latency timer to 64
> [   46.078042] forcedeth 0000:00:08.0: wake-up capability disabled by ACPI
> [   46.078056] forcedeth 0000:00:08.0: PME# disabled
> [   46.079323] forcedeth 0000:00:09.0: resume
> [   46.089903] forcedeth 0000:00:09.0: restoring config space at offset 0xf (was 0x14010100, writing 0x1401010b)
> [   46.089930] forcedeth 0000:00:09.0: restoring config space at offset 0x7 (was 0x0, writing 0xfdff4c00)
> [   46.089952] forcedeth 0000:00:09.0: restoring config space at offset 0x6 (was 0x0, writing 0xfdffa000)
> [   46.089959] forcedeth 0000:00:09.0: restoring config space at offset 0x5 (was 0x1, writing 0x9081)
> [   46.089964] forcedeth 0000:00:09.0: restoring config space at offset 0x4 (was 0x0, writing 0xfdff5000)
> [   46.089970] forcedeth 0000:00:09.0: restoring config space at offset 0x1 (was 0xb00000, writing 0xb00007)
> [   46.089998] forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 20 (level, low) -> IRQ 20
> [   46.090003] forcedeth 0000:00:09.0: setting latency timer to 64
> [   46.090007] forcedeth 0000:00:09.0: wake-up capability disabled by ACPI
> [   46.090013] forcedeth 0000:00:09.0: PME# disabled
> [   52.903755] forcedeth 0000:00:09.0: completing resume
> [   52.903759] forcedeth 0000:00:08.0: completing resume
> 
> However, the NIC still doesn't work after resume.

Is it still broken in current kernels?

> 00:08.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
> 	Subsystem: nVidia Corporation Device cb84
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 219
> 	Memory at fdff6000 (32-bit, non-prefetchable) [size=4K]
> 	I/O ports at 9400 [size=8]
> 	Memory at fdffa800 (32-bit, non-prefetchable) [size=256]
> 	Memory at fdffa400 (32-bit, non-prefetchable) [size=16]
> 	Capabilities: [44] Power Management version 2
> 	Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
> 	Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Queue=0/3 Enable+
> 	Capabilities: [6c] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Kernel driver in use: forcedeth
> 
> 00:09.0 Bridge: nVidia Corporation MCP55 Ethernet (rev a3)
> 	Subsystem: nVidia Corporation Device cb84
> 	Flags: bus master, 66MHz, fast devsel, latency 0, IRQ 20
> 	Memory at fdff5000 (32-bit, non-prefetchable) [size=4K]
> 	I/O ports at 9080 [size=8]
> 	Memory at fdffa000 (32-bit, non-prefetchable) [size=256]
> 	Memory at fdff4c00 (32-bit, non-prefetchable) [size=16]
> 	Capabilities: [44] Power Management version 2
> 	Capabilities: [70] MSI-X: Enable- Mask- TabSize=8
> 	Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ Queue=0/3 Enable-
> 	Capabilities: [6c] HyperTransport: MSI Mapping Enable+ Fixed+
> 	Kernel driver in use: forcedeth

Thanks.
