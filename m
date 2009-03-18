From: Ingo Molnar <mingo@elte.hu>
Subject: e1000e 0000:00:19.0: DMA-API: device driver tries to free DMA
	memory it has not allocated [device address=0x0000000052ff084a]
	[size=90 bytes]
Date: Wed, 18 Mar 2009 13:04:58 +0100
Message-ID: <20090318120458.GA1601@elte.hu>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com> <20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu> <20090318115615.GS6159@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@redhat.com>, iommu@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:47206 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbZCRMFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2009 08:05:33 -0400
Content-Disposition: inline
In-Reply-To: <20090318115615.GS6159@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


( e1000e Cc:s added. A new debug feature, CONFIG_DMA_API_DEBUG=3Dy,=20
  has triggered the warning below in e1000_put_txbuf(). )

* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Wed, Mar 18, 2009 at 10:38:47AM +0100, Ingo Molnar wrote:
> > e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> > e1000e 0000:00:19.0: irq 30 for MSI/MSI-X
> > ADDRCONF(NETDEV_UP): eth0: link is not ready
> > e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX/=
TX
> > 0000:00:19.0: eth0: 10/100 speed: disabling TSO
> > ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> > ------------[ cut here ]------------
> > WARNING: at lib/dma-debug.c:461 check_unmap+0xd4/0x3dd() (Not taint=
ed)
> > Hardware name: 2241B48
> > e1000e 0000:00:19.0: DMA-API: device driver tries to free DMA memor=
y=20
> > it has not allocated [device address=3D0x0000000052ff084a] [size=3D=
90 bytes]
> >  [<ffffffff811a6fb0>] check_unmap+0xd4/0x3dd
> >  [<ffffffff811a7406>] debug_dma_unmap_page+0x50/0x52
> >  [<ffffffffa00f4523>] pci_unmap_page+0x4e/0x57 [e1000e]
> >  [<ffffffffa00f455a>] e1000_put_txbuf+0x2e/0x4f [e1000e]
> >  [<ffffffffa00f4681>] e1000_clean_tx_irq+0xc8/0x2c2 [e1000e]
> >  [<ffffffffa00f809b>] ? e1000_clean+0x6b/0x246 [e1000e]
> >  [<ffffffffa00f80a7>] e1000_clean+0x77/0x246 [e1000e]
> >  [<ffffffff812f89dd>] net_rx_action+0xb6/0x1ee
> >  [<ffffffff812f8acc>] ? net_rx_action+0x1a5/0x1ee
> >  [<ffffffff81051353>] __do_softirq+0x94/0x179
> >  [<ffffffff810127ac>] call_softirq+0x1c/0x30
> >  [<ffffffff8101393e>] do_softirq+0x52/0xb9
> >  [<ffffffff81050f76>] irq_exit+0x53/0x90
> >  [<ffffffff81013c57>] do_IRQ+0x12c/0x151
> >  [<ffffffff81011e93>] ret_from_intr+0x0/0x2e
> >  <EOI>  [<ffffffff811fe088>] ? acpi_idle_enter_bm+0x287/0x2de
> >  [<ffffffff8106fbf9>] ? trace_hardirqs_on+0xd/0xf
> >  [<ffffffff811fe090>] ? acpi_idle_enter_bm+0x28f/0x2de
> >  [<ffffffff811fe088>] ? acpi_idle_enter_bm+0x287/0x2de
> >  [<ffffffff81399916>] ? __atomic_notifier_call_chain+0x0/0x86
> >  [<ffffffff812d62ad>] ? cpuidle_idle_call+0x8d/0xc4
> >  [<ffffffff810102c7>] ? cpu_idle+0x68/0xb3
> >  [<ffffffff81381817>] ? rest_init+0x6b/0x6d
> > ---[ end trace b8ae2341b2e9bbc2 ]---
> >=20
> > i have some vague memories of this being discussed somewhere - it=20
> > got fixed in the driver, right? If yes, do you have an URL to that=20
> > fix? (if it's not upstream yet i will pick it up into=20
> > tip:out-of-tree to not have already-fixed warnings)
>=20
> We had this issue in the ixgbe driver and it was fixed there. As far =
as
> I know for e1000e this is a new issue.
>=20
> Joerg
>=20
> --=20
>            | Advanced Micro Devices GmbH
>  Operating | Karl-Hammerschmidt-Str. 34, 85609 Dornach bei M=FCnchen
>  System    |=20
>  Research  | Gesch=E4ftsf=FChrer: Jochen Polster, Thomas M. McCoy, Gi=
uliano Meroni
>  Center    | Sitz: Dornach, Gemeinde Aschheim, Landkreis M=FCnchen
>            | Registergericht M=FCnchen, HRB Nr. 43632
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
