From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 83661] New: CPU hangs on pppd disconnect
Date: Tue, 2 Sep 2014 15:05:17 -0700
Message-ID: <20140902150517.6cf92dd0@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:63511 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750820AbaIBWFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 18:05:20 -0400
Received: by mail-pd0-f174.google.com with SMTP id ft15so9562919pdb.19
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 15:05:20 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id dw2sm14501855pab.8.2014.09.02.15.05.19
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Sep 2014 15:05:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 1 Sep 2014 02:43:35 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 83661] New: CPU hangs on pppd disconnect


https://bugzilla.kernel.org/show_bug.cgi?id=83661

            Bug ID: 83661
           Summary: CPU hangs on pppd disconnect
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.1-1-ARCH
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: alex@kurilo.me
        Regression: No

The following appears in the system log when l2tp-connection terminates:


Sep 01 12:16:17 localhost kernel: BUG: soft lockup - CPU#0 stuck for 23s!
[pppd:2320]
Sep 01 12:16:17 localhost kernel: Modules linked in: authenc xfrm_user ah6 ah4
esp6 esp4 xfrm4_mode_beet xfrm4_tunnel xfrm4_mode_tunnel xfrm4_mode_transport
xfrm6_mode_transport xfrm6_mode_ro xfrm6_mode_beet xfrm6_mode_tunnel ipcomp
ipcomp6 xfrm6_tunnel tunnel6 xfrm_ipcomp af_key l2tp_ppp l2tp_netlink l2tp_core
pppoe pppox ppp_generic slhc cmac rmd160 sha1_ssse3 sha1_generic hmac
crypto_null tunnel4 rng_core xfrm_algo camellia_generic camellia_aesni_avx2
camellia_aesni_avx_x86_64 camellia_x86_64 cast6_avx_x86_64 cast6_generic
cast5_avx_x86_64 cast5_generic cast_common deflate cts ctr gcm ccm serpent_avx2
serpent_avx_x86_64 serpent_sse2_x86_64 serpent_generic blowfish_generic
blowfish_x86_64 blowfish_common twofish_generic twofish_avx_x86_64
twofish_x86_64_3way xts twofish_x86_64 twofish_common xcbc cbc md5 sha256_ssse3
Sep 01 12:16:17 localhost kernel:  sha256_generic sha512_ssse3 sha512_generic
des_generic fuse bnep snd_hda_codec_hdmi snd_hda_codec_idt
snd_hda_codec_generic uvcvideo ecb btusb videobuf2_vmalloc videobuf2_memops
videobuf2_core v4l2_common bluetooth videodev 6lowpan_iphc media wl(PO)
snd_hda_intel rtsx_pci_ms i915 snd_hda_controller snd_hda_codec coretemp
rtsx_pci_sdmmc hwmon mmc_core intel_rapl x86_pkg_temp_thermal memstick joydev
mousedev iTCO_wdt iTCO_vendor_support snd_hwdep intel_powerclamp drm_kms_helper
cfg80211 hp_wmi sparse_keymap rfkill ppdev drm snd_pcm kvm_intel rtsx_pci kvm
snd_timer pcspkr evdev crct10dif_pclmul crc32_pclmul crc32c_intel
ghash_clmulni_intel aesni_intel tpm_infineon aes_x86_64 lrw gf128mul
glue_helper ablk_helper cryptd microcode e1000e snd soundcore ptp mac_hid
psmouse serio_raw pps_core
Sep 01 12:16:17 localhost kernel:  mei_me mei hp_accel led_class lis3lv02d
intel_gtt i2c_algo_bit i2c_i801 input_polldev i2c_core ac lpc_ich tpm_tis
battery tpm thermal wmi hp_wireless shpchp parport_pc parport video button
processor ext4 crc16 mbcache jbd2 sd_mod crc_t10dif crct10dif_common atkbd
libps2 ahci libahci libata scsi_mod ehci_pci ehci_hcd i8042 serio xhci_hcd
usbcore usb_common [last unloaded: tunnel6]
Sep 01 12:16:17 localhost kernel: CPU: 0 PID: 2320 Comm: pppd Tainted: P
   O  3.16.1-1-ARCH #1
Sep 01 12:16:17 localhost kernel: Hardware name: Hewlett-Packard HP ProBook 650
G1/1993, BIOS L77 Ver. 01.05 04/29/2014
Sep 01 12:16:17 localhost kernel: task: ffff8804197d8a30 ti: ffff880412f44000
task.ti: ffff880412f44000
Sep 01 12:16:17 localhost kernel: RIP: 0010:[<ffffffff815303a7>]
[<ffffffff815303a7>] _raw_spin_lock_bh+0x47/0x50
Sep 01 12:16:17 localhost kernel: RSP: 0018:ffff880412f47a58  EFLAGS: 00000206
Sep 01 12:16:17 localhost kernel: RAX: 00000000000057dd RBX: 0000000812f47b90
RCX: 0000000000000073
Sep 01 12:16:17 localhost kernel: RDX: 0000000000000072 RSI: 0000000000000002
RDI: ffff880412c20ea0
Sep 01 12:16:17 localhost kernel: RBP: ffff880412f47a58 R08: 0000000000000246
R09: ffff8800af918000
Sep 01 12:16:17 localhost kernel: R10: 000000000000ffff R11: 0000000000000096
R12: ffff880412f47a00
Sep 01 12:16:17 localhost kernel: R13: ffffffffa0f42e43 R14: 0000000000000008
R15: ffff880412f479c0
Sep 01 12:16:17 localhost kernel: FS:  00007f267c484700(0000)
GS:ffff88043fa00000(0000) knlGS:0000000000000000
Sep 01 12:16:17 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
Sep 01 12:16:17 localhost kernel: CR2: 0000000002d10000 CR3: 0000000414353000
CR4: 00000000001407f0
Sep 01 12:16:17 localhost kernel: Stack:
Sep 01 12:16:17 localhost kernel:  ffff880412f47af0 ffffffffa0f5c71c
ffff8800af91ada0 ffff8800af91ad10
Sep 01 12:16:17 localhost kernel:  ffff880412cd8a00 ffff880412f47aa0
ffffffff81268e96 ffff880412cd8a60
Sep 01 12:16:17 localhost kernel:  ffff8800af91ad90 ffff880412f47ab0
ffff8800af843900 ffff880412f47af0
Sep 01 12:16:17 localhost kernel: Call Trace:
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f5c71c>] ppp_push+0x11c/0x600
[ppp_generic]
Sep 01 12:16:17 localhost kernel:  [<ffffffff81268e96>] ?
shash_finup_unaligned+0x26/0x30
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f32331>] ? hmac_finup+0xa1/0xb0
[hmac]
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f5d03f>]
ppp_xmit_process+0x43f/0x650 [ppp_generic]
Sep 01 12:16:17 localhost kernel:  [<ffffffff81269686>] ?
shash_ahash_finup+0x56/0xc0
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f5d359>]
ppp_start_xmit+0x109/0x1d0 [ppp_generic]
Sep 01 12:16:17 localhost kernel:  [<ffffffff81438957>]
dev_hard_start_xmit+0x2f7/0x630
Sep 01 12:16:17 localhost kernel:  [<ffffffff8145a546>]
sch_direct_xmit+0xa6/0x210
Sep 01 12:16:17 localhost kernel:  [<ffffffff81438e6d>]
__dev_queue_xmit+0x1dd/0x4e0
Sep 01 12:16:17 localhost kernel:  [<ffffffff81439180>]
dev_queue_xmit+0x10/0x20
Sep 01 12:16:17 localhost kernel:  [<ffffffff81440401>]
neigh_direct_output+0x11/0x20
Sep 01 12:16:17 localhost kernel:  [<ffffffff8147536c>]
ip_finish_output+0x2ec/0x8e0
Sep 01 12:16:17 localhost kernel:  [<ffffffff814770c8>] ip_output+0x58/0x90
Sep 01 12:16:17 localhost kernel:  [<ffffffff814d0bca>]
xfrm_output_resume+0x39a/0x3c0
Sep 01 12:16:17 localhost kernel:  [<ffffffff814d0c52>] xfrm_output+0x42/0x100
Sep 01 12:16:17 localhost kernel:  [<ffffffff814c5eb2>]
xfrm4_output_finish+0x32/0x40
Sep 01 12:16:17 localhost kernel:  [<ffffffff814c5d6b>]
__xfrm4_output+0x2b/0x50
Sep 01 12:16:17 localhost kernel:  [<ffffffff814c5ef0>] xfrm4_output+0x30/0x70
Sep 01 12:16:17 localhost kernel:  [<ffffffff81476870>]
ip_local_out_sk+0x30/0x40
Sep 01 12:16:17 localhost kernel:  [<ffffffff81476bf3>]
ip_queue_xmit+0x143/0x390
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f738f6>]
l2tp_xmit_skb+0x2a6/0x540 [l2tp_core]
Sep 01 12:16:17 localhost kernel:  [<ffffffff81423e1c>] ?
skb_free_head+0x6c/0x80
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f883c7>]
pppol2tp_xmit+0x117/0x230 [l2tp_ppp]
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f5d470>]
ppp_channel_push+0x50/0xd0 [ppp_generic]
Sep 01 12:16:17 localhost kernel:  [<ffffffffa0f5d5b0>] ppp_write+0xa0/0xf0
[ppp_generic]
Sep 01 12:16:17 localhost kernel:  [<ffffffff811c1f87>] vfs_write+0xb7/0x200
Sep 01 12:16:17 localhost kernel:  [<ffffffff811c2bf9>] SyS_write+0x59/0xd0
Sep 01 12:16:17 localhost kernel:  [<ffffffff81530be9>]
system_call_fastpath+0x16/0x1b
Sep 01 12:16:17 localhost kernel: Code: 0f c1 07 0f b6 cc 38 c1 75 0a 5d c3 0f
1f 84 00 00 00 00 00 b8 00 80 00 00 eb 10 66 0f 1f 84 00 00 00 00 00 f3 90 83
e8 01 74 e9 <0f> b6 17 38 ca 75 f2 5d c3 0f 1f 44 00 00 55 48 89 e5 80 07 01
Sep 01 12:16:27 localhost xl2tpd[1342]: xl2tpd[1342]: Maximum retries exceeded
for tunnel 35511.  Closing.
Sep 01 12:16:27 localhost xl2tpd[1342]: xl2tpd[1342]: Terminating pppd: sending
TERM signal to pid 2320
Sep 01 12:16:27 localhost xl2tpd[1342]: xl2tpd[1342]: Connection 1043 closed to
VPN_SERVER, port 1701 (Timeout)
Sep 01 12:16:32 localhost xl2tpd[1342]: xl2tpd[1342]: Unable to deliver closing
message for tunnel 35511. Destroying anyway.
Sep 01 12:16:45 localhost kernel: BUG: soft lockup - CPU#0 stuck for 23s!
[pppd:2320]

Not sure what's the real cause but circumstances make me thing that it's
network-related.
IP address of the VPN server is replaced with VPN_SERVER and machine's hostname
is changed to localhost.

Please, advice whether this bug should live here or be submitted anywhere else.
I'm not even close to kernel- or C-development, but can provide some additional
information (well, if I understand how to get it).

--
You are receiving this mail because:
You are the assignee for the bug.
