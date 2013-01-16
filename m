From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: BUG when hot docking my laptop (v3.8-rc3-273-g3152ba0)
Date: Thu, 17 Jan 2013 09:39:31 +1100
Message-ID: <20130117093931.834661692f06cf1d5b7807ca@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__17_Jan_2013_09_39_31_+1100_QaOUFjB6mFqnjPt0"
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__17_Jan_2013_09_39_31_+1100_QaOUFjB6mFqnjPt0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

This morning when I hot docked my laptop (after it actually resumed for
once!) it produced this BUG message:

[16045.661684] genirq: Flags mismatch irq 46. 00000000 (eth0) vs. 00000000 =
(eth0)
[16045.661749] ------------[ cut here ]------------
[16045.661827] kernel BUG at drivers/pci/msi.c:346!
[16045.661902] invalid opcode: 0000 [#1] SMP=20
[16045.661974] Modules linked in: xhci_hcd hid_generic usbhid hid ip6table_=
filter ip6_tables iptable_filter ip_tables x_tables tun bnep rfcomm cpufreq=
_conservative cpufreq_stats cpufreq_powersave cpufreq_userspace uinput defl=
ate zlib_deflate ctr twofish_generic twofish_x86_64_3way twofish_x86_64 two=
fish_common camellia_generic camellia_x86_64 serpent_sse2_x86_64 serpent_ge=
neric glue_helper lrw xts gf128mul blowfish_generic blowfish_x86_64 blowfis=
h_common cast5_generic cast_common ablk_helper cryptd des_generic cbc xcbc =
rmd160 sha512_generic sha256_generic sha1_ssse3 sha1_generic hmac crypto_nu=
ll af_key xfrm_algo nf_conntrack_ftp nf_conntrack loop fuse dm_crypt dm_mod=
 snd_hda_codec_hdmi btusb bluetooth iTCO_wdt arc4 iTCO_vendor_support snd_h=
da_codec_conexant iwldvm mac80211 sg sr_mod cdrom coretemp kvm_intel kvm cr=
c32c_intel pcspkr psmouse serio_raw firewire_ohci i7core_edac edac_core fir=
ewire_core thinkpad_acpi lpc_ich i2c_i801 mfd_core crc_itu_t nvram battery =
ac snd_seq_midi nouve
au sdhci_pci acpi_cpufreq sdhci mperf mmc_core snd_hda_intel snd_rawmidi sn=
d_hda_codec snd_hwdep iwlwifi snd_pcm_oss video snd_seq_midi_event mxm_wmi =
snd_mixer_oss cfg80211 wmi ehci_pci ehci_hcd snd_pcm snd_seq usbcore rfkill=
 usb_common snd_seq_device snd_page_alloc snd_timer button drm_kms_helper e=
1000e ttm snd drm processor i2c_algo_bit i2c_core soundcore microcode therm=
al thermal_sys [last unloaded: xhci_hcd]
[16045.664620] CPU 6=20
[16045.664668] Pid: 8840, comm: ifconfig Not tainted 3.8.0-rc3+ #1 LENOVO 4=
389A97/4389A97
[16045.664828] RIP: 0010:[<ffffffff8120a3a3>]  [<ffffffff8120a3a3>] free_ms=
i_irqs+0x56/0x107
[16045.664962] RSP: 0018:ffff8801296e9c48  EFLAGS: 00010282
[16045.665043] RAX: ffff880127be1d80 RBX: ffff88012a5fb9c0 RCX: 00000000fff=
ffffa
[16045.665161] RDX: 0000000000000000 RSI: 000000000000002e RDI: 00000000000=
00000
[16045.665298] RBP: ffff880131d2a000 R08: ffff880133000050 R09: 00000000000=
00030
[16045.665447] R10: 00000000000000c8 R11: 0000000000000000 R12: 00000000000=
00000
[16045.665589] R13: ffff880131d2a848 R14: 0000000000000001 R15: 00000000000=
00000
[16045.665728] FS:  0000000000000000(0000) GS:ffff880137d80000(0063) knlGS:=
00000000f765c8d0
[16045.665894] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[16045.666010] CR2: 0000000008062e00 CR3: 00000001104aa000 CR4: 00000000000=
007e0
[16045.666153] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[16045.666300] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[16045.666456] Process ifconfig (pid: 8840, threadinfo ffff8801296e8000, ta=
sk ffff88013083f6a0)
[16045.666636] Stack:
[16045.666686]  ffff880131d2a000 ffff880130af0000 0000000000000000 ffff8801=
31d2a098
[16045.666869]  0000000000000001 ffffffff8120ae37 ffff880130af07c0 ffffffff=
a00ec658
[16045.667031]  ffff880130af07c0 ffffffffa00ec924 ffff880130af0000 ffff8801=
30af07c0
[16045.667209] Call Trace:
[16045.667277]  [<ffffffff8120ae37>] ? pci_disable_msi+0x28/0x41
[16045.667448]  [<ffffffffa00ec658>] ? e1000e_reset_interrupt_capability+0x=
48/0x54 [e1000e]
[16045.667654]  [<ffffffffa00ec924>] ? e1000_request_irq+0x1d2/0x249 [e1000=
e]
[16045.667807]  [<ffffffffa00eecdd>] ? e1000_open+0xe7/0x393 [e1000e]
[16045.667931]  [<ffffffff81399c14>] ? notifier_call_chain+0x2e/0x59
[16045.668068]  [<ffffffff812e63ca>] ? __dev_open+0x8c/0xce
[16045.668184]  [<ffffffff812e65d1>] ? __dev_change_flags+0x9d/0x118
[16045.668310]  [<ffffffff812e66b2>] ? dev_change_flags+0x12/0x42
[16045.668429]  [<ffffffff813308e7>] ? devinet_ioctl+0x247/0x53d
[16045.668553]  [<ffffffff812e6e4a>] ? dev_ioctl+0x46d/0x5d4
[16045.668674]  [<ffffffff812d252a>] ? sock_do_ioctl+0x1b/0x36
[16045.668806]  [<ffffffff812d3458>] ? compat_sock_ioctl+0xaf5/0xb68
[16045.668951]  [<ffffffff811a0553>] ? file_has_perm+0x6b/0x74
[16045.669073]  [<ffffffff8112a99b>] ? compat_sys_ioctl+0x1bf/0x10bc
[16045.669207]  [<ffffffff810e6ca5>] ? kmem_cache_alloc+0x4f/0xbd
[16045.669330]  [<ffffffff8139d11c>] ? sysenter_dispatch+0x7/0x21
[16045.669444] Code: eb 10 eb 33 8a 0b 41 be 01 00 00 00 45 31 e4 d0 e9 83 =
e1 07 41 d3 e6 eb 17 8b 7b 0c 44 01 e7 e8 90 30 e8 ff 48 83 78 58 00 74 02 =
<0f> 0b 41 ff c4 45 39 f4 7c e4 eb c3 48 8d 43 10 49 39 c5 75 b4=20
[16045.670155] RIP  [<ffffffff8120a3a3>] free_msi_irqs+0x56/0x107
[16045.670288]  RSP <ffff8801296e9c48>

This is v3.8-rc3-273-g3152ba0, config at
http://ozlabs.org/~sfr/config.oops, "lspci -vv -k output at
http://ozlabs.org/~sfr/lspci.oops

The laptop continued running enough for me to switch back to X and shut
it down.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__17_Jan_2013_09_39_31_+1100_QaOUFjB6mFqnjPt0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQ9ywjAAoJEECxmPOUX5FEO0IP/0BnF/DjDGQ4vuUK56N0qoMo
RASi8VB4Tj0RT6MxuqkyrsHOn16dP2bGGncQrS1U24+H9IkXLBdOS7+Wf9P6IBjB
Cj+sNC2S1waLVS0Sr9DqbDwaAEMqIxWoEF1CrWfxNF0FIC6+3dU0GQjJhqusMklp
zndd1auduxwqEVmibw+UBCcEFNGV8FLXWdPe8+SD/kVNDo2Op+eihIDSjujY1RBs
s97us6MKqNG8VtSxWpSwDDXB2CNvauhRCxAcmOkAgys6Tr4EiE/5h5clU7Thafhe
77sbAJ5+vzUhaA/YJYVIKSaD3cwAAulkAB92AQjcLQBzQk8H2D2c5XtoFPG9PTeF
rZ3FglBT7GTllmgPrrzghiDm8/gjc7LEt8/nvYnDkwAprrVGMNFVZIJLZdwDp/DF
F315wizdLQKqjNGwjfPGAfMCIOyg3oh+iqCLNp9wMsrga0tepBdc2lF153hXQ9T+
/I7yS1oAXbgTf6qrc7QxB02k2MGyo/KqVz0jYn6dc3Expxf4vSkegLRYbZYpTVpO
QMh6X4jt0DyWN2WNRqOFChH0rJMYNdfr1VPwiFTIyOO4M2FPfKVYzz0Y4+zJ9tv8
6k/2OrnmJw/J7ZfSQvHwjxBpZa1JP4/Rjs7WmvImDwMQR2tJQsbWtcvtCjSXLdvQ
VGI52y59izxIe5N7n7qP
=ZcuK
-----END PGP SIGNATURE-----

--Signature=_Thu__17_Jan_2013_09_39_31_+1100_QaOUFjB6mFqnjPt0--
