From: David Miller <davem@davemloft.net>
Subject: APE changes cause tg3 regressions...
Date: Thu, 11 Oct 2007 17:58:09 -0700 (PDT)
Message-ID: <20071011.175809.74749424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, mcarlson@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47900
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751358AbXJLA6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:58:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On my onboard SunBlade1500 5703 chips, which lack firmware, the APE
changes introduce bus timeouts while bringing the chip up,
specifically I get crashes in tg3_write_sig_post_reset() such as:

[   36.066603] eth1: Tigon3 [partno(BCM95703A30U) rev 1002 PHY(5703)] (PCI:33MHz:64-bit) 10/100/1000Base-T Ethernet 00:10:18:04:13:02
[   36.076040] eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
[   36.085393] eth1: dma_rwctrl[763f0000] dma_mask[32-bit]
[   36.095909] PCI: Enabling device: (0000:00:08.0), cmd 3
[   37.541359] tg3: eth1: No firmware running.
[   37.588662] ERROR(0): Cheetah error trap taken afsr[0000400000000000] afar[0000000000004210] TL1(0)
[   37.598106] ERROR(0): TPC[1004a700] TNPC[1004a704] O7[42f488] TSTATE[80009602]
[   37.607555] ERROR(0): TPC<tg3_write_sig_post_reset+0x68/0x78 [tg3]>
[   37.617040] ERROR(0): M_SYND(0),  E_SYND(0)
[   37.626422] ERROR(0): Highest priority error (0000400000000000) "Error due to unsupported store"
[   37.636046] ERROR(0): AFAR E-syndrome [???]
[   37.645619] ERROR(0): D-cache idx[0] tag[0000000000000000] utag[0000000000000000] stag[0000000000000000]
[   37.655394] ERROR(0): D-cache data0[0000000000000000] data1[0000000000000000] data2[0000000000000000] data3[0000000000000000]
[   37.665254] ERROR(0): I-cache idx[0] tag[0000000000000000] utag[0000000000000000] stag[0000000000000000] u[0000000000000000] l[0000000000000000]
[   37.675194] ERROR(0): I-cache INSN0[0000000000000000] INSN1[0000000000000000] INSN2[0000000000000000] INSN3[0000000000000000]
[   37.685138] ERROR(0): I-cache INSN4[0000000000000000] INSN5[0000000000000000] INSN6[0000000000000000] INSN7[0000000000000000]
[   37.695069] ERROR(0): E-cache idx[4200] tag[0000000002000fb1]
[   37.704920] ERROR(0): E-cache data0[b0102000a6922000] data1[02800057a004c010] data2[9410001192100019] data3[a2042250b0100013]
[   37.714978] /pci@1f,700000: Safari/JBUS interrupt, UNMAPPED error, interrogating IOMMUs.

My initial suspicion is that TG3_FLG3_ENABLE_APE isn't being set right
on these firmware-less cards, or some APE programming is not being
guarded properly with tests on that feature bit.

Please fix this, thanks!
