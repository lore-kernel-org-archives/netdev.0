From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Fwd: [Bug 42957] New: Kernel trap probably by malicious packet from torrent peer
Date: Sun, 18 Mar 2012 18:44:39 -0700 (PDT)
Message-ID: <852c3d7d-7aeb-411c-8239-a5c4052b93a2@tahiti.vyatta.com>
References: <bug-42957-100@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58377 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756248Ab2CSBon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 21:44:43 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 987D21410001
	for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 18:44:41 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id drDk8oQ+EcjY for <netdev@vger.kernel.org>;
	Sun, 18 Mar 2012 18:44:40 -0700 (PDT)
Received: from mail.vyatta.com (mail.vyatta.com [76.74.103.46])
	by mail.vyatta.com (Postfix) with ESMTP id EFC071410005
	for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 18:44:39 -0700 (PDT)
In-Reply-To: <bug-42957-100@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Forwarded Message -----
> https://bugzilla.kernel.org/show_bug.cgi?id=42957
> 
>            Summary: Kernel trap probably by malicious packet from
>            torrent
>                     peer
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 3.0.23
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: warpme@o2.pl
>         Regression: No
> 
> 
> Hi,
> 
> Last day I got 2 traps on otherwise (months of 24/7 uptime) stable
> server. I
> see correlation with launching torrent download (transmission
> client). Sys is
> 64-bit ArchLinux with 3.0.23 kernel. Log from trap is below. I submit
> this in
> IPv4 - but I'll appreciate if somebody will deduce from trap log
> proper
> category/kernel component involved/responsible this issue.
> 
> ------------[ cut here ]------------
> Mar 17 19:32:47 [98071.093459] WARNING: at net/ipv4/tcp_input.c:2999
> tcp_ack+0x1e34/0x2080()
> Mar 17 19:32:47 [98071.093461] Hardware name: GA-880GA-UD3H
> Mar 17 19:32:47 [98071.093462] Modules linked in: md5 dvbloopback
> nfsd exportfs
> nfs nfs_acl lockd auth_rpcgss fscache sunrpc xt_multiport xt_recent
> xt_state
> xt_tcpudp dvb_pll cx22702 stb6100 stv090x cx88_dvb videobuf_dvb
> cx88_vp3054_i2c
> dvb_core iptable_mangle rc_hauppauge iptable_nat nf_nat
> nf_conntrack_ipv4
> nf_defrag_ipv4 nf_conntrack iptable_filter ip_tables x_tables
> rc_tbs_nec
> appletalk ipx p8023 psnap p8022 llc snd_hda_codec_hdmi tuner cx8802
> cx8800
> cx88xx tveeprom btcx_risc videobuf_dma_sg videobuf_core v4l2_common
> videodev
> snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_page_alloc
> snd_timer snd
> radeon soundcore drm_kms_helper ttm drm ir_lirc_codec lirc_dev
> i2c_algo_bit
> ir_sony_decoder ir_jvc_decoder ir_rc6_decoder i2c_piix4 shpchp wmi
> pci_hotplug
> i2c_core ftdi_sio usbserial edac_mce_amd v4l2_compat_ioctl32
> ir_rc5_decoder
> media ir_nec_decoder rc_core sp5100_tco edac_core processor e1000e
> button r8169
> mii pcspkr evdev k10temp loop it87 hwmon_vid ipv6 autofs4 ext3
> mbcache jbd
> sd_mod pata_jmi
> Mar 17 19:32:47 cron pata_acpi ata_generic ahci libahci libata
> scsi_mod
> ohci_hcd ehci_hcd xhci_hcd usbcore
> Mar 17 19:32:47 [98071.093507] Pid: 0, comm: kworker/0:0 Tainted: G
>        W
> 3.0-ARCH #1
> Mar 17 19:32:47 [98071.093508] Call Trace:
> Mar 17 19:32:47 [98071.093509]  <IRQ>  [<ffffffff8105c8ff>]
> warn_slowpath_common+0x7f/0xc0
> Mar 17 19:32:47 [98071.093514]  [<ffffffff8105c95a>]
> warn_slowpath_null+0x1a/0x20
> Mar 17 19:32:47 [98071.093517]  [<ffffffff81380c74>]
> tcp_ack+0x1e34/0x2080
> Mar 17 19:32:47 [98071.093520]  [<ffffffffa026a1b7>] ?
> ipt_do_table+0x227/0x5b0
> [ip_tables]
> Mar 17 19:32:47 [98071.093523]  [<ffffffff81381d50>]
> tcp_rcv_established+0x280/0x830
> Mar 17 19:32:47 [98071.093525]  [<ffffffff81388d6f>]
> tcp_v4_do_rcv+0x10f/0x310
> Mar 17 19:32:47 [98071.093544]  [<ffffffff81348545>] ?
> sk_filter+0x95/0xd0
> Mar 17 19:32:47 [98071.093546]  [<ffffffff8138ae14>]
> tcp_v4_rcv+0x624/0x910
> Mar 17 19:32:47 [98071.093549]  [<ffffffff8136804d>]
> ip_local_deliver_finish+0xed/0x2b0
> Mar 17 19:32:47 [98071.093551]  [<ffffffff813683e0>]
> ip_local_deliver+0x90/0xa0
> Mar 17 19:32:47 [98071.093553]  [<ffffffff81367d21>]
> ip_rcv_finish+0x131/0x370
> Mar 17 19:32:47 [98071.093556]  [<ffffffff81368615>]
> ip_rcv+0x225/0x2f0
> Mar 17 19:32:47 [98071.093559]  [<ffffffff81334c1a>]
> __netif_receive_skb+0x30a/0x660
> Mar 17 19:32:47 [98071.093561]  [<ffffffff8133574d>]
> netif_receive_skb+0xad/0xc0
> Mar 17 19:32:47 [98071.093564]  [<ffffffff81336140>]
> napi_skb_finish+0x50/0x70
> Mar 17 19:32:47 [98071.093567]  [<ffffffff81336255>]
> napi_gro_receive+0xf5/0x140
> Mar 17 19:32:47 [98071.093572]  [<ffffffffa01c6dbb>]
> e1000_receive_skb+0x5b/0x70 [e1000e]
> Mar 17 19:32:47 [98071.093578]  [<ffffffffa01c8702>]
> e1000_clean_rx_irq+0x2c2/0x430 [e1000e]
> Mar 17 19:32:47 [98071.093581]  [<ffffffff8108404f>] ?
> hrtimer_interrupt+0x12f/0x210
> Mar 17 19:32:47 [98071.093586]  [<ffffffffa01c811f>]
> e1000_clean+0xaf/0x2b0
> [e1000e]
> Mar 17 19:32:47 [98071.093589]  [<ffffffff81335a29>]
> net_rx_action+0x149/0x300
> Mar 17 19:32:47 [98071.093592]  [<ffffffff81063f90>]
> __do_softirq+0xb0/0x270
> Mar 17 19:32:47 [98071.093594]  [<ffffffff813f875c>]
> call_softirq+0x1c/0x30
> Mar 17 19:32:47 [98071.093596]  [<ffffffff8100db25>]
> do_softirq+0x65/0xa0
> Mar 17 19:32:47 [98071.093598]  [<ffffffff8106449e>]
> irq_exit+0x9e/0xc0
> Mar 17 19:32:47 [98071.093600]  [<ffffffff813f8fb3>] do_IRQ+0x63/0xe0
> Mar 17 19:32:47 [98071.093603]  [<ffffffff813f6c93>]
> common_interrupt+0x13/0x13
> Mar 17 19:32:47 [98071.093604]  <EOI>  [<ffffffff81031e9b>] ?
> native_safe_halt+0xb/0x10
> Mar 17 19:32:47 [98071.093609]  [<ffffffff81014173>]
> default_idle+0x53/0x2a0
> Mar 17 19:32:47 [98071.093611]  [<ffffffff8101499a>]
> amd_e400_idle+0x9a/0x120
> Mar 17 19:32:47 [98071.093614]  [<ffffffff8100a21a>]
> cpu_idle+0xba/0x100
> Mar 17 19:32:47 [98071.093616]  [<ffffffff813e6169>]
> start_secondary+0x202/0x209
> Mar 17 19:32:47 [98071.093618] ---[ end trace 4fecd84b3e9e66ee ]---
> Mar 17 19:32:47 [98071.274828] ------------[ cut here ]------------
> 
> --
> Configure bugmail:
> https://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are the assignee for the bug.
> 
