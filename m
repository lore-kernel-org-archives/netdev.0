From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch (for 2.6.25?) 1/2] bluetooth: hci_core: defer hci_unregister_sysfs()
Date: Wed, 5 Mar 2008 09:48:29 +0100
Message-ID: <1250A009-2EDE-4203-9472-05F68BC66001@holtmann.org>
References: <200803042258.m24Mw6sO001378@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, hidave.darkstar@gmail.com,
	alon.barlev@gmail.com, seife@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60160 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbYCEIsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 03:48:37 -0500
In-Reply-To: <200803042258.m24Mw6sO001378@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> From: Dave Young <hidave.darkstar@gmail.com>
>
> Alon Bar-Lev reports:
>
>> Feb 16 23:41:33 alon1 usb 3-1: configuration #1 chosen from 1 choice
> Feb 16 23:41:33 alon1 BUG: unable to handle kernel NULL pointer  
> dereference at virtual address 00000008
> Feb 16 23:41:33 alon1 printing eip: c01b2db6 *pde = 00000000
> Feb 16 23:41:33 alon1 Oops: 0000 [#1] PREEMPT
> Feb 16 23:41:33 alon1 Modules linked in: ppp_deflate zlib_deflate  
> zlib_inflate bsd_comp ppp_async rfcomm l2cap hci_usb vmnet(P)  
> vmmon(P) tun radeon drm autofs4 ipv6 aes_generic crypto_algapi  
> ieee80211_crypt_ccmp nf_nat_irc nf_nat_ftp nf_conntrack_irc  
> nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat ipt_REJECT  
> xt_tcpudp ipt_LOG xt_limit xt_state nf_conntrack_ipv4 nf_conntrack  
> iptable_filter ip_tables x_tables snd_pcm_oss snd_mixer_oss  
> snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device  
> bluetooth ppp_generic slhc ioatdma dca cfq_iosched cpufreq_powersave  
> cpufreq_ondemand cpufreq_conservative acpi_cpufreq freq_table uinput  
> fan af_packet nls_cp1255 nls_iso8859_1 nls_utf8 nls_base pcmcia  
> snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm nsc_ircc snd_timer  
> ipw2200 thinkpad_acpi irda snd ehci_hcd yenta_socket uhci_hcd  
> psmouse ieee80211 soundcore intel_agp hwmon rsrc_nonstatic pcspkr  
> e1000 crc_ccitt snd_page_alloc i2c_i801 ieee80211_crypt pcmcia_core  
> agpgart thermal bat!
> tery nvram rtc sr_mod ac sg firmware_class button processor cdrom  
> unix usbcore evdev ext3 jbd ext2 mbcache loop ata_piix libata sd_mod  
> scsi_mod
> Feb 16 23:41:33 alon1
> Feb 16 23:41:33 alon1 Pid: 4, comm: events/0 Tainted: P         
> (2.6.24-gentoo-r2 #1)
> Feb 16 23:41:33 alon1 EIP: 0060:[<c01b2db6>] EFLAGS: 00010282 CPU: 0
> Feb 16 23:41:33 alon1 EIP is at sysfs_get_dentry+0x26/0x80
> Feb 16 23:41:33 alon1 EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX:  
> f48a2210
> Feb 16 23:41:33 alon1 ESI: f72eb900 EDI: f4803ae0 EBP: f4803ae0 ESP:  
> f7c49efc
> Feb 16 23:41:33 alon1 hcid[7004]: HCI dev 0 registered
> Feb 16 23:41:33 alon1 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> Feb 16 23:41:33 alon1 Process events/0 (pid: 4, ti=f7c48000  
> task=f7c3efc0 task.ti=f7c48000)
> Feb 16 23:41:33 alon1 Stack: f7cb6140 f4822668 f7e71e10 c01b304d  
> ffffffff ffffffff fffffffe c030ba9c
> Feb 16 23:41:33 alon1 f7cb6140 f4822668 f6da6720 f7cb6140 f4822668  
> f6da6720 c030ba8e c01ce20b
> Feb 16 23:41:33 alon1 f6e9dd00 c030ba8e f6da6720 f6e9dd00 f6e9dd00  
> 00000000 f4822600 00000000
> Feb 16 23:41:33 alon1 Call Trace:
> Feb 16 23:41:33 alon1 [<c01b304d>] sysfs_move_dir+0x3d/0x1f0
> Feb 16 23:41:33 alon1 [<c01ce20b>] kobject_move+0x9b/0x120
> Feb 16 23:41:33 alon1 [<c0241711>] device_move+0x51/0x110
> Feb 16 23:41:33 alon1 [<f9aaed80>] del_conn+0x0/0x70 [bluetooth]
> Feb 16 23:41:33 alon1 [<f9aaed99>] del_conn+0x19/0x70 [bluetooth]
> Feb 16 23:41:33 alon1 [<c012c1a1>] run_workqueue+0x81/0x140
> Feb 16 23:41:33 alon1 [<c02c0c88>] schedule+0x168/0x2e0
> Feb 16 23:41:33 alon1 [<c012fc70>] autoremove_wake_function+0x0/0x50
> Feb 16 23:41:33 alon1 [<c012c9cb>] worker_thread+0x9b/0xf0
> Feb 16 23:41:33 alon1 [<c012fc70>] autoremove_wake_function+0x0/0x50
> Feb 16 23:41:33 alon1 [<c012c930>] worker_thread+0x0/0xf0
> Feb 16 23:41:33 alon1 [<c012f962>] kthread+0x42/0x70
> Feb 16 23:41:33 alon1 [<c012f920>] kthread+0x0/0x70
> Feb 16 23:41:33 alon1 [<c0104c2f>] kernel_thread_helper+0x7/0x18
> Feb 16 23:41:33 alon1 =======================
> Feb 16 23:41:33 alon1 Code: 26 00 00 00 00 57 89 c7 a1 50 1b 3a c0  
> 56 53 8b 70 38 85 f6 74 08 8b 0e 85 c9 74 58 ff 06 8b 56 50 39 fa 74  
> 47 89 fb eb 02 89 c3 <8b> 43 08 39 c2 75 f7 8b 46 08 83 c0 68 e8 98  
> e7 10 00 8b 43 10
> Feb 16 23:41:33 alon1 EIP: [<c01b2db6>] sysfs_get_dentry+0x26/0x80  
> SS:ESP 0068:f7c49efc
> Feb 16 23:41:33 alon1 ---[ end trace aae864e9592acc1d ]---
>
> Defer hci_unregister_sysfs because hci device could be destructed
> while hci conn devices still there.
>
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> Tested-by: Stefan Seyfried <seife@suse.de>
> Acked-by: Alon Bar-Lev <alon.barlev@gmail.com>
> Cc: Marcel Holtmann <marcel@holtmann.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
> net/bluetooth/hci_core.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff -puN net/bluetooth/hci_core.c~bluetooth-hci_core-defer- 
> hci_unregister_sysfs net/bluetooth/hci_core.c
> --- a/net/bluetooth/hci_core.c~bluetooth-hci_core-defer- 
> hci_unregister_sysfs
> +++ a/net/bluetooth/hci_core.c
> @@ -902,8 +902,6 @@ int hci_unregister_dev(struct hci_dev *h
>
> 	BT_DBG("%p name %s type %d", hdev, hdev->name, hdev->type);
>
> -	hci_unregister_sysfs(hdev);
> -
> 	write_lock_bh(&hci_dev_list_lock);
> 	list_del(&hdev->list);
> 	write_unlock_bh(&hci_dev_list_lock);
> @@ -915,6 +913,8 @@ int hci_unregister_dev(struct hci_dev *h
>
> 	hci_notify(hdev, HCI_DEV_UNREG);
>
> +	hci_unregister_sysfs(hdev);
> +
> 	__hci_dev_put(hdev);

I never got a chance to test this one in a proper way, but from a  
logic point of view it makes sense and thus it is acked by me. I also  
trust Stefan that he fully tested it.

Regards

Marcel

