From: Ben Greear <greearb@candelatech.com>
Subject: Crash in tcp_sack in hacked 3.14.4+, running as ath9k AP.
Date: Mon, 02 Jun 2014 13:39:35 -0700
Message-ID: <538CE107.5000206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34499 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396AbaFBUjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 16:39:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Console log looks like this.  The ath stuff is from a hack-around I have that
detects hung tx queues and tries to recover.  Not sure if that is related to
the crash or not.  System had been running under high load with hundreds of
stations associated (this system acts as AP) and passing tcp traffic at max
capacity on all of the stations.

We've only seen this once so far.  We upgraded to 3.14.5+ today,
will see if we can reproduce the crash.

ath: 1401236608.918699 wiphy0: tx hung, queue: 2 axq-depth: 1, ampdu-depth: 1 resetting the chip
ath: 1401236611.938756 wiphy0: soft tx hang: queue: 2 pending-frames: 123, resetting chip
ath: 1401236611.946931 wiphy0: Pending frames still exist on txq: 2 after drain: 123  axq-depth: 0  ampdu-depth: 0
ath: 1401236615.968806 wiphy0: soft tx hang: queue: 2 pending-frames: 123, resetting chip
ath: 1401236615.976896 wiphy0: Pending frames still exist on txq: 2 after drain: 123  axq-depth: 0  ampdu-depth: 0
ath: 1401236626.885297 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.26311 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.33907 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.41493 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.49066 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.56636 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.64196 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.71766 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.79350 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236627.86916 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.806162 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.813826 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.858572 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.866227 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.873877 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.881524 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.889173 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.896821 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
ath: 1401236634.904468 wiphy0: txq: ffff8800c725ab68 had negative pending_frames, q: 2
------------[ cut here ]------------
kernel BUG at /home/greearb/git/linux-3.14.dev.y/net/netfilter/nf_conntrack_proto_tcp.c:452!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: iptable_raw xt_CT nf_nat_ipv4 nf_nat bridge 8021q garp stp mrp llc macvlan wanlink(O) pktgen lockd sunrpc f71882fg coretemp hwmon ath9k
ath9k_common ath9k_hw ath mac80211 snd_hda_codec_realtek snd_hda_codec_generic cfg80211 snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device gpio_ich
e1000e snd_pcm pcspkr iTCO_wdt serio_raw uinput iTCO_vendor_support ptp pps_core snd_timer snd soundcore ppdev parport_pc i2c_i801 parport microcode lpc_ich
ipv6 i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: iptable_nat]
CPU: 3 PID: 0 Comm: swapper/3 Tainted: G         C O 3.14.4+ #32
Hardware name: To be filled by O.E.M. To be filled by O.E.M./To be filled by O.E.M., BIOS 4.6.3 03/06/2012
task: ffff880222140000 ti: ffff88022213a000 task.ti: ffff88022213a000
RIP: 0010:[<ffffffff8153f4e7>]  [<ffffffff8153f4e7>] tcp_packet+0x6a4/0x118d
RSP: 0018:ffff88022bd834a8  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88022054e900 RCX: 000000000000000c
RDX: 0000000000000000 RSI: ffff88022bd834a8 RDI: ffff8800c3799900
RBP: ffff88022bd835f8 R08: 00000000821f7485 R09: 0000000000000000
R10: ffffffff81ab2470 R11: 0000000000000000 R12: ffff88022054e9ec
R13: ffff8800c4155fa8 R14: 0000000000000028 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff88022bd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003c9dcba9f0 CR3: 0000000001a0c000 CR4: 00000000000007e0
Stack:
 ffff88022bd83518 ffffffff81503425 ffff880221a114c0 0000005b005b0d38
 ffff8802821f7485 00000034c672e800 ffff88022bd83510 0000000081512ca1
 ffff880221c45098 00000000c3799900 ffffffff81a89e00 0200000000000002
Call Trace:
 <IRQ>
 [<ffffffff81503425>] ? __skb_checksum+0x52/0x20a
 [<ffffffff8150874f>] ? __skb_checksum_complete+0xc/0xe
 [<ffffffff81538cdb>] ? nf_ct_key_equal+0x1f/0x7d
 [<ffffffff815398e9>] ? __nf_conntrack_find_get+0x149/0x15b
 [<ffffffff8153b4a6>] nf_conntrack_in+0x87c/0x9b2
 [<ffffffff8154992c>] ? ip_frag_mem+0x42/0x42
 [<ffffffff8158a7dd>] ipv4_conntrack_in+0x1e/0x20
 [<ffffffff815376fa>] nf_iterate+0x56/0x92
 [<ffffffff81547f48>] ? inet_add_protocol+0x43/0x43
 [<ffffffff81537908>] nf_hook_slow+0x76/0x10e
 [<ffffffff81547f48>] ? inet_add_protocol+0x43/0x43
 [<ffffffff81547f48>] ? inet_add_protocol+0x43/0x43
 [<ffffffff815484e2>] NF_HOOK.clone.1+0x41/0x53
 [<ffffffff815487f1>] ip_rcv+0x2af/0x2f6
 [<ffffffff8150e4a3>] __netif_receive_skb_core+0x4e8/0x523
 [<ffffffff8150e795>] ? netif_receive_skb_internal+0x87/0x87
 [<ffffffff8150e530>] __netif_receive_skb+0x52/0x57
 [<ffffffff8150e795>] ? netif_receive_skb_internal+0x87/0x87
 [<ffffffff8150e78e>] netif_receive_skb_internal+0x80/0x87
 [<ffffffff8150e795>] ? netif_receive_skb_internal+0x87/0x87
 [<ffffffff8150e79e>] netif_receive_skb+0x9/0xb
 [<ffffffffa073ecbd>] NF_HOOK.clone.0+0x4c/0x53 [bridge]
 [<ffffffffa073efdf>] br_handle_frame_finish+0x31b/0x336 [bridge]
 [<ffffffffa073ecc4>] ? NF_HOOK.clone.0+0x53/0x53 [bridge]
 [<ffffffffa073ecbd>] NF_HOOK.clone.0+0x4c/0x53 [bridge]
 [<ffffffffa073f187>] br_handle_frame+0x18d/0x1a6 [bridge]
 [<ffffffffa073effa>] ? br_handle_frame_finish+0x336/0x336 [bridge]
 [<ffffffff8150e321>] __netif_receive_skb_core+0x366/0x523
 [<ffffffff81011655>] ? read_tsc+0x9/0x1b
 [<ffffffff8150e530>] __netif_receive_skb+0x52/0x57
 [<ffffffff8150e78e>] netif_receive_skb_internal+0x80/0x87
 [<ffffffff814c65dc>] ? led_trigger_blink_setup+0x90/0x9f
 [<ffffffffa03757e5>] ? ieee80211_data_to_8023+0x2c2/0x33d [cfg80211]
 [<ffffffff8150e79e>] netif_receive_skb+0x9/0xb
 [<ffffffffa042a74f>] ieee80211_deliver_skb+0xc8/0x107 [mac80211]
 [<ffffffffa042c201>] ieee80211_rx_handlers+0x1375/0x18fc [mac80211]
 [<ffffffffa042cff8>] ieee80211_prepare_and_rx_handle+0x870/0x8dc [mac80211]
 [<ffffffffa042d7d2>] ieee80211_rx+0x6d3/0x745 [mac80211]
 [<ffffffff8150553b>] ? build_skb+0x33/0xbe
 [<ffffffffa061d2ef>] ? ath_debug_rate_stats+0x124/0x130 [ath9k]
 [<ffffffffa060d9f4>] ath_rx_tasklet+0xeaf/0xfdb [ath9k]
 [<ffffffffa060bf17>] ath9k_tasklet+0x1f2/0x27b [ath9k]
 [<ffffffff810b141e>] tasklet_action+0x70/0xc0
 [<ffffffff810b1b7d>] __do_softirq+0xd3/0x1ee
 [<ffffffff810b1d1a>] irq_exit+0x40/0x9e
 [<ffffffff8100c744>] do_IRQ+0xba/0xd4
 [<ffffffff815c0bad>] common_interrupt+0x6d/0x6d
 <EOI>
 [<ffffffff814c4286>] ? cpuidle_enter_state+0x42/0xad
 [<ffffffff814c427f>] ? cpuidle_enter_state+0x3b/0xad
 [<ffffffff814c43bd>] cpuidle_idle_call+0xcc/0x117
 [<ffffffff81012b4f>] arch_cpu_idle+0x9/0x1e
 [<ffffffff810f0077>] cpu_startup_entry+0x102/0x16f
 [<ffffffff81031dc1>] start_secondary+0x25d/0x260
Code: ff ff 48 8b bd 38 ff ff ff 48 8d 4d a0 44 89 f2 44 89 85 d0 fe ff ff 83 c6 14 e8 50 f4 ff ff 48 85 c0 44 8b 85 d0 fe ff ff 75 04 <0f> 0b eb fe 41 83 fe 0c
75 6d 81 38 01 01 08 0a 75 65 eb 68 8a
RIP  [<ffffffff8153f4e7>] tcp_packet+0x6a4/0x118d
 RSP <ffff88022bd834a8>
---[ end trace b93ac7ad488b6946 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
drm_kms_helper: panic occurred, switching back to text console


The crash comes from the BUG_ON below:


static void tcp_sack(const struct sk_buff *skb, unsigned int dataoff,
                     const struct tcphdr *tcph, __u32 *sack)
{
        unsigned char buff[(15 * 4) - sizeof(struct tcphdr)];
        const unsigned char *ptr;
        int length = (tcph->doff*4) - sizeof(struct tcphdr);
        __u32 tmp;

        if (!length)
                return;

        ptr = skb_header_pointer(skb, dataoff + sizeof(struct tcphdr),
                                 length, buff);
        BUG_ON(ptr == NULL);



Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
