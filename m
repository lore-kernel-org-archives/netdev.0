From: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: net-next-2.6: Bluetooth: NULL pointer dereference in tty_register_device
Date: Wed, 03 Jun 2009 19:12:18 +0200
Message-ID: <4A26AEF2.2000900@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

this morning i got this NULL pointer dereference at boot time
with Daves (that time) latest net-next-2.6 tree.

Any idea about this bug?

I only got this problem once so far.

Regards,
Oliver

----


Jun  3 09:41:52 vwagwolkf320 kernel: [   25.591133] Bluetooth: L2CAP ver 2.13
Jun  3 09:41:52 vwagwolkf320 kernel: [   25.617796] Bluetooth: L2CAP socket layer initialized
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.748174] Bletooth: RFCOMM socket layer initialized
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.759983] BUG: unable to handle kernel NULL pointer dereference at 00000054
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.759993] IP: [<c0276c44>] tty_register_device+0x10/0xb8
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760009] *pde = 00000000 
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760014] Oops: 0000 [#1] SMP 
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760020] last sysfs file: /sys/module/l2cap/initstate
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760025] Modules linked in: rfcomm(+) l2cap aes_i586 aes_generic snd_hda_codec_idt arc4 ecb cryptomgr aead pcompress snd_hda_intel crypto_blkcipher snd_hda_codec crypto_hash snd_pcm_oss snd_mixer_oss crypto_algapi snd_pcm snd_seq_oss b43 snd_seq_midi snd_rawmidi mac80211 snd_seq_midi_event snd_seq snd_timer snd_seq_device cfg80211 pcmcia snd i2c_i801 btusb ssb snd_page_alloc yenta_socket rsrc_nonstatic pcmcia_core bluetooth dell_laptop backlight rfkill dcdbas
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760088] 
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760096] Pid: 3444, comm: rfcomm Not tainted (2.6.30-rc6-03219-gd455e5b #19) Latitude D830                   
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760103] EIP: 0060:[<c0276c44>] EFLAGS: 00010282 CPU: 0
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760110] EIP is at tty_register_device+0x10/0xb8
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760115] EAX: 00000000 EBX: 00000000 ECX: 00000000 EDX: 00000000
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760121] ESI: 00000000 EDI: 00000000 EBP: f63ebe88 ESP: f63ebe34
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760127]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760134] Process rfcomm (pid: 3444, ti=f63ea000 task=f6a9e840 task.ti=f63ea000)
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760138] Stack:
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760142]  00000000 f63ebe50 c013fb46 00000006 f6a9e840 c0127675 f62143c0 f63ebe60
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760153]  c013fdb2 fa387621 00000000 f63ebe68 c013fde5 f63ebe74 c0127675 fa38a928
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760165]  f63ebe7c c0127681 fa38a944 00000000 f62143c0 f63ebed8 fa387638 ffffffff
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760178] Call Trace:
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760182]  [<c013fb46>] ? mark_held_locks+0x43/0x5b
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760192]  [<c0127675>] ? _local_bh_enable_ip+0x97/0x9b
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760203]  [<c013fdb2>] ? trace_hardirqs_on_caller+0x107/0x12f
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760211]  [<fa387621>] ? rfcomm_dev_ioctl+0x33c/0x627 [rfcomm]
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760230]  [<c013fde5>] ? trace_hardirqs_on+0xb/0xd
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760238]  [<c0127675>] ? _local_bh_enable_ip+0x97/0x9b
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760247]  [<c0127681>] ? local_bh_enable_ip+0x8/0xa
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760255]  [<fa387638>] ? rfcomm_dev_ioctl+0x353/0x627 [rfcomm]
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760272]  [<c012768e>] ? local_bh_enable+0xb/0xd
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760280]  [<c033e72f>] ? lock_sock_nested+0xbe/0xc9
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760289]  [<fa386072>] ? rfcomm_sock_ioctl+0x28/0x45 [rfcomm]
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760306]  [<fa38607e>] ? rfcomm_sock_ioctl+0x34/0x45 [rfcomm]
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760321]  [<c033c34b>] ? sock_ioctl+0x1d3/0x1f7
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760332]  [<c033c178>] ? sock_ioctl+0x0/0x1f7
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760340]  [<c0181e1f>] ? vfs_ioctl+0x22/0x69
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760350]  [<c01822c6>] ? do_vfs_ioctl+0x460/0x499
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760358]  [<c013fde5>] ? trace_hardirqs_on+0xb/0xd
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760365]  [<c01672e7>] ? remove_vma+0x55/0x5b
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760376]  [<c01672e7>] ? remove_vma+0x55/0x5b
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760384]  [<c0167f58>] ? sys_munmap+0x31/0x37
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760392]  [<c0102a4b>] ? sysenter_exit+0xf/0x18
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760401]  [<c018232b>] ? sys_ioctl+0x2c/0x45
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760409]  [<c0102a18>] ? sysenter_do_call+0x12/0x36
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760418] Code: 00 89 d8 e8 b7 d5 ef ff 8d 46 08 e8 ed 36 f0 ff 89 f0 e8 a8 d5 ef ff 5b 5e 5d c3 55 89 e5 57 89 d7 56 53 89 c3 83 ec 48 89 4d ac <8b> 70 54 8b 40 58 3b 53 60 89 45 b0 72 14 52 68 34 e0 4c c0 e8 
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760481] EIP: [<c0276c44>] tty_register_device+0x10/0xb8 SS:ESP 0068:f63ebe34
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760491] CR2: 0000000000000054
Jun  3 09:41:53 vwagwolkf320 kernel: [   25.760512] ---[ end trace ad03b3043ac52689 ]---
Jun  3 09:41:53 vwagwolkf320 kernel: [   27.148514] Bluetooth: RFCOMM TTY layer initialized
Jun  3 09:41:53 vwagwolkf320 kernel: [   27.177881] Bluetooth: RFCOMM ver 1.11
