From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Mon, 04 Apr 2011 22:37:57 +0200
Message-ID: <1301949477.3021.55.camel@edumazet-laptop>
References: <20110404194856.GA3720@dannf.org>  <4D9A23BC.4010505@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dann frazier <dannf@dannf.org>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36451 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755543Ab1DDUiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:38:02 -0400
In-Reply-To: <4D9A23BC.4010505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 avril 2011 =C3=A0 22:02 +0200, Patrick McHardy a =C3=A9crit=
 :
> CCed netfilter-devel.
>=20
> Am 04.04.2011 21:48, schrieb dann frazier:
> > fyi, noticed this oops when shutting down a system running top of g=
it
> > (@ 78fca1be)
> >=20
> > [ 1169.794644] cfg80211: Calling CRDA to update world regulatory do=
main
> > [ 1170.490646] bluetoothd[2029]: segfault at f8ad9944 ip 00000000f7=
7045e0 sp 00000000ffcb14e0 error 4 in bluetoothd[f76bf000+8b000]
> > [ 1170.543817] BUG: unable to handle kernel paging request at 00000=
001dc1be9f8
> > [ 1170.543875] IP: [<ffffffffa051e7b0>] xt_compat_calc_jump+0x25/0x=
6f [x_tables]
> > [ 1170.543927] PGD 1215b3067 PUD 0=20
> > [ 1170.543955] Oops: 0000 [#1] SMP=20
> > [ 1170.543982] last sysfs file: /sys/module/bridge/initstate
> > [ 1170.544017] CPU 3=20
> > [ 1170.544031] Modules linked in: ebtable_broute ebtable_filter vfa=
t msdos fat ext3 jbd ip6table_filter ip6_tables ebtable_nat ebtables ip=
t_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_sta=
te nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables =
bridge stp llc acpi_cpufreq mperf cpufreq_powersave cpufreq_userspace c=
pufreq_conservative cpufreq_stats binfmt_misc kvm(-) fuse ext2 loop snd=
_hda_codec_hdmi snd_hda_codec_conexant arc4 ecb snd_usb_audio snd_usbmi=
di_lib snd_seq_midi snd_seq_midi_event snd_hda_intel snd_hda_codec snd_=
hwdep snd_pcm snd_rawmidi i915 drm_kms_helper thinkpad_acpi snd_seq iwl=
agn snd_timer snd_seq_device drm snd mac80211 psmouse btusb serio_raw b=
luetooth evdev tpm_tis snd_page_alloc tpm i2c_i801 i2c_algo_bit cfg8021=
1 battery soundcore nvram tpm_bios i2c_core rfkill wmi ac power_supply =
video button processor ext4 mbcache jbd2 crc16 sha256_generic aesni_int=
el cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod sd_mod crc_t10di
> f=20
> >  usbhid
> > hid usb_storage ahci libahci libata ehci_hcd scsi_mod usbcore e1000=
e thermal thermal_sys [last unloaded: kvm_intel]
> > [ 1170.544836]=20
> > [ 1170.544849] Pid: 4901, comm: ebtables Not tainted 2.6.39-rc1+ #9=
 LENOVO 2516CTO/2516CTO
> > [ 1170.544902] RIP: 0010:[<ffffffffa051e7b0>]  [<ffffffffa051e7b0>]=
 xt_compat_calc_jump+0x25/0x6f [x_tables]
> > [ 1170.544958] RSP: 0018:ffff880121473cf8  EFLAGS: 00010217
> > [ 1170.544989] RAX: 000000003b837d3f RBX: 0000000000000090 RCX: 000=
000007706fa7f
> > [ 1170.545029] RDX: 0000000000000000 RSI: 0000000000000090 RDI: 000=
000003b837d3f
> > [ 1170.545067] RBP: ffffc900111a3000 R08: 0000000000000000 R09: dea=
d000000200200
> > [ 1170.545104] R10: dead000000100100 R11: 0000000000001311 R12: fff=
f880121473d88
> > [ 1170.545147] R13: ffffc900111a6000 R14: ffffffff817de300 R15: 000=
0000000000000
> > [ 1170.545185] FS:  0000000000000000(0000) GS:ffff880137d80000(0063=
) knlGS:00000000f761b6c0
> > [ 1170.545227] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
> > [ 1170.545258] CR2: 00000001dc1be9f8 CR3: 0000000125868000 CR4: 000=
00000000006e0
> > [ 1170.545297] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [ 1170.545334] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [ 1170.545375] Process ebtables (pid: 4901, threadinfo ffff88012147=
2000, task ffff8801322d1ac0)
> > [ 1170.545418] Stack:
> > [ 1170.545433]  0000000000000090 ffffffffa0576d46 f7007265746c6966 =
0000000000000054
> > [ 1170.545479]  0000000000000000 0000000000000000 000000000000000e =
0000000000000090
> > [ 1170.545529]  0000000000000000 0000000008af2180 0000000008af21b0 =
0000000008af21e0
> > [ 1170.545579] Call Trace:
> > [ 1170.545600]  [<ffffffffa0576d46>] ? compat_do_replace+0x117/0x22=
1 [ebtables]
> > [ 1170.545639]  [<ffffffffa0577392>] ? compat_do_ebt_set_ctl+0x55/0=
xbb [ebtables]
> > [ 1170.545688]  [<ffffffff810337e3>] ? need_resched+0x1a/0x23
> > [ 1170.545723]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > [ 1170.545730]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
> > [ 1170.545733]  [<ffffffff813152fe>] ? mutex_lock_interruptible+0x1=
8/0x32
> > [ 1170.545738]  [<ffffffff8128490b>] ? nf_sockopt_find.clone.1+0xda=
/0xec
> > [ 1170.545742]  [<ffffffff81284996>] ? compat_nf_sockopt+0x79/0xa5
> > [ 1170.545744]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > [ 1170.545747]  [<ffffffff812849f3>] ? compat_nf_setsockopt+0x1a/0x=
1f
> > [ 1170.545751]  [<ffffffff8128fb35>] ? compat_ip_setsockopt+0x80/0x=
a0
> > [ 1170.545756]  [<ffffffff812784a2>] ? compat_sys_setsockopt+0x1d5/=
0x204
> > [ 1170.545759]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
> > [ 1170.545761]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
> > [ 1170.545764]  [<ffffffff812788a5>] ? compat_sys_socketcall+0x148/=
0x1a7
> > [ 1170.545768]  [<ffffffff8131d2c0>] ? sysenter_dispatch+0x7/0x2e
> > [ 1170.545769] Code: 5d 41 5e 41 5f c3 40 0f b6 ff 53 31 d2 48 6b f=
f 70 48 03 3d 03 1b 00 00 8b 4f 6c 4c 8b 47 60 ff c9 eb 27 8d 04 11 d1 =
f8 48 63 f8=20
> > [ 1170.545787] RIP  [<ffffffffa051e7b0>] xt_compat_calc_jump+0x25/0=
x6f [x_tables]
> > [ 1170.545792]  RSP <ffff880121473cf8>
> > [ 1170.545794] CR2: 00000001dc1be9f8
> > [ 1170.654269] ---[ end trace d44667d90dcbd115 ]---
> > [ 1170.662411] fuse exit
> > Kernel logging (proc) stopped.
> > --


Hmm, commit 255d0dc34068a976550ce555e must have a problem for ebtables =
?

Dann, could you give us what you do with ebtables ?

Thanks


