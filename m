From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v11 0/5] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Tue, 15 Aug 2017 07:03:14 -0700
Message-ID: <1502805794.4936.75.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502767407-6812-1-git-send-email-dingtianhong@huawei.com>
         <20170814.221512.1430356980828045690.davem@davemloft.net>
         <1502805534.4936.73.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dingtianhong@huawei.com, leedom@chelsio.com, ashok.raj@intel.com,
        bhelgaas@google.com, helgaas@kernel.org, werner@chelsio.com,
        ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        alexander.duyck@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502805534.4936.73.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-08-15 at 06:58 -0700, Eric Dumazet wrote:
> On Mon, 2017-08-14 at 22:15 -0700, David Miller wrote:
> > From: Ding Tianhong <dingtianhong@huawei.com>
> > Date: Tue, 15 Aug 2017 11:23:22 +0800
> > 
> > > Some devices have problems with Transaction Layer Packets with the Relaxed
> > > Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
> > > PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
> > > devices with Relaxed Ordering issues, and a use of this new flag by the
> > > cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
> > > Ports.
> >  ...
> > 
> > Series applied, thanks.
> 
> I got a NULL deref in pci_find_pcie_root_port()
> 

This was :

[    4.241029] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
[    4.247001] IP: pci_find_pcie_root_port+0x62/0x80
[    4.253011] PGD 0 
[    4.253011] P4D 0 
[    4.253011] 
[    4.258013] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[    4.262015] Modules linked in:
[    4.265005] CPU: 31 PID: 1 Comm: swapper/0 Not tainted 4.13.0-dbx-DEV #316
[    4.271002] Hardware name: Intel RML,PCH/Iota_QC_19, BIOS 2.40.0 06/22/2016
[    4.279002] task: ffffa2ee38cfa040 task.stack: ffffa51ec0004000
[    4.285001] RIP: 0010:pci_find_pcie_root_port+0x62/0x80
[    4.290012] RSP: 0000:ffffa51ec0007ab8 EFLAGS: 00010246
[    4.295003] RAX: 0000000000000000 RBX: ffffa2ee36bae000 RCX: 0000000000000006
[    4.303002] RDX: 000000000000081c RSI: ffffa2ee38cfa8c8 RDI: ffffa2ee36bae000
[    4.310013] RBP: ffffa51ec0007b58 R08: 0000000000000001 R09: 0000000000000000
[    4.317001] R10: 0000000000000000 R11: 0000000000000000 R12: ffffa51ec0007ad0
[    4.324005] R13: ffffa2ee36bae098 R14: 0000000000000002 R15: ffffa2ee37204818
[    4.331002] FS:  0000000000000000(0000) GS:ffffa2ee3fcc0000(0000) knlGS:0000000000000000
[    4.339002] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    4.345001] CR2: 0000000000000050 CR3: 000000401000f000 CR4: 00000000001406e0
[    4.351002] Call Trace:
[    4.354012]  ? pci_configure_device+0x19f/0x570
[    4.359002]  ? pci_conf1_read+0xb8/0xf0
[    4.363002]  ? raw_pci_read+0x23/0x40
[    4.366011]  ? pci_read+0x2c/0x30
[    4.370014]  ? pci_read_config_word+0x67/0x70
[    4.374012]  pci_device_add+0x28/0x230
[    4.378012]  ? pci_vpd_f0_read+0x50/0x80
[    4.382014]  pci_scan_single_device+0x96/0xc0
[    4.386012]  pci_scan_slot+0x79/0xf0
[    4.389001]  pci_scan_child_bus+0x31/0x180
[    4.394014]  acpi_pci_root_create+0x1c6/0x240
[    4.398013]  pci_acpi_scan_root+0x15f/0x1b0
[    4.402012]  acpi_pci_root_add+0x2e6/0x400
[    4.406012]  ? acpi_evaluate_integer+0x37/0x60
[    4.411002]  acpi_bus_attach+0xdf/0x200
[    4.415002]  acpi_bus_attach+0x6a/0x200
[    4.418014]  acpi_bus_attach+0x6a/0x200
[    4.422013]  acpi_bus_scan+0x38/0x70
[    4.426011]  acpi_scan_init+0x10c/0x271
[    4.429001]  acpi_init+0x2fa/0x348
[    4.433004]  ? acpi_sleep_proc_init+0x2d/0x2d
[    4.437001]  do_one_initcall+0x43/0x169
[    4.441001]  kernel_init_freeable+0x1d0/0x258
[    4.445003]  ? rest_init+0xe0/0xe0
[    4.449001]  kernel_init+0xe/0x150
[    4.451002]  ret_from_fork+0x27/0x40
[    4.457004] Code: 85 d2 74 27 80 7a 4a 00 74 21 48 89 d0 48 89 c2 f6 80 1b 09 00 00 10 74 07 48 8b 90 a0 0a 00 00 48 8b 52 10 48 83 7a 10 00 75 d0 <0f> b7 50 50 5d 81 e2 f0 00 00 00 83 fa 40 ba 00 00 00 00 48 0f 
[    4.474012] RIP: pci_find_pcie_root_port+0x62/0x80 RSP: ffffa51ec0007ab8
[    4.481004] CR2: 0000000000000050
[    4.484001] ---[ end trace 6f9be6a057581199 ]---
[    4.488001] Kernel panic - not syncing: Fatal exception
[    4.494013] Rebooting in 10 seconds..
[    4.494013] ACPI MEMORY or I/O RESET_REG.

> 
> This local hack seems to fix the issue.
> 
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index af0cc3456dc1b48b1325c06c5edd2ca8cc22a640..cfd8eb5a3d0ba8347d44952ffab28d9c761044d3 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -522,7 +522,7 @@ struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>                 bridge = pci_upstream_bridge(bridge);
>         }
>  
> -       if (pci_pcie_type(highest_pcie_bridge) != PCI_EXP_TYPE_ROOT_PORT)
> +       if (highest_pcie_bridge && pci_pcie_type(highest_pcie_bridge) != PCI_EXP_TYPE_ROOT_PORT)
>                 return NULL;
>  
>         return highest_pcie_bridge;
