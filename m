From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: eth4 received packet on queue 4, but number of RX queues is 4
Date: Wed, 22 Jun 2011 10:34:25 -0500
Message-ID: <20110622153425.GA2176@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:34649 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757922Ab1FVPef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 11:34:35 -0400
Received: by gwb1 with SMTP id 1so602786gwb.22
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2011 08:34:34 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just booted up 3.0.0-rc4+ and got the following trace in the logs:

cxgb3 0000:04:00.0: found old FW minor version(7.4), driver compiled for version 7.10
cxgb3 0000:04:00.0: successful upgrade to firmware 7.10.0
cxgb3 0000:04:00.0: FW upgrade to 7.10.0 succeeded
eth4: link up, 10Gbps, full-duplex
eth4: link down
------------[ cut here ]------------
WARNING: at net/core/dev.c:2656 get_rps_cpu+0x1d1/0x350()
Hardware name: PowerEdge R610
eth4 received packet on queue 4, but number of RX queues is 4
Modules linked in: fuse ext3 jbd mbcache dm_mirror dm_multipath scsi_dh video sbs sbshc acpi_pad acpi_ipmi ipmi_msghandler parport_pc lp parport sg ses enclosure joydev cxgb3 mdio bnx2 iTCO_wdt iTCO_vendor_support serio_raw snd_pcm snd_timer snd soundcore snd_page_alloc dcdbas pcspkr dm_region_hash dm_log dm_mod shpchp megaraid_sas sd_mod scsi_mod crc_t10dif xfs exportfs uhci_hcd ohci_hcd ssb mmc_core ehci_hcd [last unloaded: microcode]
Pid: 0, comm: swapper Not tainted 3.0.0-rc4+ #25
Call Trace:
 <IRQ>  [<ffffffff8104e94f>] warn_slowpath_common+0x7f/0xc0
 [<ffffffff811da090>] ? timerqueue_add+0x60/0xb0
 [<ffffffff8104ea46>] warn_slowpath_fmt+0x46/0x50
 [<ffffffff813499e1>] get_rps_cpu+0x1d1/0x350
 [<ffffffff81073c8b>] ? hrtimer_interrupt+0x13b/0x230
 [<ffffffff81349b95>] netif_receive_skb+0x35/0x90
 [<ffffffffa026c6af>] process_responses+0x62f/0x1580 [cxgb3]
 [<ffffffff81075d55>] ? sched_clock_cpu+0xc5/0x100
 [<ffffffffa026d63c>] napi_rx_handler+0x3c/0x90 [cxgb3]
 [<ffffffff8134a3b7>] net_rx_action+0xe7/0x230
 [<ffffffff81055182>] __do_softirq+0xb2/0x1f0
 [<ffffffff81408cac>] call_softirq+0x1c/0x30
 [<ffffffff81004295>] do_softirq+0x55/0x90
 [<ffffffff81054fa5>] irq_exit+0x65/0x70
 [<ffffffff81409236>] do_IRQ+0x66/0xe0
 [<ffffffff81400513>] common_interrupt+0x13/0x13
 <EOI>  [<ffffffff8122c69b>] ? intel_idle+0xbb/0x110
 [<ffffffff8122c67e>] ? intel_idle+0x9e/0x110
 [<ffffffff813147fc>] cpuidle_idle_call+0xbc/0x240
 [<ffffffff81001ee9>] cpu_idle+0xa9/0xf0
 [<ffffffff813e85e2>] rest_init+0x72/0x80
 [<ffffffff81942cf4>] start_kernel+0x3a1/0x3ac
 [<ffffffff81942321>] x86_64_start_reservations+0x131/0x135
 [<ffffffff81942412>] x86_64_start_kernel+0xed/0xf4
---[ end trace 741fa1dbbcf6aa7b ]---
eth4: link up, 10Gbps, full-duplex
802.1Q VLAN Support v1.8


$ sudo /usr/sbin/ethtool -i eth4
driver: cxgb3
version: 1.1.4-ko
firmware-version: T 7.10.0 TP 1.1.0
bus-info: 0000:04:00.0


$ /sbin/lspci | grep 04:00.0
04:00.0 Ethernet controller: Chelsio Communications Inc S320-LP-CR 10GbE Dual Port Adapter


Thanks,
Shawn


---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

