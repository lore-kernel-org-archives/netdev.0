From: dann frazier <dannf@dannf.org>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 6 Apr 2011 10:25:48 -0600
Message-ID: <20110406162547.GA3064@dannf.org>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
 <1301957293.3021.191.camel@edumazet-laptop>
 <1301984679.3021.655.camel@edumazet-laptop>
 <1301987879.3021.714.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1301987879.3021.714.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2011 at 09:17:59AM +0200, Eric Dumazet wrote:
> Le mardi 05 avril 2011 =E0 08:24 +0200, Eric Dumazet a =E9crit :
> > Le mardi 05 avril 2011 =E0 00:48 +0200, Eric Dumazet a =E9crit :
> > > Le lundi 04 avril 2011 =E0 22:37 +0200, Eric Dumazet a =E9crit :
> > > > Le lundi 04 avril 2011 =E0 22:02 +0200, Patrick McHardy a =E9cr=
it :
> > > > > CCed netfilter-devel.
> > > > >=20
> > > > > Am 04.04.2011 21:48, schrieb dann frazier:
> > > > > > fyi, noticed this oops when shutting down a system running =
top of git
> > > > > > (@ 78fca1be)
> > > > > >=20
> > > > > > [ 1169.794644] cfg80211: Calling CRDA to update world regul=
atory domain
> > > > > > [ 1170.490646] bluetoothd[2029]: segfault at f8ad9944 ip 00=
000000f77045e0 sp 00000000ffcb14e0 error 4 in bluetoothd[f76bf000+8b000=
]
> > > > > > [ 1170.543817] BUG: unable to handle kernel paging request =
at 00000001dc1be9f8
> > > > > > [ 1170.543875] IP: [<ffffffffa051e7b0>] xt_compat_calc_jump=
+0x25/0x6f [x_tables]
> > > > > > [ 1170.543927] PGD 1215b3067 PUD 0=20
> > > > > > [ 1170.543955] Oops: 0000 [#1] SMP=20
> > > > > > [ 1170.543982] last sysfs file: /sys/module/bridge/initstat=
e
> > > > > > [ 1170.544017] CPU 3=20
> > > > > > [ 1170.544031] Modules linked in: ebtable_broute ebtable_fi=
lter vfat msdos fat ext3 jbd ip6table_filter ip6_tables ebtable_nat ebt=
ables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv=
4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x=
_tables bridge stp llc acpi_cpufreq mperf cpufreq_powersave cpufreq_use=
rspace cpufreq_conservative cpufreq_stats binfmt_misc kvm(-) fuse ext2 =
loop snd_hda_codec_hdmi snd_hda_codec_conexant arc4 ecb snd_usb_audio s=
nd_usbmidi_lib snd_seq_midi snd_seq_midi_event snd_hda_intel snd_hda_co=
dec snd_hwdep snd_pcm snd_rawmidi i915 drm_kms_helper thinkpad_acpi snd=
_seq iwlagn snd_timer snd_seq_device drm snd mac80211 psmouse btusb ser=
io_raw bluetooth evdev tpm_tis snd_page_alloc tpm i2c_i801 i2c_algo_bit=
 cfg80211 battery soundcore nvram tpm_bios i2c_core rfkill wmi ac power=
_supply video button processor ext4 mbcache jbd2 crc16 sha256_generic a=
esni_intel cryptd aes_x86_64 aes_generic cbc dm_crypt dm_mod sd_mod crc=
_t10di
> > > > > f=20
> > > > > >  usbhid
> > > > > > hid usb_storage ahci libahci libata ehci_hcd scsi_mod usbco=
re e1000e thermal thermal_sys [last unloaded: kvm_intel]
> > > > > > [ 1170.544836]=20
> > > > > > [ 1170.544849] Pid: 4901, comm: ebtables Not tainted 2.6.39=
-rc1+ #9 LENOVO 2516CTO/2516CTO
> > > > > > [ 1170.544902] RIP: 0010:[<ffffffffa051e7b0>]  [<ffffffffa0=
51e7b0>] xt_compat_calc_jump+0x25/0x6f [x_tables]
> > > > > > [ 1170.544958] RSP: 0018:ffff880121473cf8  EFLAGS: 00010217
> > > > > > [ 1170.544989] RAX: 000000003b837d3f RBX: 0000000000000090 =
RCX: 000000007706fa7f
> > > > > > [ 1170.545029] RDX: 0000000000000000 RSI: 0000000000000090 =
RDI: 000000003b837d3f
> > > > > > [ 1170.545067] RBP: ffffc900111a3000 R08: 0000000000000000 =
R09: dead000000200200
> > > > > > [ 1170.545104] R10: dead000000100100 R11: 0000000000001311 =
R12: ffff880121473d88
> > > > > > [ 1170.545147] R13: ffffc900111a6000 R14: ffffffff817de300 =
R15: 0000000000000000
> > > > > > [ 1170.545185] FS:  0000000000000000(0000) GS:ffff880137d80=
000(0063) knlGS:00000000f761b6c0
> > > > > > [ 1170.545227] CS:  0010 DS: 002b ES: 002b CR0: 00000000800=
50033
> > > > > > [ 1170.545258] CR2: 00000001dc1be9f8 CR3: 0000000125868000 =
CR4: 00000000000006e0
> > > > > > [ 1170.545297] DR0: 0000000000000000 DR1: 0000000000000000 =
DR2: 0000000000000000
> > > > > > [ 1170.545334] DR3: 0000000000000000 DR6: 00000000ffff0ff0 =
DR7: 0000000000000400
> > > > > > [ 1170.545375] Process ebtables (pid: 4901, threadinfo ffff=
880121472000, task ffff8801322d1ac0)
> > > > > > [ 1170.545418] Stack:
> > > > > > [ 1170.545433]  0000000000000090 ffffffffa0576d46 f70072657=
46c6966 0000000000000054
> > > > > > [ 1170.545479]  0000000000000000 0000000000000000 000000000=
000000e 0000000000000090
> > > > > > [ 1170.545529]  0000000000000000 0000000008af2180 000000000=
8af21b0 0000000008af21e0
> > > > > > [ 1170.545579] Call Trace:
> > > > > > [ 1170.545600]  [<ffffffffa0576d46>] ? compat_do_replace+0x=
117/0x221 [ebtables]
> > > > > > [ 1170.545639]  [<ffffffffa0577392>] ? compat_do_ebt_set_ct=
l+0x55/0xbb [ebtables]
> > > > > > [ 1170.545688]  [<ffffffff810337e3>] ? need_resched+0x1a/0x=
23
> > > > > > [ 1170.545723]  [<ffffffff810337f1>] ? should_resched+0x5/0=
x24
> > > > > > [ 1170.545730]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x=
20
> > > > > > [ 1170.545733]  [<ffffffff813152fe>] ? mutex_lock_interrupt=
ible+0x18/0x32
> > > > > > [ 1170.545738]  [<ffffffff8128490b>] ? nf_sockopt_find.clon=
e.1+0xda/0xec
> > > > > > [ 1170.545742]  [<ffffffff81284996>] ? compat_nf_sockopt+0x=
79/0xa5
> > > > > > [ 1170.545744]  [<ffffffff810337f1>] ? should_resched+0x5/0=
x24
> > > > > > [ 1170.545747]  [<ffffffff812849f3>] ? compat_nf_setsockopt=
+0x1a/0x1f
> > > > > > [ 1170.545751]  [<ffffffff8128fb35>] ? compat_ip_setsockopt=
+0x80/0xa0
> > > > > > [ 1170.545756]  [<ffffffff812784a2>] ? compat_sys_setsockop=
t+0x1d5/0x204
> > > > > > [ 1170.545759]  [<ffffffff810337f1>] ? should_resched+0x5/0=
x24
> > > > > > [ 1170.545761]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x=
20
> > > > > > [ 1170.545764]  [<ffffffff812788a5>] ? compat_sys_socketcal=
l+0x148/0x1a7
> > > > > > [ 1170.545768]  [<ffffffff8131d2c0>] ? sysenter_dispatch+0x=
7/0x2e
> > > > > > [ 1170.545769] Code: 5d 41 5e 41 5f c3 40 0f b6 ff 53 31 d2=
 48 6b ff 70 48 03 3d 03 1b 00 00 8b 4f 6c 4c 8b 47 60 ff c9 eb 27 8d 0=
4 11 d1 f8 48 63 f8=20
> > > > > > [ 1170.545787] RIP  [<ffffffffa051e7b0>] xt_compat_calc_jum=
p+0x25/0x6f [x_tables]
> > > > > > [ 1170.545792]  RSP <ffff880121473cf8>
> > > > > > [ 1170.545794] CR2: 00000001dc1be9f8
> > > > > > [ 1170.654269] ---[ end trace d44667d90dcbd115 ]---
> > > > > > [ 1170.662411] fuse exit
> > > > > > Kernel logging (proc) stopped.
> > > > > > --
> > > >=20
> > > >=20
> > > > Hmm, commit 255d0dc34068a976550ce555e must have a problem for e=
btables ?
> > > >=20
> > > > Dann, could you give us what you do with ebtables ?
> > > >=20
> > > > Thanks
> > > >=20
> > >=20
> > > For sure, there was a typo in above commit, but this is not enoug=
h to
> > > make ebtables work in COMPAT mode.
> > >=20
> > > Hmm...
> > >=20
> >=20
> > Update : xt_compat_calc_jump() misses this bit, and I still have to=
 find
> > the ebtables problem.
> >=20
> > I'll provide a cumulative patch once done
> >=20
>=20
> Here is the cumulative patch

Thanks Eric. Unfortunately that didn't solve the problem I am seeing.
I rebaselined (same kernel build as before), and found that I'm able
to reproduce this 100% of the time by running only:

  sudo ebtables -t filter --init-table

The backtrace I received was this:
[   73.393223] ------------[ cut here ]------------
[   73.394944] WARNING: at net/netfilter/x_tables.c:476 xt_compat_calc_=
jump+0x64/0x6f [x_tables]()
[   73.396427] Hardware name: 2516CTO
[   73.398079] Modules linked in: ebtable_broute ebtable_filter ip6tabl=
e_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_=
nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT x=
t_tcpudp iptable_filter ip_tables x_tables bridge stp llc acpi_cpufreq =
mperf cpufreq_powersave cpufreq_userspace cpufreq_conservative cpufreq_=
stats kvm_intel kvm binfmt_misc fuse ext2 loop snd_hda_codec_hdmi snd_h=
da_codec_conexant arc4 ecb snd_usb_audio snd_usbmidi_lib snd_seq_midi s=
nd_seq_midi_event snd_hda_intel snd_hda_codec iwlagn snd_hwdep snd_pcm =
snd_seq i915 snd_rawmidi thinkpad_acpi mac80211 snd_timer snd_seq_devic=
e btusb bluetooth psmouse battery tpm_tis cfg80211 drm_kms_helper drm s=
erio_raw nvram evdev ac tpm tpm_bios i2c_algo_bit i2c_i801 snd power_su=
pply soundcore rfkill wmi snd_page_alloc button i2c_core video processo=
r ext4 mbcache jbd2 crc16 sha256_generic aesni_intel cryptd aes_x86_64 =
aes_generic cbc dm_crypt dm_mod sd_mod crc_t10dif usbhid hid usb_storag=
e=20
ahci libahci libata ehci_hcd scsi_mod usbcore e1000e thermal thermal_sy=
s [last unloaded: scsi_wait_scan]
[   73.412341] Pid: 2891, comm: ebtables.orig Not tainted 2.6.39-rc1+ #=
9
[   73.414396] Call Trace:
[   73.416525]  [<ffffffff81041b99>] ? warn_slowpath_common+0x78/0x8c
[   73.418631]  [<ffffffffa05227ef>] ? xt_compat_calc_jump+0x64/0x6f [x=
_tables]
[   73.420758]  [<ffffffffa0571d46>] ? compat_do_replace+0x117/0x221 [e=
btables]
[   73.422859]  [<ffffffffa0572392>] ? compat_do_ebt_set_ctl+0x55/0xbb =
[ebtables]
[   73.425030]  [<ffffffff810337e3>] ? need_resched+0x1a/0x23
[   73.427110]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   73.429183]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
[   73.431290]  [<ffffffff813152fe>] ? mutex_lock_interruptible+0x18/0x=
32
[   73.433418]  [<ffffffff8128490b>] ? nf_sockopt_find.clone.1+0xda/0xe=
c
[   73.435520]  [<ffffffff81284996>] ? compat_nf_sockopt+0x79/0xa5
[   73.437565]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   73.439612]  [<ffffffff812849f3>] ? compat_nf_setsockopt+0x1a/0x1f
[   73.441666]  [<ffffffff8128fb35>] ? compat_ip_setsockopt+0x80/0xa0
[   73.443697]  [<ffffffff812784a2>] ? compat_sys_setsockopt+0x1d5/0x20=
4
[   73.445705]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   73.447739]  [<ffffffff81314cc5>] ? _cond_resched+0x9/0x20
[   73.449813]  [<ffffffff812788a5>] ? compat_sys_socketcall+0x148/0x1a=
7
[   73.451873]  [<ffffffff8131d2c0>] ? sysenter_dispatch+0x7/0x2e
[   73.453894] ---[ end trace 2285ecdee0e743d3 ]---
[   73.745725] Ebtables v2.0 unregistered

I reliably get the same backtrace, which is slightly different than
the one I originally submitted. I've only seen that original backtrace
once.

I then applied your patch, but I'm still seeing a similar backtrace:
[   33.143939] ------------[ cut here ]------------
[   33.146063] WARNING: at net/netfilter/x_tables.c:479 xt_compat_calc_=
jump+0x6f/0x7a [x_tables]()
[   33.148360] Hardware name: 2516CTO
[   33.150654] Modules linked in: ebtable_filter ip6table_filter ip6_ta=
bles ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrac=
k_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptabl=
e_filter ip_tables x_tables bridge stp llc acpi_cpufreq mperf cpufreq_p=
owersave cpufreq_userspace cpufreq_conservative cpufreq_stats kvm_intel=
 kvm binfmt_misc fuse ext2 loop snd_hda_codec_hdmi snd_hda_codec_conexa=
nt arc4 ecb thinkpad_acpi i915 snd_hda_intel iwlagn snd_hda_codec snd_h=
wdep snd_pcm mac80211 drm_kms_helper drm snd_seq snd_timer psmouse i2c_=
i801 btusb snd_seq_device bluetooth ac cfg80211 evdev tpm_tis snd serio=
_raw rfkill i2c_algo_bit tpm battery power_supply nvram wmi i2c_core tp=
m_bios soundcore snd_page_alloc button processor video ext4 mbcache jbd=
2 crc16 sha256_generic aesni_intel cryptd aes_x86_64 aes_generic cbc dm=
_crypt dm_mod sd_mod crc_t10dif ahci libahci ehci_hcd libata usbcore sc=
si_mod e1000e thermal thermal_sys [last unloaded: scsi_wait_scan]
[   33.167207] Pid: 2279, comm: ebtables Not tainted 2.6.39-rc1+ #11
[   33.169998] Call Trace:
[   33.172814]  [<ffffffff81041be9>] ? warn_slowpath_common+0x78/0x8c
[   33.175723]  [<ffffffffa04d7801>] ? xt_compat_calc_jump+0x6f/0x7a [x=
_tables]
[   33.178549]  [<ffffffffa0526d54>] ? compat_do_replace+0x125/0x22f [e=
btables]
[   33.181370]  [<ffffffffa05273a0>] ? compat_do_ebt_set_ctl+0x55/0xb9 =
[ebtables]
[   33.184240]  [<ffffffff810337e3>] ? need_resched+0x1a/0x23
[   33.187055]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   33.189805]  [<ffffffff81314d25>] ? _cond_resched+0x9/0x20
[   33.192578]  [<ffffffff8131535e>] ? mutex_lock_interruptible+0x18/0x=
32
[   33.195385]  [<ffffffff8128496b>] ? nf_sockopt_find.clone.1+0xda/0xe=
c
[   33.198093]  [<ffffffff812849f6>] ? compat_nf_sockopt+0x79/0xa5
[   33.200852]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   33.203618]  [<ffffffff81284a53>] ? compat_nf_setsockopt+0x1a/0x1f
[   33.206291]  [<ffffffff8128fb95>] ? compat_ip_setsockopt+0x80/0xa0
[   33.209001]  [<ffffffff81278502>] ? compat_sys_setsockopt+0x1d5/0x20=
4
[   33.211726]  [<ffffffff810337f1>] ? should_resched+0x5/0x24
[   33.214374]  [<ffffffff81314d25>] ? _cond_resched+0x9/0x20
[   33.217083]  [<ffffffff81278905>] ? compat_sys_socketcall+0x148/0x1a=
7
[   33.219811]  [<ffffffff8131d340>] ? sysenter_dispatch+0x7/0x2e
[   33.222433] ---[ end trace 96f8ae34f1f5ad81 ]---

    -dann

> Thanks
>=20
> [PATCH] netfilter: fix ebtables
>=20
> commit 255d0dc34068a976 (netfilter: x_table: speedup compat operation=
s)
> made ebtables not working anymore.
>=20
> 1) xt_compat_calc_jump() is not an exact match lookup, and=20
> 2) compat_table_info() has a typo in xt_compat_init_offsets() call
> 3) compat_do_replace() misses a xt_compat_init_offsets() call
>=20
> Reported-by: dann frazier <dannf@dannf.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/bridge/netfilter/ebtables.c |    3 ++-
>  net/netfilter/x_tables.c        |    3 +++
>  2 files changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/e=
btables.c
> index 893669c..c66aa80 100644
> --- a/net/bridge/netfilter/ebtables.c
> +++ b/net/bridge/netfilter/ebtables.c
> @@ -1766,7 +1766,7 @@ static int compat_table_info(const struct ebt_t=
able_info *info,
> =20
>  	newinfo->entries_size =3D size;
> =20
> -	xt_compat_init_offsets(AF_INET, info->nentries);
> +	xt_compat_init_offsets(NFPROTO_BRIDGE, info->nentries /* + 4*/);
>  	return EBT_ENTRY_ITERATE(entries, size, compat_calc_entry, info,
>  							entries, newinfo);
>  }
> @@ -2240,6 +2240,7 @@ static int compat_do_replace(struct net *net, v=
oid __user *user,
> =20
>  	xt_compat_lock(NFPROTO_BRIDGE);
> =20
> +	xt_compat_init_offsets(NFPROTO_BRIDGE, tmp.nentries);
>  	ret =3D compat_copy_entries(entries_tmp, tmp.entries_size, &state);
>  	if (ret < 0)
>  		goto out_unlock;
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index a9adf4c..e6dbec5 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -455,6 +455,7 @@ void xt_compat_flush_offsets(u_int8_t af)
>  		vfree(xt[af].compat_tab);
>  		xt[af].compat_tab =3D NULL;
>  		xt[af].number =3D 0;
> +		xt[af].cur =3D 0;
>  	}
>  }
>  EXPORT_SYMBOL_GPL(xt_compat_flush_offsets);
> @@ -473,6 +474,8 @@ int xt_compat_calc_jump(u_int8_t af, unsigned int=
 offset)
>  		else
>  			return mid ? tmp[mid - 1].delta : 0;
>  	}
> +	if (left)
> +		return tmp[left - 1].delta;
>  	WARN_ON_ONCE(1);
>  	return 0;
>  }
>=20
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
