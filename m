From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: nl80211 NULL pointer dereference
Date: Tue, 18 Jun 2013 15:46:13 -1000
Message-ID: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:56753 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932860Ab3FSBqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 21:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hmm. Maybe this is old, but I don't think I've seen it before (who
knows, maybe it has killed the machine before, I had a hard hang the
other day).

It's a NULL pointer dereference in nl80211_set_reg() on my Pixel. The
machine kind of stayed up afterwards, although with no working
wireless, and it would not shut down cleanly presumably due to locks
held etc.

Any ideas? I'm including the few wireless-related messages that
happened justr before the oops. Being a pixel, this is with the ath9k
driver.

                     Linus

---
  wlp1s0: authenticate with 00:c0:23:ba:27:40
  wlp1s0: send auth to 00:c0:23:ba:27:40 (try 1/3)
  wlp1s0: authenticated
  ath9k 0000:01:00.0 wlp1s0: disabling HT as WMM/QoS is not supported by the AP
  ath9k 0000:01:00.0 wlp1s0: disabling VHT as WMM/QoS is not supported by the AP
  wlp1s0: associate with 00:c0:23:ba:27:40 (try 1/3)
  wlp1s0: RX AssocResp from 00:c0:23:ba:27:40 (capab=0x501 status=0 aid=4)
  wlp1s0: associated
  cfg80211: Calling CRDA for country: US

  BUG: unable to handle kernel NULL pointer dereference at           (null)
  IP: [<ffffffffa02a77d3>] nl80211_set_reg+0x113/0x2c0 [cfg80211]
  PGD 1459c3067 PUD 10f6fa067 PMD 0
  Oops: 0000 [#1] SMP
  Modules linked in: ftdi_sio tpm_tis tpm tpm_bios usb_storage fuse
ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast
ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT
nf_conntra
   media chromeos_laptop snd_timer snd microcode lpc_ich rfkill
soundcore mfd_core i2c_i801 uinput binfmt_misc dm_crypt i915
i2c_algo_bit drm_kms_helper drm crc32_pclmul crc32c_intel
ghash_clmulni_intel i2
  CPU: 1 PID: 4859 Comm: crda Not tainted 3.10.0-rc6 #2
  Hardware name: GOOGLE Link, BIOS          12/10/2012
  RIP: 0010:[<ffffffffa02a77d3>]  [<ffffffffa02a77d3>]
nl80211_set_reg+0x113/0x2c0 [cfg80211]
  RSP: 0018:ffff8801277779f0  EFLAGS: 00010202
  RAX: ffff8801456b0000 RBX: 0000000000000000 RCX: 0000000000000000
  RDX: 00000000000000c0 RSI: 0000000000000000 RDI: 0000000000000000
  RBP: ffff880127777a58 R08: 0000000000015d40 R09: ffff880141c8ecc0
  R10: ffffffffa02a779a R11: 0000000000000004 R12: 0000000000000000
  R13: ffff880141c8ecc0 R14: ffff88013af8d414 R15: ffff880127777a80
  FS:  00007f2c82fb5740(0000) GS:ffff88014f280000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 0000000000000000 CR3: 00000001459b2000 CR4: 00000000001407e0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
  Call Trace:
   [<ffffffff81531b44>] genl_family_rcv_msg+0x1f4/0x2e0
   [<ffffffff81531cc1>] genl_rcv_msg+0x91/0xd0
   [<ffffffff81531339>] netlink_rcv_skb+0xa9/0xc0
   [<ffffffff81531758>] genl_rcv+0x28/0x40
   [<ffffffff81530d62>] netlink_unicast+0x142/0x1f0
   [<ffffffff815310ad>] netlink_sendmsg+0x29d/0x370
   [<ffffffff814f22e9>] sock_sendmsg+0x99/0xd0
   [<ffffffff814f270e>] ___sys_sendmsg+0x39e/0x3b0
   [<ffffffff814f34f2>] __sys_sendmsg+0x42/0x80
   [<ffffffff814f3542>] SyS_sendmsg+0x12/0x20
   [<ffffffff81615e42>] system_call_fastpath+0x16/0x1b
  Code: 60 10 41 0f b6 46 04 0f b6 fb 41 88 45 14 41 0f b6 46 05 41 88
45 15 e8 8c c5 fe ff 84 c0 75 68 49 8b 47 20 4c 8b a0 10 01 00 00 <45>
0f b7 34 24 41 83 ee 04 41 83 fe 03 7e 0e 41 0f b7 44 24 04
  RIP  [<ffffffffa02a77d3>] nl80211_set_reg+0x113/0x2c0 [cfg80211]
   RSP <ffff8801277779f0>
  CR2: 0000000000000000
