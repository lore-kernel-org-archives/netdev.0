From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Seeing transmit timeouts on 8139cp
Date: Thu, 16 Sep 2010 22:10:43 -0700
Message-ID: <4C92F853.8050701@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:59942 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750860Ab0IQFKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 01:10:51 -0400
Received: from macbook.redfish-solutions.com (71-34-122-182.ptld.qwest.net [71.34.122.182])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id o8H5AhxU019120
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 23:10:50 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  I know that 2.6.27.49 isn't particularly recent, but we have toolchain issues stopping us from jumping to 2.6.33.

That said, if there's a simple fix or two for this, we're happy to backport it, but I wasn't able to track it down.

Does this look familiar to anyone?

Thanks.


------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xf1/0x176()
NETDEV WATCHDOG: eth1 (8139cp): transmit timed out
Modules linked in: lm90 hwmon i2c_core binfmt_misc aes_i586 aes_generic xt_tcpud
p ipt_MASQUERADE iptable_nat nf_nat_ftp nf_nat nf_conntrack_ipv4 xt_TCPMSS ipt_L
OG ipt_REJECT iptable_mangle iptable_filter xt_multiport xt_state xt_limit xt_co
nntrack nf_conntrack_ftp nf_conntrack ip_tables x_tables pppoatm pppox ppp_gener
ic slhc bridge stp llc solos_pci atm dummy ath5k mac80211 ath cfg80211 rfkill_ba
ckport compat dahdi sha512_generic sha256_generic deflate zlib_deflate arc4 ecb
sha1_generic blowfish des_generic cbc cryptosoft cryptodev(P) ocf(P) geodewdt ge
ode_rng geode_aes crypto_blkcipher 8139cp rtc cs5535_gpio
Pid: 0, comm: swapper Tainted: P          2.6.27.49-astlinux #1
  [<c0115462>] warn_slowpath+0x61/0x84
  [<e0157fa3>] minstrel_get_rate+0x23/0x418 [mac80211]
  [<c01261bc>] enqueue_hrtimer+0xce/0xd9
  [<c01124fd>] __enqueue_rt_entity+0xab/0xc8
  [<c011256d>] enqueue_task_rt+0x2d/0x3e
  [<c01065e8>] read_tsc+0x6/0x22
  [<c012899e>] getnstimeofday+0x4a/0xc7
  [<c01267c2>] ktime_get_ts+0x1d/0x3f
  [<c01065e8>] read_tsc+0x6/0x22
  [<c012899e>] getnstimeofday+0x4a/0xc7
  [<c025df4b>] dev_watchdog+0x0/0x176
  [<c01cfa0f>] strlcpy+0x15/0x62
  [<c025e03c>] dev_watchdog+0xf1/0x176
  [<c012ad9e>] tick_dev_program_event+0x1e/0x80
  [<c012ae3f>] tick_program_event+0xf/0x11
  [<c0126b84>] hrtimer_interrupt+0x123/0x14b
  [<c011c052>] run_timer_softirq+0x116/0x17a
  [<c0118cdc>] __do_softirq+0x35/0x75
  [<c0118d3e>] do_softirq+0x22/0x26
  [<c0118f18>] irq_exit+0x25/0x30
  [<c010477c>] do_IRQ+0x4d/0x5d
  [<c010394b>] common_interrupt+0x23/0x28
  [<c0106f3d>] default_idle+0x25/0x38
  [<c010254b>] cpu_idle+0x37/0x5f
  =======================
---[ end trace a7debcd6fdb2db97 ]---
eth1: Transmit timeout, status  c   2b    0 80ff
------------[ cut here ]------------
WARNING: at kernel/softirq.c:136 local_bh_enable+0x2f/0x76()
Modules linked in: lm90 hwmon i2c_core binfmt_misc aes_i586 aes_generic xt_tcpud
p ipt_MASQUERADE iptable_nat nf_nat_ftp nf_nat nf_conntrack_ipv4 xt_TCPMSS ipt_L
OG ipt_REJECT iptable_mangle iptable_filter xt_multiport xt_state xt_limit xt_co
nntrack nf_conntrack_ftp nf_conntrack ip_tables x_tables pppoatm pppox ppp_gener
ic slhc bridge stp llc solos_pci atm dummy ath5k mac80211 ath cfg80211 rfkill_ba
ckport compat dahdi sha512_generic sha256_generic deflate zlib_deflate arc4 ecb
sha1_generic blowfish des_generic cbc cryptosoft cryptodev(P) ocf(P) geodewdt ge
ode_rng geode_aes crypto_blkcipher 8139cp rtc cs5535_gpio
Pid: 0, comm: swapper Tainted: P        W 2.6.27.49-astlinux #1
  [<c01153de>] warn_on_slowpath+0x40/0x63
  [<c0115cfb>] printk+0x14/0x18
  [<c01150ab>] print_oops_end_marker+0x1b/0x1f
  [<c0115467>] warn_slowpath+0x66/0x84
  [<c014d80e>] free_block+0xb3/0xef
  [<c02aa0e1>] __atomic_notifier_call_chain+0x19/0x36
  [<c011915d>] local_bh_enable+0x2f/0x76
  [<e0194f8a>] destroy_conntrack+0xb8/0xd7 [nf_conntrack]
  [<c0266262>] nf_conntrack_destroy+0x1e/0x34
  [<c024da41>] skb_release_all+0x80/0xbd
  [<c024da9c>] __kfree_skb+0x8/0x61
  [<e0015589>] cp_clean_rings+0xbb/0xf8 [8139cp]
  [<e0016b58>] cp_tx_timeout+0x6b/0xca [8139cp]
  [<c025df4b>] dev_watchdog+0x0/0x176
  [<c025e051>] dev_watchdog+0x106/0x176
  [<c012ad9e>] tick_dev_program_event+0x1e/0x80
  [<c012ae3f>] tick_program_event+0xf/0x11
  [<c0126b84>] hrtimer_interrupt+0x123/0x14b
  [<c011c052>] run_timer_softirq+0x116/0x17a
  [<c0118cdc>] __do_softirq+0x35/0x75
  [<c0118d3e>] do_softirq+0x22/0x26
  [<c0118f18>] irq_exit+0x25/0x30
  [<c010477c>] do_IRQ+0x4d/0x5d
  [<c010394b>] common_interrupt+0x23/0x28
  [<c0106f3d>] default_idle+0x25/0x38
  [<c010254b>] cpu_idle+0x37/0x5f
  =======================
---[ end trace a7debcd6fdb2db97 ]---


