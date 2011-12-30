From: Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next V2 00/21] net/mlx4: SRIOV support
Date: Fri, 30 Dec 2011 14:23:02 -0800
Message-ID: <CAE9FiQW2ZB3VUrg9z-=UVp=s3w1LQhY81hRUjfMXwW3d1dNaig@mail.gmail.com>
References: <4EE75CD1.7070900@mellanox.co.il>
	<20111213.141413.1872427395829102426.davem@davemloft.net>
	<953B660C027164448AE903364AC447D2485F0A86@MTLDAG02.mtl.com>
	<CAE9FiQU1EwcGBhn2bFksB30nb8p3FEo=vvOJYXq3hAA1ArhqWg@mail.gmail.com>
	<CAJZOPZJ+BxAa_OcB0f5nPAjnW7eZfsDdXz_o-VSCW7dsp5p2wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org" <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
To: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZJ+BxAa_OcB0f5nPAjnW7eZfsDdXz_o-VSCW7dsp5p2wg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 14, 2011 at 1:50 PM, Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Dec 14, 2011 at 10:42 PM, Yinghai Lu <yinghai-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
>> got following warning:
>
> could you send your .config as attached to Yevgeny Petrilin
> <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, he will distribute it to the group

hotplug removal is broken...

sca21d-0a86d3dd:~ # echo 0 > /sys/bus/pci/slots/1/power
[  123.085198] pciehp 0000:00:02.2:pcie04: disable_slot: physical_slot = 1
[  123.091863] pciehp 0000:00:02.2:pcie04: pciehp_get_power_status:
SLOTCTRL a8 value read 1f9
[  123.100210] pciehp 0000:00:02.2:pcie04: pciehp_unconfigure_device:
domain:bus:dev = 0000:30:00
[  123.114078] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000010
[  123.121923] IP: [<ffffffff8177fc92>] mlx4_table_put+0x57/0xaf
[  123.127684] PGD 0
[  123.129712] Oops: 0000 [#1] SMP
[  123.132969] CPU 0
[  123.134806] Modules linked in:
[  123.138063]
[  123.139552] Pid: 7617, comm: bash Not tainted
3.2.0-rc7-tip-yh-03751-ga431a72-dirty #35 Oracle Corporation Sun Blade
/BD,ASSY,
[  123.151662] RIP: 0010:[<ffffffff8177fc92>]  [<ffffffff8177fc92>]
mlx4_table_put+0x57/0xaf
[  123.159850] RSP: 0018:ffff8802707018d8  EFLAGS: 00010296
[  123.165151] RAX: ffff880175a69900 RBX: ffff8801756f4f50 RCX: ffff880276c407e8
[  123.172272] RDX: 0000000000000000 RSI: ffff880276c407e8 RDI: ffff880270701898
[  123.179391] RBP: ffff880270701908 R08: ffff880270701878 R09: 3d605d874c4567fa
[  123.186512] R10: 3d605d874c4567e5 R11: dead000000200200 R12: 0000000000000000
[  123.193633] R13: ffff8801756f4f70 R14: ffff8801756f0000 R15: 0000000000000000
[  123.200754] FS:  00007f44d66686f0(0000) GS:ffff880179e00000(0000)
knlGS:0000000000000000
[  123.208827] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  123.214564] CR2: 0000000000000010 CR3: 000000016bf94000 CR4: 00000000000407f0
[  123.221684] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  123.228805] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  123.235926] Process bash (pid: 7617, threadinfo ffff880270700000,
task ffff880276c40000)
[  123.243997] Stack:
[  123.246009]  0000000000001dbf ffff8801756f4f50 ffff8801756f0000
0000000000001d80
[  123.253458]  0000000000040000 0000000000001dbf ffff880270701948
ffffffff8177fec7
[  123.260908]  0000000000000040 0000000000001d80 0000000000000006
ffff8801756f0000
[  123.268357] Call Trace:
[  123.270808]  [<ffffffff8177fec7>] mlx4_table_put_range+0x35/0x50
[  123.276806]  [<ffffffff817857f7>] __mlx4_free_mtt_range+0x5c/0x65
[  123.282893]  [<ffffffff81785887>] mlx4_free_mtt_range+0x87/0x92
[  123.288802]  [<ffffffff81779d4e>] ? __mlx4_cmd+0x4a/0x6b
[  123.294105]  [<ffffffff817854e9>] ? mlx4_HW2SW_MPT.constprop.22+0x43/0x45
[  123.300878]  [<ffffffff817858a9>] mlx4_mtt_cleanup+0x17/0x19
[  123.306527]  [<ffffffff8178590c>] mlx4_mr_free_reserved+0x61/0x66
[  123.312607]  [<ffffffff81785d6a>] mlx4_mr_free+0x17/0x3e
[  123.317910]  [<ffffffff81785db0>] mlx4_fmr_free+0x1f/0x2c
[  123.323307]  [<ffffffff81a32e3e>] mlx4_ib_fmr_dealloc+0x24/0x3e
[  123.329215]  [<ffffffff81134437>] ? kfree+0x125/0x131
[  123.334257]  [<ffffffff81981fb7>] ib_dealloc_fmr+0x18/0x25
[  123.339732]  [<ffffffff81984e56>] ib_destroy_fmr_pool+0x8c/0xf7
[  123.345640]  [<ffffffff81a5ebc7>] srp_remove_one+0x19d/0x1c6
[  123.351287]  [<ffffffff81984429>] ib_unregister_device+0x3d/0xe3
[  123.357284]  [<ffffffff81a30058>] mlx4_ib_remove+0x26/0xed
[  123.362756]  [<ffffffff81780246>] mlx4_remove_device+0x57/0x72
[  123.368577]  [<ffffffff8178052a>] mlx4_unregister_device+0x3c/0x72
[  123.374744]  [<ffffffff81782477>] mlx4_remove_one+0xb9/0x23f
[  123.380395]  [<ffffffff81359137>] pci_device_remove+0x3c/0xbc
[  123.386129]  [<ffffffff81416ee7>] __device_release_driver+0x86/0xd2
[  123.392383]  [<ffffffff81416f58>] device_release_driver+0x25/0x32
[  123.398464]  [<ffffffff81416aee>] bus_remove_device+0x93/0xa3
[  123.404199]  [<ffffffff81414d35>] device_del+0x12d/0x17f
[  123.409499]  [<ffffffff81414d9a>] device_unregister+0x13/0x1f
[  123.415235]  [<ffffffff81354826>] pci_stop_bus_device+0x8a/0xad
[  123.421142]  [<ffffffff81354984>] pci_remove_bus_device+0x13/0x1f
[  123.427226]  [<ffffffff81366ac6>] pciehp_unconfigure_device+0x107/0x16d
[  123.433825]  [<ffffffff81366539>] pciehp_disable_slot+0x11e/0x186
[  123.439906]  [<ffffffff813667ec>] pciehp_sysfs_disable_slot+0x68/0x108
[  123.446420]  [<ffffffff81365929>] disable_slot+0x58/0x5c
[  123.451722]  [<ffffffff8136273e>] power_write_file+0xd1/0x11b
[  123.457457]  [<ffffffff8136266d>] ? get_attention_status+0xad/0xad
[  123.463625]  [<ffffffff8135c9b9>] pci_slot_attr_store+0x29/0x2b
[  123.469533]  [<ffffffff811960f8>] sysfs_write_file+0x10e/0x14a
[  123.475354]  [<ffffffff8113b2cd>] vfs_write+0xb5/0x128
[  123.480483]  [<ffffffff8113b529>] sys_write+0x4d/0x77
[  123.485526]  [<ffffffff81c653d2>] system_call_fastpath+0x16/0x1b
[  123.491517] Code: 89 ef 41 21 c7 89 c8 99 f7 7e 10 31 f6 89 c1 44
89 f8 99 f7 f9 41 89 c7 e8 e8 c0 4d 00 48 8b 83 c8 00 00 00 4d 63 e7
4a 8b 14 e0 <8b> 42 10 ff c8 85 c0 89 42 10 75 37 41 c1 e7 12 4c 89 f7
49 63
[  123.511545] RIP  [<ffffffff8177fc92>] mlx4_table_put+0x57/0xaf
[  123.517383]  RSP <ffff8802707018d8>
[  123.520866] CR2: 0000000000000010
[  123.524228] ---[ end trace 6436e31aa4627ed0 ]---
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
