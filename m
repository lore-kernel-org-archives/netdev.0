From: Ferenc =?utf-8?b?V8OhZ25lcg==?= <wferi@niif.hu>
Subject: Re: WARNING =?utf-8?b?KHNrYl9nc29fc2VnbWVudCk=?= with tg3+bridge in 2.6.27
Date: Thu, 7 May 2009 21:23:14 +0000 (UTC)
Message-ID: <loom.20090507T211235-698@post.gmane.org>
References: <20081011172002.GA12659@pest> <20081013.004226.171259546.davem@davemloft.net> <20081022074502.GA25058@gondor.apana.org.au> <20081022175704.GA25286@xw6200.broadcom.net> <20081023022001.GB304@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:46044 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbZEGXaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 19:30:04 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1M2D2R-0006Fw-F4
	for netdev@vger.kernel.org; Thu, 07 May 2009 23:30:03 +0000
Received: from tac.ki.iif.hu ([193.6.222.43])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 23:30:03 +0000
Received: from wferi by tac.ki.iif.hu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 23:30:03 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert <at> gondor.apana.org.au> writes:

> On Wed, Oct 22, 2008 at 10:57:04AM -0700, Matt Carlson wrote:
>
>> Looking at the dmesg output, I see that the tg3 device is a 5714.
>> NETIF_F_TSO6 should not be enabled for the 5714.  Why is the driver
>> getting an IPv6 TSO packet?
> 
> This might be caused by the bridge enabling TSO6 due to GSO
> being enabled on the underlying device which is a result of
> it supporting SG.

Hi,

Was this bug finally found and fixed?  I get the enclosed warnings with

eth0: Tigon3 [partno(BCM95701A10) rev 0105 PHY(5701)] (PCIX:133MHz:64-bit)
10/100/1000Base-T Ethernet 00:06:5b:f3:43:66
eth0: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] WireSpeed[1] TSOcap[0]
eth0: dma_rwctrl[76db000f] dma_mask[64-bit]

cards in active/backup bonding setup, without any bridging under
2.6.26-2-i686, the Debian Lenny stock kernel.  If if it was fixed, I
wonder if the fix could be perhaps backported to this kernel.  If not,
I'd like to help finding it.  I could get rid of them by turning of
GSO on both physical interfaces of the bond.
-- 
Thanks,
Feri.

WARNING: at net/core/dev.c:1451 skb_gso_segment+0x6b/0x14e()
Modules linked in: 8021q bonding nf_conntrack_tftp ipt_recent xt_multiport
ip6t_REJECT ipt_REJECT nf_conntrack_ipv6 nf_conntrack_ipv4 xt_state nf_conntrack
xt_tcpudp xt_comment ip6t_LOG ipt_LOG xt_limit ip6table_filter iptable_filter
ip6table_raw ip6_tables ipv6 iptable_raw ip_tables x_tables ext3 jbd mbcache
ipmi_devintf ipmi_si ipmi_msghandler loop psmouse evdev serio_raw snd_pcm
snd_timer snd soundcore snd_page_alloc pcspkr shpchp pci_hotplug button
i2c_piix4 i2c_core rocket sworks_agp agpgart dcdbas xfs dm_mirror dm_log
dm_snapshot dm_mod raid1 md_mod ide_cd_mod cdrom sg ata_generic sd_mod libata
dock serverworks aic7xxx scsi_transport_spi scsi_mod floppy ide_pci_generic tg3
ohci_hcd ide_core usbcore thermal processor fan thermal_sys [last unloaded:
scsi_wait_scan]
Pid: 3956, comm: exim4 Not tainted 2.6.26-2-686 #1
 [<c01225bb>] warn_on_slowpath+0x40/0x66
 [<f8b88d26>] tcp_packet+0x916/0x980 [nf_conntrack]
 [<c011d41d>] hrtick_set+0x8f/0xd8
 [<c0134f45>] atomic_notifier_call_chain+0x9/0xc
 [<f8b8941b>] nf_ct_deliver_cached_events+0x3b/0x96 [nf_conntrack]
 [<c0258766>] skb_gso_segment+0x6b/0x14e
 [<c0258a05>] dev_hard_start_xmit+0x1bc/0x24f
 [<c025ac1f>] dev_queue_xmit+0x20b/0x2bc
 [<c025f121>] neigh_resolve_output+0x1f1/0x21b
 [<f8b9762a>] ip6_output_finish+0x72/0xc7 [ipv6]
 [<f8b98733>] ip6_output+0xa57/0xa73 [ipv6]
 [<c026df90>] nf_iterate+0x30/0x61
 [<c026e01f>] nf_hook_slow+0x3a/0x90
 [<f8b9755c>] dst_output+0x0/0x7 [ipv6]
 [<f8b99ec8>] ip6_xmit+0x2c7/0x387 [ipv6]
 [<f8bb73e1>] inet6_csk_xmit+0x1e1/0x1f7 [ipv6]
 [<c0284e90>] tcp_transmit_skb+0x6a2/0x6d5
 [<c0285e1e>] tso_fragment+0xd5/0x10b
 [<c028645f>] __tcp_push_pending_frames+0x60b/0x6b2
 [<c027ca95>] tcp_sendmsg+0x7f5/0x8e3
 [<c024f188>] sock_sendmsg+0xc7/0xe1
 [<c013193c>] autoremove_wake_function+0x0/0x2d
 [<c0187568>] mnt_drop_write+0x1a/0xb4
 [<c01586be>] generic_file_aio_read+0x493/0x4da
 [<f8a48ebf>] xfs_iunlock+0x28/0x62 [xfs]
 [<c024fa63>] sys_sendto+0xfc/0x127
 [<f8a69d58>] xfs_file_aio_read+0x50/0x58 [xfs]
 [<c01742b2>] do_sync_read+0xbf/0xfe
 [<c01360ac>] getnstimeofday+0x37/0xbc
 [<c024faa7>] sys_send+0x19/0x1d
 [<c0250335>] sys_socketcall+0xed/0x19e
 [<c0103853>] sysenter_past_esp+0x78/0xb1
 [<c02b0000>] acpi_pci_root_add+0xe7/0x296
 =======================
---[ end trace 8437de2d68accdc8 ]---


