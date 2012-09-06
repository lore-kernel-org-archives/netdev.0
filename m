From: Dave Jones <davej@redhat.com>
Subject: WARNING: at net/ipv4/tcp.c:1303 tcp_cleanup_rbuf+0x54/0x120()
Date: Thu, 6 Sep 2012 11:32:40 -0400
Message-ID: <20120906153240.GA25087@redhat.com>
References: <bug-854367-176318@bugzilla.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55871 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752158Ab2IFPcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 11:32:43 -0400
Content-Disposition: inline
In-Reply-To: <bug-854367-176318@bugzilla.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've had about 20 reports of this bug in the last 2 days. 
No idea why it only just started showing up, but it may coincide with
users updating from 3.4->3.5 when we pushed an update.

Seems to be affecting multiple different network drivers.
(The original trace is a 'crap' driver from staging, but there are
 reports from e1000e and iwlwifi for eg)

 > https://bugzilla.redhat.com/show_bug.cgi?id=854367
 > 
 > backtrace:
 > :WARNING: at net/ipv4/tcp.c:1303 tcp_cleanup_rbuf+0x54/0x120()
 > :Hardware name: GA-MA785GM-US2H
 > :cleanup rbuf bug: copied A48FD80 seq A48FD80 rcvnxt A48FD80
 > :Modules linked in: fuse ebtable_nat ebtables ipt_MASQUERADE
 > nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle ip6t_REJECT
 > nf_conntrack_ipv6 nf_defrag_ipv6 lockd ip6table_filter sunrpc ip6_tables
 > iptable_nat nf_nat rfcomm iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 bnep
 > xt_conntrack nf_conntrack binfmt_misc btusb bluetooth snd_hda_codec_hdmi
 > snd_hda_codec_realtek snd_hda_intel joydev r8712u(C) snd_hda_codec rfkill
 > snd_hwdep shpchp sp5100_tco r8169 mii serio_raw snd_pcm snd_page_alloc
 > snd_timer snd soundcore i2c_piix4 edac_core edac_mce_amd ppdev parport_pc
 > parport microcode k10temp vhost_net tun macvtap macvlan kvm_amd kvm uinput
 > ata_generic pata_acpi firewire_ohci firewire_core crc_itu_t pata_atiixp wmi
 > usb_storage radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded:
 > scsi_wait_scan]
 > :Pid: 2241, comm: Chrome_IOThread Tainted: G         C   3.5.3-1.fc17.x86_64 #1
 > :Call Trace:
 > : [<ffffffff810584bf>] warn_slowpath_common+0x7f/0xc0
 > : [<ffffffff810585b6>] warn_slowpath_fmt+0x46/0x50
 > : [<ffffffff815443c4>] tcp_cleanup_rbuf+0x54/0x120
 > : [<ffffffff8154564c>] tcp_recvmsg+0x76c/0xd30
 > : [<ffffffff81569c1b>] inet_recvmsg+0x6b/0x80
 > : [<ffffffff814e7612>] sock_aio_read.part.9+0x142/0x170
 > : [<ffffffff814e7665>] sock_aio_read+0x25/0x40
 > : [<ffffffff81187a06>] do_sync_read+0xe6/0x120
 > : [<ffffffff8127948a>] ? inode_has_perm.isra.31.constprop.61+0x2a/0x30
 > : [<ffffffff812764d2>] ? security_file_permission+0x92/0xb0
 > : [<ffffffff81187ea1>] ? rw_verify_area+0x61/0xf0
 > : [<ffffffff811883ed>] vfs_read+0x15d/0x180
 > : [<ffffffff8118845a>] sys_read+0x4a/0x90
 > : [<ffffffff81614ae9>] system_call_fastpath+0x16/0x1b

Could this be related to the "recvmsg bug" WARN's we've also been seeing recently ?

	Dave
