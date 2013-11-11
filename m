From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Oops in rfcomm_sock_getsockopt on net-next as of 20131111
Date: Mon, 11 Nov 2013 11:33:09 +0100
Message-ID: <874n7j6xei.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I got this when I booted my laptop with todays net-next:

[   16.064546] BUG: unable to handle kernel paging request at 00000c8bf=
d080975
[   16.064558] IP: [<ffffffffa07f65b3>] rfcomm_sock_getsockopt+0x62/0x2=
51 [rfcomm]
[   16.064561] PGD 0=20
[   16.064564] Oops: 0000 [#1] SMP=20
[   16.064637] Modules linked in: rfcomm bnep xt_hl binfmt_misc ip6tabl=
e_filter ip6_tables x_tables nfsd nfs_acl nfs lockd fscache sunrpc 8021=
q garp stp llc tun loop fuse iTCO_wdt iTCO_vendor_support snd_hda_codec=
_conexant arc4 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mi=
xer_oss iwlmvm mac80211 snd_pcm snd_page_alloc thinkpad_acpi nvram snd_=
seq_midi snd_seq_midi_event snd_rawmidi snd_seq iwlwifi coretemp uvcvid=
eo cdc_mbim cdc_wdm videobuf2_vmalloc videobuf2_memops cdc_ncm kvm_inte=
l videobuf2_core snd_seq_device psmouse usbnet lpc_ich videodev kvm snd=
_timer evdev serio_raw mfd_core mii cfg80211 i2c_i801 snd soundcore bat=
tery ac i915 i2c_algo_bit drm_kms_helper drm i2c_core acpi_cpufreq vide=
o wmi processor button btusb bluetooth rfkill ext4 crc16 jbd2 mbcache n=
bd sg sd_mod crc_t10dif sr_mod cdrom crct10dif_common ahci libahci micr=
ocode libata scsi_mod thermal thermal_sys ehci_pci uhci_hcd ehci_hcd e1=
000e usbcore ptp pps_core usb_common
[   16.064656] CPU: 1 PID: 3153 Comm: bluetoothd Not tainted 3.12.0+ #1=
36
[   16.064658] Hardware name: LENOVO 2776LEG/2776LEG, BIOS 6EET55WW (3.=
15 ) 12/19/2011
[   16.064660] task: ffff88022e50a440 ti: ffff8800b78b4000 task.ti: fff=
f8800b78b4000
[   16.064669] RIP: 0010:[<ffffffffa07f65b3>]  [<ffffffffa07f65b3>] rfc=
omm_sock_getsockopt+0x62/0x251 [rfcomm]
[   16.064670] RSP: 0018:ffff8800b78b5ed8  EFLAGS: 00010246
[   16.064672] RAX: 00000c8bfd080975 RBX: ffff8800b688b140 RCX: 00007ff=
f7ae042f8
[   16.064674] RDX: 0000000000000003 RSI: 0000000000000012 RDI: ffff880=
0b688b140
[   16.064676] RBP: ffff8800b78b5f28 R08: 00007fff7ae042fc R09: 00007ff=
f7ae042f8
[   16.064678] R10: 00007fff7ae042f8 R11: ffff8800b83ec180 R12: ffff880=
0b78bc800
[   16.064680] R13: 00007fff7ae042f8 R14: 0000000000000003 R15: ffff880=
0b78bc800
[   16.064682] FS:  00007f020d523740(0000) GS:ffff88023b000000(0000) kn=
lGS:0000000000000000
[   16.064685] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   16.064687] CR2: 00000c8bfd080975 CR3: 00000000b78a2000 CR4: 0000000=
0000007e0
[   16.064688] Stack:
[   16.064692]  ffff8800b78b5f08 00007fff7ae042fc ffffffff8139b647 0000=
7fff7ae04570
[   16.064696]  ffff8800b78b5f50 ffff8800b688b140 0000000000000012 0000=
000000000003
[   16.064700]  0000000000000011 00007f020e6abce0 ffff8800b78b5f78 ffff=
ffff812b8215
[   16.064701] Call Trace:
[   16.064708]  [<ffffffff8139b647>] ? sysret_check+0x1b/0x56
[   16.064714]  [<ffffffff812b8215>] SyS_getsockopt+0x79/0x99
[   16.064718]  [<ffffffff8139b622>] system_call_fastpath+0x16/0x1b
[   16.064756] Code: a0 31 c0 48 c7 c7 08 e0 7f a0 e8 35 45 9f e0 41 83=
 ff 12 0f 85 1e 01 00 00 4c 8b 7b 20 f6 05 a6 7a 00 00 04 49 8b 87 18 0=
5 00 00 <4c> 8b 20 74 18 4c 89 fa 48 c7 c6 8f b9 7f a0 31 c0 48 c7 c7 3=
0=20
[   16.064763] RIP  [<ffffffffa07f65b3>] rfcomm_sock_getsockopt+0x62/0x=
251 [rfcomm]
[   16.064764]  RSP <ffff8800b78b5ed8>
[   16.064766] CR2: 00000c8bfd080975
[   16.064769] ---[ end trace f71c8d4720ff0e6f ]---


I am using standard Debian startup scripts AFAIK, doing:

  /usr/bin/rfcomm -f /etc/bluetooth/rfcomm.conf bind all

where my rfcomm.conf is completely empty except for comments.  The
reported userspace version is

 RFCOMM configuration utility ver 4.99

Let me know if there is any other information you need to debug this
further.



Bj=C3=B8rn
