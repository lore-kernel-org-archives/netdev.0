From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 2.6.24] pasemi_mac: Fix reuse of free'd skb
Date: Tue, 04 Dec 2007 18:04:38 +0000
Message-ID: <1196791478.13978.359.camel@pmac.infradead.org>
References: <20071204033414.GA13616@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	ranger@gentoo.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45964 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755200AbXLDSEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 13:04:54 -0500
In-Reply-To: <20071204033414.GA13616@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oops: Exception in kernel mode, sig: 5 [#1]                                     
nfs: server pmac not responding, still trying                                   
SMP NR_CPUS=128 NUMA PA Semi PWRficient                                         
Modules linked in: appletouch cbc blkcipher dm_crypt dm_emc dm_round_robin dm_mu
ltipath dm_snapshot dm_mirror dm_zero dm_mod xfs jfs reiserfs lock_nolock gfs2 m
sdos linear raid10 raid456 async_memcpy async_tx async_xor xor raid1 raid0 sata_
mv libata pasemi_mac gpio_mdio libphy ehci_hcd ohci_hcd iscsi_tcp libiscsi scsi_
transport_iscsi sr_mod sd_mod scsi_mod ide_cd cdrom ipv6 ext2 ext4dev crc16 jbd2
 ext3 mbcache jbd squashfs loop nfs nfs_acl lockd sunrpc vfat fat cramfs        
NIP: c0000000003af2f0 LR: c0000000003af2ec CTR: c0000000000791c0                
REGS: c00000000ffff9c0 TRAP: 0700   Not tainted  (2.6.24-0.67.rc3.git7.fc9)     
MSR: 9000000000029032 <EE,ME,IR,DR>  CR: 24000028  XER: 00000000                
TASK = c000000000677720[0] 'swapper' THREAD: c000000000758000 CPU: 0            
GPR00: c0000000003af2ec c00000000ffffc40 c000000000753d98 0000000000000087      
GPR04: 0000000000000000 0000000000000000 0000000000000000 0000000000000000      
GPR08: c000000000677720 0000000000000000 0000000000000004 0000000000000000      
GPR12: 0000000000000000 c000000000678200 0000000000000000 0000000000000000      
GPR16: 0000000000000000 0000000000000000 0000000000000000 4000000001400000      
GPR20: 0000000000000040 00000000000006e0 00000000000006e8 0000000000000037      
GPR24: 0000000000000000 c00000003ba40370 00000000000000dc 540045ee0111a3a8      
GPR28: 00000000000005ee c00000003d104900 c000000000712b18 c00000003b939800      
NIP [c0000000003af2f0] .skb_over_panic+0x50/0x58                                
LR [c0000000003af2ec] .skb_over_panic+0x4c/0x58                                 
Call Trace:                                                                     
[c00000000ffffc40] [c0000000003af2ec] .skb_over_panic+0x4c/0x58 (unreliable)    
[c00000000ffffcd0] [d0000000002dfb10] .pasemi_mac_clean_rx+0x2f0/0x480 [pasemi_m
ac]                                                                             
[c00000000ffffda0] [d0000000002e008c] .pasemi_mac_poll+0x44/0xe4 [pasemi_mac]   
[c00000000ffffe40] [c0000000003bba54] .net_rx_action+0xf8/0x214                 
[c00000000ffffef0] [c00000000008eb58] .__do_softirq+0xa8/0x164                  
[c00000000fffff90] [c00000000002b468] .call_do_softirq+0x14/0x24                
[c00000000075b940] [c00000000000d4d0] .do_softirq+0x68/0xac                     
[c00000000075b9d0] [c00000000008ecc8] .irq_exit+0x60/0xb0                       
[c00000000075ba50] [c00000000000db00] .do_IRQ+0x174/0x1e8                       
[c00000000075baf0] [c000000000004c24] hardware_interrupt_entry+0x24/0x28        
--- Exception: 501 at .ppc64_runlatch_off+0x0/0x54                              
    LR = .cpu_idle+0x70/0x1f0                                                   
[c00000000075bde0] [c0000000000135c4] .cpu_idle+0x11c/0x1f0 (unreliable)        
[c00000000075be60] [c000000000009b08] .rest_init+0x78/0x90                      
[c00000000075bee0] [c0000000005c59ec] .start_kernel+0x3f8/0x41c                 
[c00000000075bf90] [c000000000008590] .start_here_common+0x60/0xd0              
Instruction dump:                                                               
80a30068 e8e300c8 e90300d0 812300bc 814300c0 2fa00000 409e0008 e81e8018         
e87e8028 f8010070 4bcd92cd 60000000 <0fe00000> 48000000 7c0802a6 faa1ffa8       
Kernel panic - not syncing: Fatal exception in interrupt                        
Rebooting in 180 seconds..

-- 
dwmw2

