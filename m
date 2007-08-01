From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Wed, 01 Aug 2007 00:53:31 -0700
Message-ID: <1185954811.5552.7.camel@dell>
References: <20070731174522.b141178a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Joachim Deguara" <joachim.deguara@amd.com>,
	"lkml List" <linux-kernel@vger.kernel.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20070731174522.b141178a.akpm@linux-foundation.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-07-31 at 17:45 -0700, Andrew Morton wrote:
> On Tue, 31 Jul 2007 11:28:32 +0200 "Joachim Deguara"
> <joachim.deguara@amd.com> wrote:
> 
> > On my Acer Ferrari 1000 the tg3 ethernet no longer is available
> after a
> > suspend to ram with the latet 2.6.23-rc1-git9.

It seems to work for me on the same 2.6.23-rc1-git9 kernel with the same
tg3 hardware.  Can you narrow down the problem some more?  It seems that
in your case, the chip registers are returning 0xffffffff after resume.
Can you do lspci -xxxvvv on the tg3 adapter after resume?

Here's my log:

tg3.c:v3.79 (July 18, 2007)
ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 16
eth0: Tigon3 [partno(BCM95755m) rev a002 PHY(5755)] (PCI Express) 10/100/1000Ba1eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
eth0: dma_rwctrl[76180000] dma_mask[64-bit]
ACPI: PCI Interrupt 0000:40:00.0[A] -> GSI 17 (level, low) -> IRQ 17
eth1: Tigon3 [partno(BCM95751) rev 4001 PHY(5750)] (PCI Express) 10/100/1000Bas5eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[1] TSOcap[1]
eth1: dma_rwctrl[76180000] dma_mask[64-bit]
ACPI: PCI Interrupt 0000:05:09.0[A] -> GSI 18 (level, low) -> IRQ 19
eth2: Tigon3 [partno(BCM95788A50) rev 3003 PHY(5705)] (PCI:33MHz:32-bit) 10/1008eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
eth2: dma_rwctrl[763f0000] dma_mask[32-bit]
ADDRCONF(NETDEV_UP): eth0: link is not ready
ADDRCONF(NETDEV_UP): eth1: link is not ready
ADDRCONF(NETDEV_UP): eth2: link is not ready
tg3: eth2: Link is up at 1000 Mbps, full duplex.
tg3: eth2: Flow control is on for TX and on for RX.
ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
Stopping tasks ... done.
Suspending console(s)
ACPI handle has no context!
pnp: Device 00:08 disabled.
ACPI handle has no context!
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
ACPI: PCI Interrupt 0000:00:1f.2[B] -> GSI 19 (level, low) -> IRQ 18
tg3: eth2: Link is down.
pnp: Device 00:08 activated.
Restarting tasks ... hda: status error: status=0x51 { DriveReady SeekComplete E}hda: status error: error=0x04 { DriveStatusError }
ide: failed opcode was: unknown
hda: no DRQ after issuing MULTWRITE_EXT
hda: status error: status=0x51 { DriveReady SeekComplete Error }
hda: status error: error=0x04 { DriveStatusError }
ide: failed opcode was: unknown
hda: no DRQ after issuing MULTWRITE_EXT
hda: status error: status=0x51 { DriveReady SeekComplete Error }
hda: status error: error=0x04 { DriveStatusError }
ide: failed opcode was: unknown
hda: no DRQ after issuing MULTWRITE_EXT
hda: status error: status=0x51 { DriveReady SeekComplete Error }
hda: status error: error=0x04 { DriveStatusError }
ide: failed opcode was: unknown
hda: no DRQ after issuing MULTWRITE_EXT
done.
ide0: reset: success
tg3: eth2: Link is up at 1000 Mbps, full duplex.
tg3: eth2: Flow control is on for TX and on for RX.



