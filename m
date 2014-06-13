From: Ben Greear <greearb@candelatech.com>
Subject: Splat in hacked 3.14.6+ kernel.
Date: Fri, 13 Jun 2014 10:39:52 -0700
Message-ID: <539B3768.6080402@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:46710 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbaFMRjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 13:39:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is 3.14.6+ kernel with a fair bit of networking related patches
applied, so could be my fault.

The system has 3 ath9k NICs, one NIC in use with 200 station vdevs.

A script bounces the vdevs every 10 seconds or so.  TCP traffic is generated
on the interfaces if they manage to come up for any length of time.
This was left running over-night, and crashed with the splat below.

I'm mainly curious if anyone else has seen anything similar.

BUG: unable to handle kernel NULL pointer dereference at           (null)
IP: [<ffffffff810c1912>] pwq_dec_nr_in_flight+0x49/0xdd
PGD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: nfsv3 nfs_acl rpcsec_gss_krb5 auth_rpcgss oid_registry nfsv4 nfs lockd sunrpc fscache nf_conntrack_netlink nfnetlink nf_nat_ipv4 nf_nat 8021q
garp stp mrp llc macvlan wanlink(O) pktgen fuse ip6table_filter ip6_tables ebtable_nat ebtables coretemp hwmon ath9k ath9k_common snd_hda_codec_hdmi ath9k_hw
snd_hda_codec_realtek intel_rapl snd_hda_codec_generic ath x86_pkg_temp_thermal snd_hda_intel intel_powerclamp mac80211 kvm_intel snd_hda_codec kvm snd_hwdep
snd_seq snd_seq_device iTCO_wdt cfg80211 e1000e snd_pcm iTCO_vendor_support microcode snd_timer ptp serio_raw pps_core snd pcspkr soundcore i2c_i801 shpchp
lpc_ich uinput ipv6 i915 i2c_algo_bit drm_kms_helper drm i2c_core ata_generic pata_acpi video [last unloaded: iptable_nat]
CPU: 0 PID: 32199 Comm: kworker/u8:0 Tainted: G        WC O 3.14.6+ #39
Hardware name: To be filled by O.E.M. To be filled by O.E.M./HURONRIVER, BIOS 4.6.5 01/24/2013
task: ffff8801f047c980 ti: ffff8800bf05e000 task.ti: ffff8800bf05e000
RIP: 0010:[<ffffffff810c1912>]  [<ffffffff810c1912>] pwq_dec_nr_in_flight+0x49/0xdd
RSP: 0018:ffff8800bf05fe08  EFLAGS: 00010046
RAX: ffff8800bbea4408 RBX: ffff88021486ea00 RCX: 0000000000000000
RDX: ffff8800bbea4410 RSI: 0000000000000008 RDI: 0000000fffffffe0
RBP: ffff8800bf05fe18 R08: 0000000000000417 R09: 0000000000000000
R10: ffff8800bf05fd88 R11: ffff8800bf05fd98 R12: ffff88021700c800
R13: ffff88021486ea00 R14: 0000000000001000 R15: 0ffff88021486ea8
FS:  0000000000000000(0000) GS:ffff88021fa00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000b8 CR3: 0000000001a0c000 CR4: 00000000000407f0
Stack:
 ffff8801fc4d9f00 ffff88021700c800 ffff8800bf05fe68 ffffffff810c1c57
 ffff88021700c800 ffff8800d5530740 ffff88021700c800 ffff8801fc4d9f00
 ffff88021700c800 ffff8801fc4d9f30 ffff88021700cb80 ffff88021700c818
Call Trace:
 [<ffffffff810c1c57>] process_one_work+0x2b1/0x2c0
 [<ffffffff810c1dcf>] worker_thread+0x169/0x27e
 [<ffffffff810c1c66>] ? process_one_work+0x2c0/0x2c0
 [<ffffffff810c798a>] kthread+0xc9/0xd1
 [<ffffffff810c78c1>] ? kthread_freezable_should_stop+0x5b/0x5b
 [<ffffffff815c694c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810c78c1>] ? kthread_freezable_should_stop+0x5b/0x5b
Code: 8b 47 58 48 8b 57 60 ff c8 48 39 ca 89 47 58 74 6e 3b 47 5c 7d 69 48 8b 7a f8 31 c9 48 8d 42 f8 40 f6 c7 04 74 05 48 89 f9 30 c9 <4c> 8b 01 48 8b 78 08 4d
8d 60 18 48 83 ef 08 eb 32 4c 8b 50 10
RIP  [<ffffffff810c1912>] pwq_dec_nr_in_flight+0x49/0xdd
 RSP <ffff8800bf05fe08>
CR2: 0000000000000000
---[ end trace 61649a1ff64bf3fc ]---

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
