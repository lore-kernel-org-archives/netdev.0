From: Jan 'yanek' Bortl <yanek@ya.bofh.cz>
Subject: PROBLEM: kernel lockup while changing TC rules
Date: Thu, 1 May 2008 17:49:14 +0200
Message-ID: <20080501145239.GA20284__27061.693944461$1209657574$gmane$org@atlantis.mitranet.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlantis.mitranet.cz ([62.240.190.34]:34933 "EHLO
	atlantis.mitranet.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758283AbYEAP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 11:58:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have found this problem with today's git (2.6.25-00000-ge4c576b) and 2.6.25:

Network configuration:

+--------+         vlan20 +---------+ vlan80
| laptop |----------------| router  |-----
+--------+                +---------+ 
laptop has address 192.168.243.10

Reproduce HOWTO:

1. run http://ya.bofh.cz/archive/kernel-2.6-htbcrash/init.sh
2. start packet generator on laptop (any traffic targetted to router's vlan80)
3. run http://ya.bofh.cz/archive/kernel-2.6-htbcrash/crash.sh

Then machine lockup and afterwhile print these messages:

[  395.137697] BUG: soft lockup - CPU#0 stuck for 61s! [ksoftirqd/0:4]
...
[  395.139871] Call Trace:
[  395.139940]  <IRQ>  [<ffffffff8035ea7c>] ? rb_insert_color+0xbc/0xf0
[  395.140012]  [<ffffffffa01f9cf6>] ? :sch_htb:htb_add_to_wait_tree+0xa6/0xc0
[  395.140061]  [<ffffffffa01fb46f>] ? :sch_htb:htb_dequeue+0x47f/0x7f0
[  395.140111]  [<ffffffffa01f9ec2>] ? :sch_htb:htb_activate_prios+0x122/0x140
[  395.140160]  [<ffffffff804682f6>] ? __qdisc_run+0x216/0x240
[  395.140207]  [<ffffffff804584e3>] ? dev_queue_xmit+0x2c3/0x390
[  395.140253]  [<ffffffff8047db07>] ? ip_finish_output+0x117/0x2a0
[  395.140300]  [<ffffffff8047dfe0>] ? ip_output+0x70/0xb0
[  395.140344]  [<ffffffff8047ac68>] ? ip_forward_finish+0x38/0x50

and

[  527.210416] BUG: soft lockup - CPU#1 stuck for 61s! [tc:2848]
...
[  527.212644] Call Trace:
[  527.212715]  [<ffffffff803617ff>] ? __delay+0xf/0x30
[  527.212759]  [<ffffffff80365a4c>] ? _raw_spin_lock+0x10c/0x180
[  527.212805]  [<ffffffff804d90a6>] ? _spin_lock_bh+0x56/0x70
[  527.212849]  [<ffffffff80467a3f>] ? qdisc_lock_tree+0x1f/0x30
[  527.212895]  [<ffffffffa0228bb4>] ? :sch_sfq:sfq_init+0xf4/0x240
[  527.212942]  [<ffffffff804693e4>] ? qdisc_create+0x154/0x250
[  527.212987]  [<ffffffff804710d3>] ? nla_parse+0x33/0xf0
[  527.213031]  [<ffffffff80469fd0>] ? tc_modify_qdisc+0x90/0x420
[  527.213079]  [<ffffffff804603d9>] ? rtnetlink_rcv_msg+0x1e9/0x230
[  527.213125]  [<ffffffff804601f0>] ? rtnetlink_rcv_msg+0x0/0x230

(full output here: http://ya.bofh.cz/archive/kernel-2.6-htbcrash/netconsole.txt)

kernel's config here: http://ya.bofh.cz/archive/kernel-2.6-htbcrash/config.txt
dmesg after boot here: http://ya.bofh.cz/archive/kernel-2.6-htbcrash/dmesg.txt

-- 
Jan 'yanek' Bortl <yanek [at] ya.bofh. cz>
http://ya.bofh.cz/ | jab: yanek [at] mitranet. cz
-----------------------------------------------------------------
"Maybe one day you will learn that your way is not the only way."
                                        Opher [StarGate: The Nox]
