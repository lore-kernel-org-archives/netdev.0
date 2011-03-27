From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Transmit queue timeouts in 8139cp driver
Date: Sun, 27 Mar 2011 10:43:48 -0700
Message-ID: <4D8F7754.8050609@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:38176 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753481Ab1C0Rn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 13:43:58 -0400
Received: from Philip-Prindevilles-MacBook-Pro.local (pool-71-111-146-59.ptldor.dsl-w.verizon.net [71.111.146.59])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.4/8.14.4) with ESMTP id p2RHhnRK016959
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 11:43:57 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running 2.6.37 right now (will migrate to 2.6.38 as soon as the squashfs fixes are ported) and seeing:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:258 dev_watchdog+0xe2/0x16a()
NETDEV WATCHDOG: eth0 (8139cp): transmit queue 0 timed out
Modules linked in: lm90 i2c_gpio i2c_algo_pcf i2c_algo_pca i2c_algo_bit i2c_dev
i2c_core uhci_hcd solos_pci cs5535_gpio 8139cp nf_nat_irc nf_conntrack_irc nf_na
t_ftp nf_conntrack_ftp ipt_MASQUERADE iptable_nat nf_nat xt_NOTRACK iptable_raw
xt_state nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack sata_via ehci_hcd l2tp_pp
p pppoe pppox pppoatm ipt_REJECT xt_TCPMSS ipt_LOG xt_comment xt_multiport xt_ma
c xt_limit iptable_mangle iptable_filter ip_tables xt_tcpudp x_tables nsc_gpio l
2tp_netlink l2tp_core ppp_mppe ppp_async ppp_generic slhc br2684 atm ath9k ath9k
_common ath9k_hw ath5k ath mac80211 usbcore nls_base crc_ccitt cfg80211 compat s
ha1_generic cryptosoft cryptodev(P) ocf(P) geode_aes arc4 aes_i586 aes_generic e
cb cryptomgr crypto_hash crypto_blkcipher aead crypto_algapi
Pid: 0, comm: swapper Tainted: P            2.6.37 #1
Call Trace:
  [<c101dd8f>] ? warn_slowpath_common+0x54/0x66
  [<c117349f>] ? dev_watchdog+0xe2/0x16a
  [<c101de09>] ? warn_slowpath_fmt+0x29/0x2d
  [<c117349f>] ? dev_watchdog+0xe2/0x16a
  [<c11733bd>] ? dev_watchdog+0x0/0x16a
  [<c1024c30>] ? run_timer_softirq+0xf5/0x15a
  [<c10218a2>] ? __do_softirq+0x57/0xc6
  [<c102184b>] ? __do_softirq+0x0/0xc6
  <IRQ>   [<c1003c77>] ? do_IRQ+0x71/0x83
  [<c1002b09>] ? common_interrupt+0x29/0x30
  [<c10074a6>] ? default_idle+0x27/0x3a
  [<c10014ab>] ? cpu_idle+0x19/0x2e
  [<c127561a>] ? start_kernel+0x256/0x25b
---[ end trace 5084f8f54e7e4cc5 ]---
8139cp 0000:00:0a.0: eth0: Transmit timeout, status  c   2b    0 80ff
8139cp 0000:00:0b.0: eth1: Transmit timeout, status  c   2b    0 80ff


Is this a known issue?

-Philip


