From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: new warning at net/wireless/util.c:1236
Date: Wed, 3 May 2017 19:28:29 -0700
Message-ID: <CA+55aFxyp5gpUZEYHXLwyhbK6DMWf4RoVykGxq9FPtO=j4yJsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36440 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754072AbdEDC2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 22:28:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So my Dell XPS 13 seems to have grown a new warning as of the
networking merge yesterday.

Things still work, but when it starts warning, it generates a *lot* of
noise (I got 36 of these within about ten minutes).

I have no idea what triggered it, because when I rebooted (not because
of this issue, but just to reboot into a newer kernel) I don't see it
again.

This is all pretty regular wireless - it's intel 8260 wireless in a
fairly normal laptop.

Things still seem to *work* ok, so the only problem here is the overly
verbose and useless WARN_ON. It doesn't even print out *which* rate it
is warning about, it just does that stupid unconditional WARN_ON()
without ever shutting up about it..

The WARN_ON() seems to be old, but my logs don't seem to have any
mention of this until today, so there's something that has changed
that now triggers it.

Ideas?

                  Linus

---

WARNING: CPU: 3 PID: 1138 at net/wireless/util.c:1236
cfg80211_calculate_bitrate+0x139/0x170 [cfg80211]
Modules linked in: rfcomm fuse ccm ip6t_rpfilter ip6t_REJECT
nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_broute bridge stp
llc ebtable_nat ip6table_security ip6table_mangle ip6table_nat nf_con
 snd_hda_codec iwlmvm irqbypass snd_hwdep snd_hda_core intel_cstate
mac80211 snd_seq intel_rapl_perf snd_seq_device snd_pcm iwlwifi
rtsx_pci_ms snd_timer cfg80211 memstick snd soundcore i2c_i801 shpchp
 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt
fb_sys_fops drm i2c_hid video
CPU: 3 PID: 1138 Comm: NetworkManager Tainted: G        W
4.11.0-06543-g2f34c1231bfc #60
Hardware name: Dell Inc. XPS 13 9350/09JHRY, BIOS 1.4.13 12/28/2016
task: ffff9c1d1bfcbb80 task.stack: ffffbb95c337c000
RIP: 0010:cfg80211_calculate_bitrate+0x139/0x170 [cfg80211]
RSP: 0018:ffffbb95c337f5b8 EFLAGS: 00010293
RAX: 0000000000000000 RBX: ffff9c1cb080cc00 RCX: 0000000000000000
RDX: 0000000000000005 RSI: 0000000000000002 RDI: ffffbb95c337f76e
RBP: ffffbb95c337f5b8 R08: 0000000000000004 R09: ffff9c1cc36fe0c4
R10: 00000000f7c00472 R11: ffffffffc0682000 R12: ffff9c1cc36fe0c0
R13: ffffbb95c337f76e R14: 0000000000000000 R15: ffff9c1cc36fe030
FS:  00007f000015f980(0000) GS:ffff9c1d3ed80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007ffd1ae62748 CR3: 0000000469f4f000 CR4: 00000000003406e0
Call Trace:
 nl80211_put_sta_rate+0x56/0x210 [cfg80211]
 nl80211_send_station.isra.63+0x639/0xd60 [cfg80211]
 nl80211_get_station+0x1e4/0x250 [cfg80211]
 genl_family_rcv_msg+0x1fa/0x3e0
 genl_rcv_msg+0x4c/0x90
 netlink_rcv_skb+0xde/0x110
 genl_rcv+0x28/0x40
 netlink_unicast+0x189/0x220
 netlink_sendmsg+0x2ba/0x3b0
 sock_sendmsg+0x38/0x50
 ___sys_sendmsg+0x2b6/0x2d0
 __sys_sendmsg+0x54/0x90
 SyS_sendmsg+0x12/0x20
 entry_SYSCALL_64_fastpath+0x13/0x94
RIP: 0033:0x7efffebf82fd
RSP: 002b:00007fff97d4af30 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007efffebf82fd
RDX: 0000000000000000 RSI: 00007fff97d4afc0 RDI: 0000000000000010
RBP: 00007fff97d4b070 R08: 0000000000000000 R09: 00007efffcc7b168
R10: 000055eb69e6d110 R11: 0000000000000293 R12: 00007fff97d4b0e0
R13: 0000000000000001 R14: 0000000000000000 R15: 000055eb68a32760
Code: 89 d0 f7 e1 d1 ea 8d 14 92 01 d2 81 c2 50 c3 00 00 b9 c5 5a 7c
0a c1 ea 05 89 d0 f7 e1 5d 89 d0 c1 e8 07 c3 31 c0 80 f9 02 74 b7 <0f>
ff 31 c0 eb b1 0f ff 31 c0 5d c3 0f ff 31 c0 5d c3 8d 04 40
