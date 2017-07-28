From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: [v4.12 regression] netns: NULL deref in fib_sync_down_dev()
Date: Fri, 28 Jul 2017 18:00:47 +0200
Message-ID: <20170728160047.7tzapklj7zrgxktq@qmqm.qmqm.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k5cbeotui5alz4jb"
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([91.227.64.183]:49764 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751943AbdG1QAu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 12:00:50 -0400
Received: from remote.user (localhost [127.0.0.1])
        by rere.qmqm.pl (Postfix) with ESMTPSA id 4475950
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 18:00:49 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k5cbeotui5alz4jb
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Dear NetDevs,

Before I go to bisecting, have you seen a following NULL dereference,
yet?  Where should I start looking?  It is triggered by deleting netns
(cut-down script attached - triggers every time).  This was working
correctly under v4.11.x.

Best Regards,
Micha³ Miros³aw

--k5cbeotui5alz4jb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=XXX-BUG-linux-netns

[1097925.958758] eth0: renamed from tve0x
[1097926.012266] IPv6: ADDRCONF(NETDEV_UP): tve0: link is not ready
[1097926.035396] IPv6: ADDRCONF(NETDEV_CHANGE): tve0: link becomes ready
[1097926.709371] ip6_tables: (C) 2000-2006 Netfilter Core Team
[1097929.961977] BUG: unable to handle kernel NULL pointer dereference at 0000000000000138
[1097929.961983] IP: fib_sync_down_dev+0x19a/0x230
[1097929.961983] PGD 0
[1097929.961984] P4D 0
[1097929.961986] Oops: 0000 [#1] PREEMPT SMP
[1097929.961987] Modules linked in: ip6table_mangle ip6_tables xt_tcpudp iptable_mangle xt_TPROXY nf_defrag_ipv6 veth nvidia_uvm(PO) cpuid cdc_ether cdc_subset usbnet mii pci_stub vboxpci(O) vboxnetadp(O) vboxnetflt(O) vboxdrv(O) tun xt_REDIRECT nf_nat_redirect cdc_acm ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge stp llc rfcomm snd_emu10k1_synth snd_emux_synth snd_seq_midi_emul snd_seq_virmidi snd_hrtimer snd_seq_midi snd_seq_midi_event snd_seq xfrm_user iptable_filter xfrm4_tunnel tunnel4 ipcomp xfrm_ipcomp esp4 ah4 af_key xfrm_algo cpufreq_powersave cpufreq_userspace cpufreq_conservative nfc fuse bnep binfmt_misc xfs snd_hda_codec_hdmi mxm_wmi btusb btrtl btbcm btintel bluetooth intel_powerclamp snd_hda_codec_re
 altek snd_hda_codec_generic
[1097929.962009]  kvm_intel snd_hda_intel pl2303 snd_emu10k1 usbserial input_leds ecdh_generic snd_hda_codec kvm snd_util_mem snd_hda_core snd_ac97_codec ac97_bus snd_rawmidi snd_seq_device snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd irqbypass sg pcspkr soundcore emu10k1_gp gameport iTCO_wdt wmi video nvidia_drm(PO) drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm nvidia_modeset(PO) nvidia(PO) nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc loop firewire_sbp2 firewire_core crc_itu_t ecryptfs ip_tables x_tables autofs4 algif_skcipher af_alg sr_mod cdrom raid10 raid0 multipath linear raid456 async_raid6_recov async_memcpy async_pq uas usb_storage raid6_pq async_xor xor async_tx libcrc32c crc32c_intel ghash_clmulni_intel i2c_i801 i2c_core xhci_pci xhci_h
 cd e1000e
[1097929.962034] CPU: 2 PID: 28976 Comm: kworker/u16:2 Tainted: P           O    4.12.2mq+ #204
[1097929.962035] Hardware name: System manufacturer System Product Name/P8Z68-V PRO, BIOS 3603 11/09/2012
[1097929.962037] Workqueue: netns cleanup_net
[1097929.962038] task: ffff8804078ae600 task.stack: ffffc90003b0c000
[1097929.962039] RIP: 0010:fib_sync_down_dev+0x19a/0x230
[1097929.962040] RSP: 0018:ffffc90003b0fc80 EFLAGS: 00010206
[1097929.962041] RAX: 0000000000000011 RBX: ffff880005b70570 RCX: 0000000000000000
[1097929.962042] RDX: 0000000000000000 RSI: 00000000000000ff RDI: 0000000000000000
[1097929.962043] RBP: 0000000000000000 R08: 00000000ffffffff R09: 0000000000000000
[1097929.962044] R10: ffffc90003b0fd10 R11: 0000000000000c79 R12: ffff880005b70500
[1097929.962044] R13: 0000000000000006 R14: ffff880005b70570 R15: ffff880405bc5000
[1097929.962045] FS:  0000000000000000(0000) GS:ffff88041ec80000(0000) knlGS:0000000000000000
[1097929.962046] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[1097929.962047] CR2: 0000000000000138 CR3: 0000000001c09000 CR4: 00000000000406e0
[1097929.962047] Call Trace:
[1097929.962050]  ? fib_disable_ip+0xc/0x40
[1097929.962051]  ? fib_netdev_event+0xe8/0x110
[1097929.962053]  ? notifier_call_chain+0x40/0x60
[1097929.962054]  ? rollback_registered_many+0x2b6/0x400
[1097929.962056]  ? unregister_netdevice_many+0x15/0xa0
[1097929.962057]  ? default_device_exit_batch+0x13c/0x170
[1097929.962059]  ? do_wait_intr_irq+0x80/0x80
[1097929.962061]  ? cleanup_net+0x1d0/0x2c0
[1097929.962062]  ? process_one_work+0x1d2/0x3e0
[1097929.962064]  ? worker_thread+0x42/0x3d0
[1097929.962065]  ? kthread+0xf7/0x130
[1097929.962067]  ? trace_event_raw_event_workqueue_work+0xa0/0xa0
[1097929.962068]  ? kthread_create_on_node+0x60/0x60
[1097929.962069]  ? do_group_exit+0x35/0xa0
[1097929.962070]  ? ret_from_fork+0x22/0x30
[1097929.962071] Code: 39 f0 74 77 49 83 fd 04 74 69 49 83 fd 06 74 60 49 83 fd 02 74 5a 49 8b 97 d8 02 00 00 48 89 5c 24 18 48 c7 44 24 10 00 00 00 00 <8b> 92 38 01 00 00 85 d2 74 04 a8 10 75 08 a8 01 0f 84 12 ff ff
[1097929.962085] RIP: fib_sync_down_dev+0x19a/0x230 RSP: ffffc90003b0fc80
[1097929.962086] CR2: 0000000000000138
[1097929.962087] ---[ end trace 07d937abbfe4921d ]---

--k5cbeotui5alz4jb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=net-test

#!/bin/bash

trap cleanup EXIT
cleanup() {
	ip netns del test
	ip link del tve0
}

ip netns add test || exit 1
ip link add name tve0 type veth peer name tve0x
ip link set tve0x netns test
ip netns exec test ip link set tve0x name eth0

ip link set tve0 up
ip addr add 10.22.0.1/24 dev tve0
ip route add 10.23.0.0/16 via 10.22.0.2

ip netns exec test ip link set eth0 up
ip netns exec test ip addr add 10.22.0.2/24 dev eth0
ip netns exec test ip route add default via 10.22.0.1 dev eth0
ip netns exec test sysctl net.ipv4.conf.all.forwarding=1

ip netns exec test ip rule add fwmark 1/1 table 1
ip netns exec test ip route add local default dev lo table 1
sleep 1

--k5cbeotui5alz4jb--
