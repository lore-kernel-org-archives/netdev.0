From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 7/7] net_sched: act_mirred: remove spinlock in
 fast path
Date: Mon, 6 Jul 2015 16:56:49 +0200
Message-ID: <CANn89i+yN1-rqJZ7h8QxTAvopSgaGzwVY5ZrDRLz-tAMP3ijaA@mail.gmail.com>
References: <1436185089-18268-1-git-send-email-edumazet@google.com>
	<1436185089-18268-8-git-send-email-edumazet@google.com>
	<559A7A57.2000803@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:33711 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbbGFO4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 10:56:51 -0400
Received: by wgck11 with SMTP id k11so142798497wgc.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 07:56:50 -0700 (PDT)
In-Reply-To: <559A7A57.2000803@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 2:53 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> cant wait for the multi queue ifb.
>

Yeah, me too ;)

Do not try this on a production host :

ip link add ifb10 numtxqueues 1000000 type ifb

[284151.950695] kernel BUG at /build/buildd/linux-3.13.0/net/core/dev.c:5868!
[284151.950762] invalid opcode: 0000 [#1] SMP
[284151.950779] Modules linked in: ifb uvcvideo videobuf2_vmalloc
videobuf2_memops videobuf2_core videodev e1000e ptp pps_core ctr ccm
sch_codel sch_htb tcp_diag inet_diag nfnetlink_log nfnetlink xt_recent
arc4 iwldvm mac80211 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
xt_hl ip6t_rt ipt_REJECT xt_LOG snd_hda_codec_hdmi
snd_hda_codec_realtek ipt_ULOG xt_limit xt_tcpudp snd_hda_intel
snd_hda_codec nf_conntrack_ipv4 nf_defrag_ipv4 snd_hwdep xt_addrtype
snd_pcm xt_owner xt_conntrack ip6table_filter thinkpad_acpi
snd_page_alloc ip6_tables nvram xt_state xt_helper nf_nat_tftp
nf_conntrack_tftp nf_nat_irc snd_seq_midi nf_conntrack_irc
snd_seq_midi_event nf_nat_ftp nf_nat nf_conntrack_ftp nf_conntrack
iptable_filter snd_rawmidi ip_tables x_tables snd_seq snd_seq_device
intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp btusb
kvm_intel iwlwifi kvm snd_timer cfg80211 rfcomm bnep joydev serio_raw
bluetooth snd parport_pc wmi ppdev mac_hid mei_me lpc_ich shpchp mei
lp soundcore parport btrfs xor raid6_pq libcrc32c dm_crypt
crct10dif_pclmul crc32_pclmul ghash_clmulni_intel aesni_intel
aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd ahci psmouse
i915 libahci sdhci_pci sdhci i2c_algo_bit drm_kms_helper video drm
[last unloaded: videobuf2_memops]
[284151.968991] CPU: 3 PID: 1298 Comm: ip Tainted: G        W
3.13.0-55-generic #94-Ubuntu
[284151.972108] Hardware name: LENOVO 2429CY7/2429CY7, BIOS G4ET94WW
(2.54 ) 05/23/2013
[284151.973847] task: ffff8800a3e6b000 ti: ffff8801ba4da000 task.ti:
ffff8801ba4da000
[284151.975993] RIP: 0010:[<ffffffff8162b5b2>]  [<ffffffff8162b5b2>]
alloc_netdev_mqs+0x392/0x3c0
[284151.979497] RSP: 0018:ffff8801ba4db870  EFLAGS: 00010206
[284151.982916] RAX: 00000000000f4240 RBX: ffff8804082a3000 RCX:
0000000000000000
[284151.986433] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
ffff8801ba4db7e0
[284151.989907] RBP: ffff8801ba4db8a0 R08: 00000000a9d3373c R09:
ffff8801ba4db7d6
[284151.993381] R10: 00000000323f6b16 R11: 000000002c647ed6 R12:
00000000000f423f
[284151.996862] R13: 0000000000000001 R14: ffff8801ba4dba70 R15:
000000001312d000
[284152.000335] FS:  00007efdbf71f740(0000) GS:ffff88041e2c0000(0000)
knlGS:0000000000000000
[284152.003865] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[284152.007382] CR2: 00007ffd2acd1f88 CR3: 00000001b39cc000 CR4:
00000000001407e0
[284152.010870] Stack:
[284152.014321]  000000000000091f ffff88040431e800 ffff8801ba4db958
ffffffffa024c020
[284152.017798]  fffffffffffffff4 ffffffff81cdab40 ffff8801ba4db8e8
ffffffff816357bb
[284152.021287]  ffffffff8189d340 ffff8801ba4db8f8 ffff88040431e800
ffffffff81cdab40
[284152.024770] Call Trace:
[284152.028167]  [<ffffffff816357bb>] rtnl_create_link+0x5b/0x1c0
[284152.031558]  [<ffffffff816396aa>] rtnl_newlink+0x4ba/0x610
[284152.034960]  [<ffffffff8163932f>] ? rtnl_newlink+0x13f/0x610
[284152.038301]  [<ffffffff81635e85>] rtnetlink_rcv_msg+0x95/0x250
[284152.041605]  [<ffffffff8161765e>] ? __alloc_skb+0x7e/0x2b0
[284152.044552]  [<ffffffff81635df0>] ? rtnetlink_rcv+0x30/0x30
[284152.047950]  [<ffffffff81654479>] netlink_rcv_skb+0xa9/0xc0
[284152.051202]  [<ffffffff81635de8>] rtnetlink_rcv+0x28/0x30
[284152.054429]  [<ffffffff81653b65>] netlink_unicast+0xd5/0x1b0
[284152.057644]  [<ffffffff81653f4e>] netlink_sendmsg+0x30e/0x680
[284152.060847]  [<ffffffff8160e08b>] sock_sendmsg+0x8b/0xc0
[284152.064088]  [<ffffffff8160ddba>] ? move_addr_to_kernel.part.14+0x5a/0x60
[284152.067276]  [<ffffffff8160ebb1>] ? move_addr_to_kernel+0x21/0x30
[284152.070458]  [<ffffffff8160e499>] ___sys_sendmsg+0x389/0x3a0
[284152.073628]  [<ffffffff816530ed>] ? netlink_insert+0x14d/0x240
[284152.076764]  [<ffffffff8172f334>] ? __do_page_fault+0x204/0x570
[284152.079919]  [<ffffffff810fd1fd>] ? audit_filter_rules.isra.7+0x77d/0xf20
[284152.083061]  [<ffffffff8160f282>] __sys_sendmsg+0x42/0x80
[284152.086180]  [<ffffffff8160f2d2>] SyS_sendmsg+0x12/0x20
[284152.089268]  [<ffffffff81733d5d>] system_call_fastpath+0x1a/0x1f
