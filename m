From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PANIC] pktgen panic on load
Date: Mon, 21 Sep 2009 09:54:51 -0700
Message-ID: <20090921095451.5ce95767@s6510>
References: <1253486747.17792.9.camel@jbrandeb-mobl2>
	<20090920213507.73cdc786@nehalam>
	<1253547857.2810.6.camel@odie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Simon Holm =?UTF-8?B?VGjDuGdlcnNlbg==?= <odie@cs.aau.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58406 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbZIUQy7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 12:54:59 -0400
In-Reply-To: <1253547857.2810.6.camel@odie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Sep 2009 17:44:17 +0200
Simon Holm Th=C3=B8gersen <odie@cs.aau.dk> wrote:

> s=C3=B8n, 20 09 2009 kl. 21:35 -0700, skrev Stephen Hemminger:
> > On Sun, 20 Sep 2009 15:45:47 -0700
> > Jesse Brandeburg <jesse.brandeburg@intel.com> wrote:
> >=20
> > > just got this today after cloning Linus' tree, please let me know=
 if you
> > > want .config or full dmesg
> >=20
> > config would help (hrt, nohz, preempt, ...), and was it just on mod=
ule load?
> > or had you started it sending?
>=20
> I have the similar trace below on a simple 'modprobe pktgen'. I've
> attached my config for v2.6.31-6456-g78f28b7.
>=20
> > [ 2302.386665] pktgen 2.72: Packet Generator for packet performance=
 testing.
> > [ 2302.386783] ------------[ cut here ]------------
> > [ 2302.386790] kernel BUG at net/core/pktgen.c:3503!
> > [ 2302.386796] invalid opcode: 0000 [#1] SMP=20
> > [ 2302.386803] last sysfs file: /sys/devices/pci0000:00/0000:00:1c.=
1/0000:02:00.0/ieee80211/phy0/rfkill1/state
> > [ 2302.386812] CPU 1=20
> > [ 2302.386817] Modules linked in: pktgen(+) i915 drm i2c_algo_bit c=
fbcopyarea cfbimgblt cfbfillrect binfmt_misc ipt_MASQUERADE iptable_nat=
 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack bnep ipt=
_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_=
intel kvm tun snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_pcm_=
oss snd_mixer_oss snd_pcm snd_seq_oss arc4 ecb snd_seq_midi_event snd_s=
eq iwlagn snd_timer snd_seq_device iwlcore mac80211 uvcvideo snd video =
sdhci_pci soundcore snd_page_alloc cfg80211 ricoh_mmc videodev v4l1_com=
pat v4l2_compat_ioctl32 intel_agp psmouse e1000e output sdhci led_class=
 btusb
> > [ 2302.386920] Pid: 2897, comm: kpktgend_0 Not tainted 2.6.31-debug=
 #8 HP EliteBook 6930p
> > [ 2302.386926] RIP: 0010:[<ffffffffa035483c>]  [<ffffffffa035483c>]=
 pktgen_thread_worker+0x19ac/0x1a40 [pktgen]
> > [ 2302.386945] RSP: 0018:ffff880050755d30  EFLAGS: 00010297
> > [ 2302.386950] RAX: 0000000000000001 RBX: ffff880057ae18c0 RCX: fff=
f880057ae18c0
> > [ 2302.386956] RDX: 0000000000000001 RSI: 0000000000000001 RDI: fff=
f88006637d400
> > [ 2302.386961] RBP: ffff880050755ee0 R08: ffff880050754000 R09: 000=
0000000000000
> > [ 2302.386967] R10: 0000000000000001 R11: 0000000000000400 R12: fff=
f88005ae61db0
> > [ 2302.386973] R13: ffff88006637d400 R14: ffffffffa0352e90 R15: fff=
f88006637d400
> > [ 2302.386980] FS:  0000000000000000(0000) GS:ffff880006080000(0000=
) knlGS:0000000000000000
> > [ 2302.386986] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > [ 2302.386991] CR2: 00007f861ee0e080 CR3: 0000000057a2a000 CR4: 000=
00000000026a0
> > [ 2302.386997] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000=
0000000000000
> > [ 2302.387003] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000=
0000000000400
> > [ 2302.387010] Process kpktgend_0 (pid: 2897, threadinfo ffff880050=
754000, task ffff880057ae18c0)
> > [ 2302.387014] Stack:
> > [ 2302.387018]  0000000000000000 ffff880057ae18f8 ffff88000609bc58 =
ffff880057ae18f8
> > [ 2302.387027] <0> ffff880050755d80 ffffffff81043726 ffff88000609bc=
30 ffff880057ae18f8
> > [ 2302.387037] <0> 0000000000000001 ffff88000609bc30 ffff880050755d=
b0 ffff88005ae1ca78
> > [ 2302.387048] Call Trace:
> > [ 2302.387064]  [<ffffffff81043726>] ? update_curr+0xe6/0x190
> > [ 2302.387073]  [<ffffffff8103586e>] ? update_stats_wait_end+0xae/0=
xf0
> > [ 2302.387084]  [<ffffffff81009e0d>] ? __switch_to+0xcd/0x320
> > [ 2302.387092]  [<ffffffff81040a13>] ? finish_task_switch+0x43/0xd0
> > [ 2302.387103]  [<ffffffff81444638>] ? thread_return+0x3e/0x6c6
> > [ 2302.387113]  [<ffffffff81066ed0>] ? autoremove_wake_function+0x0=
/0x40
> > [ 2302.387125]  [<ffffffffa0352e90>] ? pktgen_thread_worker+0x0/0x1=
a40 [pktgen]
> > [ 2302.387136]  [<ffffffffa0352e90>] ? pktgen_thread_worker+0x0/0x1=
a40 [pktgen]
> > [ 2302.387143]  [<ffffffff81066aa6>] kthread+0x96/0xb0
> > [ 2302.387151]  [<ffffffff8100c68a>] child_rip+0xa/0x20
> > [ 2302.387158]  [<ffffffff81066a10>] ? kthread+0x0/0xb0
> > [ 2302.387164]  [<ffffffff8100c680>] ? child_rip+0x0/0x20
> > [ 2302.387168] Code: 89 df 31 db e8 36 2d 00 e1 e9 0d f0 ff ff 90 8=
9 da 48 8b b5 b0 fe ff ff 48 c7 c7 ce 5e 35 a0 31 c0 e8 86 f6 0e e1 e9 =
fa f5 ff ff <0f> 0b eb fe 49 8b 85 48 02 00 00 48 89 de 4c 89 ef ff 50 =
30 89=20
> > [ 2302.387243] RIP  [<ffffffffa035483c>] pktgen_thread_worker+0x19a=
c/0x1a40 [pktgen]
> > [ 2302.387256]  RSP <ffff880050755d30>
> > [ 2302.387281] ---[ end trace 120a26c5c90348c4 ]---

Could you do a git bisect, although pktgen changed recently, the change=
s were
not related to the thread initialization, so I suspect something outsid=
e
the scope of networking (ie scheduler, vm, etc)
