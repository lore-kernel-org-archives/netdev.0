From: Roland Dreier <roland@kernel.org>
Subject: Oops with ipsec vpn on latest 2.6.38-rc2+ kernel
Date: Sun, 30 Jan 2011 14:55:29 -0800
Message-ID: <AANLkTi=OTfax3CFzD9xBHbjV0RRB7aNEpHD0p9nm1cOB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38316 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721Ab1A3Wzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 17:55:50 -0500
Received: by ywe10 with SMTP id 10so1746267ywe.19
        for <netdev@vger.kernel.org>; Sun, 30 Jan 2011 14:55:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With an up-to-date kernel (head is 1f0324caefd3), I'm seeing the following oops
when I try to send traffic (I think it's my first name server query)
through an ipsec VPN
(set up with the shrew client):

[  307.861225] BUG: unable to handle kernel NULL pointer dereference
at           (null)
[  307.865272] IP: [<          (null)>]           (null)
[  307.868654] PGD 0
[  307.871146] Oops: 0010 [#1] SMP
[  307.873642] last sysfs file:
/sys/devices/LNXSYSTM:00/device:00/PNP0A08:00/device:0b/PNP0C09:00/PNP0C0A:00/power_supply/BAT0/voltage_now
[  307.876302] CPU 0
[  307.876329] Modules linked in: hidp hid ip6table_filter deflate
zlib_deflate ip6_tables ctr twofish_generic twofish_x86_64
twofish_common camellia serpent blowfish cast5 des_generic aesni_intel
cryptd aes_x86_64 aes_generic xcbc rmd160 xt_CHECKSUM iptable_mangle
sha512_generic binfmt_misc ipt_MASQUERADE iptable_nat nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack sha256_generic
ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge
sha1_generic stp crypto_null af_key joydev parport_pc dm_crypt ppdev
snd_hda_codec_hdmi rfcomm snd_hda_codec_conexant arc4 sco bnep
thinkpad_acpi l2cap iwlagn snd_hda_intel snd_hda_codec snd_hwdep
snd_pcm iwlcore uvcvideo snd_seq_midi snd_rawmidi mac80211
snd_seq_midi_event videodev v4l2_compat_ioctl32 btusb snd_seq
bluetooth cfg80211 snd_timer snd_seq_device psmouse serio_raw snd
snd_page_alloc intel_ips soundcore nvram tpm_tis tpm tpm_bios lp
parport i915 drm_kms_helper e1000e drm ahci libahci i2c_algo_bit video
[  307.898289]
[  307.901550] Pid: 3140, comm: ssh Not tainted 2.6.38-999-generic
#201101281114 2901CTO/2901CTO
[  307.904894] RIP: 0010:[<0000000000000000>]  [<          (null)>]
       (null)
[  307.908301] RSP: 0018:ffff880231b13ad0  EFLAGS: 00010246
[  307.911679] RAX: ffffffff81a643c0 RBX: 0000000000000000 RCX: ffff88023105b180
[  307.915069] RDX: ffff88023105b180 RSI: ffffffff814e5a50 RDI: ffff88023105b180
[  307.918484] RBP: ffff880231b13b88 R08: 0000000000000008 R09: ffff880231b13be8
[  307.921901] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000008
[  307.925304] R13: 0000000000000000 R14: ffff880231b13e58 R15: ffff88022fe223c0
[  307.928756] FS:  00007fd52fccc7e0(0000) GS:ffff8800bb000000(0000)
knlGS:0000000000000000
[  307.932232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  307.935709] CR2: 0000000000000000 CR3: 0000000204452000 CR4: 00000000000006f0
[  307.939253] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  307.942752] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  307.946109] Process ssh (pid: 3140, threadinfo ffff880231b12000,
task ffff88022dda5b00)
[  307.949520] Stack:
[  307.952869]  ffffffff814e6347 ffff880231b13af8 0000000000000246
ffff88022fe224c8
[  307.956302]  ffff880231b13be8 0000003d31b13b18 ffff880231b13e98
ffffffff814e5a50
[  307.959728]  ffff88023105be00 ffff880231b13b48 ffffffff814defc3
ffff880231b13c08
[  307.963144] Call Trace:
[  307.966528]  [<ffffffff814e6347>] ? ip_append_data+0x787/0xab0
[  307.969967]  [<ffffffff814e5a50>] ? ip_generic_getfrag+0x0/0xa0
[  307.973414]  [<ffffffff814defc3>] ? ipv4_dst_blackhole+0x1c3/0x210
[  307.976864]  [<ffffffff815a115e>] ? _raw_spin_lock_bh+0x1e/0x30
[  307.980287]  [<ffffffff8150bd09>] udp_sendmsg+0x389/0x790
[  307.983732]  [<ffffffff815143d9>] inet_sendmsg+0x69/0xc0
[  307.987138]  [<ffffffff8149cb3a>] sock_sendmsg+0x10a/0x120
[  307.990552]  [<ffffffff8107e663>] ? queue_delayed_work_on+0xb3/0x110
[  307.994033]  [<ffffffff815a1099>] ? _raw_spin_unlock_bh+0x19/0x20
[  307.997455]  [<ffffffff814b8260>] ? __dst_free+0x50/0xa0
[  308.000868]  [<ffffffff815a1099>] ? _raw_spin_unlock_bh+0x19/0x20
[  308.004274]  [<ffffffff8150adcb>] ? udp_lib_rehash+0x11b/0x140
[  308.007675]  [<ffffffff8150b2ef>] ? udp_v4_rehash+0x2f/0x40
[  308.011108]  [<ffffffff8149adaa>] ? sockfd_lookup_light+0x4a/0x80
[  308.014548]  [<ffffffff8149d75a>] sys_sendto+0x13a/0x190
[  308.017982]  [<ffffffff815a0e0e>] ? _raw_spin_lock+0xe/0x20
[  308.021395]  [<ffffffff81156c30>] ? fd_install+0x60/0x70
[  308.024770]  [<ffffffff8100c002>] system_call_fastpath+0x16/0x1b
[  308.028141] Code:  Bad RIP value.
[  308.031547] RIP  [<          (null)>]           (null)
[  308.034952]  RSP <ffff880231b13ad0>
[  308.038330] CR2: 0000000000000000
[  308.041823] ---[ end trace 12c863de1da69f98 ]---

This wasn't happening with Ubuntu's 2.6.37 kernels.  I haven't gotten too far
with debugging this yet, but any ideas of things to look at would be
appreciated.

Thanks,
  Roland
