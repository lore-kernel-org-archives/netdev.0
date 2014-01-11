From: Daniel J Blueman <daniel-JCXMqzvhRcvYtjvyW6yDsg@public.gmane.org>
Subject: 3.13-rc7 USB networking oops
Date: Sat, 11 Jan 2014 15:58:07 +0800
Message-ID: <CAMVG2suJAbK0_CWpjkT4Nko3SF+W6sx=AcMu_NzbCZOR7DT2WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I hit this on 3.13-rc7 while transferring data over an ASIX88179 USB 3
to gigabit ethernet adapter, transferring data at only 4MB/s.

What other debug options apart from SG debug would be useful here?

Thanks,
  Daniel

On 30 December 2013 23:26, Daniel J Blueman <daniel-JCXMqzvhRcvYtjvyW6yDsg@public.gmane.org> wrote:
> When rsyncing data from a USB3 disk over a USB3-ethernet adapter to
> local server on 3.13-rc5 [1], I ran into fatal page-not-readable fault
> [2].
>
> Full dmesg (before the disk was plugged in) is at
> http://quora.org/2013/dmesg.txt
>
> I can test patches on the weekend if needed.
>
> Thanks and Happy New Year!
>   Daniel
>
> --- [1]
>
> http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.13-rc5-trusty/linux-image-3.13.0-031300rc5-generic_3.13.0-031300rc5.201312221635_amd64.deb
>
> --- [2] (apologies for any typos due to OCR)
>
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff813979f2>] sg_next+0x2/0x20
> PGD 2354c5067 PUD 1b25b1067 PMD 0
> Oops: 0000 [#1] SMP
> Modules linked in: usb_storage dm_crypt autofs4 snd_hda_codec_hdmi
> parport_pc ppdev tusb bluetooth snd_page_alloc ax88179_178e usbnet
> snd_seq_midi crctlOdif_pcImul vldepdev snd_sedird _ich apple_gmux
> apple_bl mac_hid nIs_iS08859_1 lp parport btrfs xor raid6_pq libcrc32c
> hid_generic
> CPU: 0 PID: 6395 Comm: pool Not tainted 3.13.0-031300rc5-generic #201312221635
> Hardware name: Apple Inc. MacBookFro10,1/Mac-C3EC7CD22292981F, BIOS
> M8P101.632.00EE.I
> task: ffff880178ec6000 ti: ffff880061914000 task.ti: ffff880061914000
> RIP: 0010:[<ffffffff813979f2>] kffffffff813979f2A sg_next+0x2/0x20
> RSP: 0018:ffff880061915740 EFLAGS: 00010046
> RAX: 0000000000000000 RBX: ff1f880036255000 RCX: 0000000000000003
> RDX: 0000000000000003 RSI: ffff880036255000 RDI: 0000000000000000
> R6P: ffff880061915798 R08: 0000000000000201 R09: 0000000000003578
> R10: ffffffff8163fa52 R11: 00000000000002c0 R12: ffff88025e5dfc00
> R13: ffff8802634f2098 R14: 0000000000000001 R15: ffffffff81c26c40
> FS: 00007fc7c4b37700(0000) OS:fff188026f200000(0000) knIGS:0000000000000000
> CS: 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000000 CR3: 00000001e8b12000 CR4: 00000000001407f0
> Stack:
> ffffffff8156d8fe 0000000000000000 ffff880100000003 ffff88011c144e40
> 00000003245ded00 ffff8801245ded00 ffff880036255000 ffff88025e5dfc00
> 0000000000000020 0000000000000200 1fff88007a3e59fc ffff8800619157d8
> Call Trace:
> [<ffffffff8156d8fe>] ? usb_hcd_map_urb_for_dma+0x30e/0x4b0
> [<ffffffff8156e535>] usb_hcd_submit_urb+0x125/0x1b0
> [<ffffffff8156f93f>] usb_submit_urb.part.7+0x15f/0x430
> [<ffffffff814c79a9>] ? __pm_runtime_resume+0x69/0x90
> [<ffffffff8156fc45>1 usb_submit_urb+0x35/0x80
> [<ffffffffa05c8b55>] usbnet_stert_xmit+0x245/0x640 [usbnet]
> [<ffffffff8165248d>] dev_hard_start_xmit+0x54d/0x5f0
> [<ffffffff8165248d>] ? dev_hard_start_xmit+0x54d/0x5f0
> [<ffffffff81671710>] sch_direct_xmit+0x100/0x1d0
> [<ffffffff816526a2>] dev_queue_xmit+0x172/0x4b0
> [<ffffffff8168c8b0>] ip_finish_output+0x224/0x3f0
> [<ffffffffB168d3b8>] ip_output+0x58/0x90
> [<ffffffff8168cb29>] 1p_local_out+0x29/0x30
> [<ffffffff8168cc70>] ip_queue_xmit+0x140/0x3d0
> [<ffffffff816a495a>] tcp_transmit_skb+0x3ba/0x620
> [<ffffffff816a55cc>] tcp_write_xmit+0xlic/0x470
> [<ffffffff81685992>] __tcp_push_pend1ng_frames+0x32/0xd0
> [<ffffffff816968af>] tcp_sendmsg+0xl2f/0xd70
> [<ffffffff816c0961>] inet_sendmsg+0x61/0xb0
> [<ffffffff8108f460>] ? __remove_hrtimer+0x60/0xc0
> [<ffffffff816374a2>] do_sock_write.isra.16+0xc2/0xe0
> [<ffffffff81637508>] sock_aio_write+0x48/0x60
> [<ffffffff8108f8c2>] ? hrtimer_cance1+0x22/0x30
> [<ffffffff811c38f8>] do_sync_readv_writev+0x48/0x80
> [<ffffffff811c4d18>] do_readv_writev+0xc8/0x2a0
> [<ffffffff8109fc6d>] ? vtime_account_user+0x5d/0x70
> [<ffffffffelic4f27>] vfs_writev+0x37/0x50
> [<ffffffff811c50a2>] SyS_writev+0x52/0xc0
> [<ffffffff8176c73f>] tracesys+0xe1/0xe6
> Code: 5c 41 5d 41 5e 41 5f 5d c3 55 48 c7 c2 00 7e 39 81 be 80 00 00
> 00 4S 89 eS e8 6b
> RIP [<ffffffffe13379f2>] sg_next+0x2/0x20
> RSP <ffff880061915740>
> CR2: 0000000000000000
> Kernel panic - not syncing: Fatal exception in interrupt
> drm_kms_helper: panic occurred, switching back to text console
-- 
Daniel J Blueman
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
