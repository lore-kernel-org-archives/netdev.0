From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: Legacy features in PCI Express devices
Date: Mon, 13 Mar 2017 17:12:41 +0000
Message-ID: <96b57ba5-641d-46c8-6ba0-cee2c0613a6f@arm.com>
References: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Bjorn Helgaas <helgaas@kernel.org>,
        David Laight <david.laight@aculab.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Phuong Nguyen <phuong_nguyen@sigmadesigns.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        netdev <netdev@vger.kernel.org>,
        Tim Harvey <tharvey@gateworks.com>,
        Arnd Bergmann <arnd@arndb.de>
To: Mason <slash.tmp@free.fr>, linux-pci <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/03/17 16:10, Mason wrote:
> Hello,
> 
> There are two revisions of our PCI Express controller.
> 
> Rev 1 did not support the following features:
> 
>   1) legacy PCI interrupt delivery (INTx signals)
>   2) I/O address space
> 
> Internally, someone stated that such missing support would prevent
> some PCIe cards from working with our controller.
> 
> Are there really modern PCIe cards that require 1) and/or 2)
> to function?
> 
> Can someone provide examples of such cards, so that I may test them
> on both revisions?
> 
> I was told to check ath9k-based cards. Any other examples?
> 
> Looking around, I came across this thread:
> http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/418254.html
> "i.MX6 PCIe: Fix imx6_pcie_deassert_core_reset() polarity"
> 
> IIUC, although some PCIe boards do support MSI, the driver might not
> put in the work to use that infrastructure, and instead reverts to
> legacy interrupts. (So it is a SW issue, in a sense.)

Secondary to that category is endpoints which nominally support MSI, but
in a way which is unreliable or otherwise broken. My experience shows
that the Silicon Image SiI 3132 (as integrated on ARM Juno boards, but
seemingly also relatively common on 'generic' 2-port SATA cards) falls
into that category - using the command-line parameter to force MSIs
instead of legacy interrupts leads to the the machine barely reaching
userspace before something goes horribly wrong:

...
         Activating swap Swap Partition...
[   10.817806] Adding 524284k swap on /dev/sda2.  Priority:-1 extents:1
across:524284k SS
         Starting File System Check on /dev/disk/by-uuid/1000-9346...
[  OK  ] Activated swap Swap Partition.
[  OK  ] Activated swap
/dev/disk/by-partuui…6cda4-9f73-4e26-bf19-e71f9319b5ce.
[  OK  ] Reached target Swap.
         Mounting Temporary Directory...
[  OK  ] Mounted Temporary Directory.
[  OK  ] Started File System Check on /dev/disk/by-uuid/1000-9346.
[   46.036065] Unhandled fault: synchronous external abort (0x96000210)
at 0xffff0000092f5000
[   46.044273] Internal error: : 96000210 [#1] PREEMPT SMP
[   46.049445] Modules linked in:
[   46.052474] CPU: 0 PID: 122 Comm: scsi_eh_0 Not tainted 4.11.0-rc1+ #1753
[   46.059192] Hardware name: ARM Juno development board (r1) (DT)
[   46.065052] task: ffff8009763b8000 task.stack: ffff800975f70000
[   46.070918] PC is at ata_wait_register+0x2c/0xa0
[   46.075491] LR is at sil24_init_port+0x60/0x110
[   46.079974] pc : [<ffff0000085b342c>] lr : [<ffff0000085d2b78>]
pstate: 40000145
...

Robin.
