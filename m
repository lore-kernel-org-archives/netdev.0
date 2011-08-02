From: Dave Jones <davej@redhat.com>
Subject: return of ip_rt_bug()
Date: Tue, 2 Aug 2011 13:09:42 -0400
Message-ID: <20110802170942.GA17164@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom London <selinux@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753927Ab1HBRJp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 13:09:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom (CC'd) has been hitting that ip_rt_bug() WARN_ON() since 3.0rc

Here's the latest report.

------------[ cut here]------------
WARNING: atnet/ipv4/route.c:1714 ip_rt_bug+0x5c/0x62()
Hardware name: 74585FU
Modules linked in: fuse
ip6table_filter ip6_tables ebtable_nat ebtables ppdev parport_pc lp parport
ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state
nf_conntrack xt_CHECKSUM iptable_mangle tun bridge stp llc sunrpc rfcomm bnep
usblp arc4 uvcvideo videodev media snd_usb_audio snd_usbmidi_lib snd_rawmidi
v4l2_compat_ioctl32 iwlagn microcode i2c_i801 btusb iTCO_wdt
iTCO_vendor_support mac80211 bluetooth snd_hda_codec_conexant cfg80211
thinkpad_acpi snd_hda_intel snd_hda_codec rfkill snd_hwdep snd_seq
snd_seq_device snd_pcm snd_timer snd soundcore snd_page_alloc e1000e virtio_net
kvm_intel kvm uinput wmi i915 drm_kms_helper drm i2c_algo_bit i2c_core video[last unloaded: scsi_wait_scan]
Pid: 5492, comm: xsane Not tainted 3.1.0-0.rc0.git12.1.fc17.x86_64 #1
Call Trace:
 [<ffffffff8105c5ec>] warn_slowpath_common+0x83/0x9b
 [<ffffffff8105c61e>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff8142f485>] ip_rt_bug+0x5c/0x62
 [<ffffffff81437091>] dst_output+0x19/0x1d
 [<ffffffff814387c0>] ip_local_out+0x20/0x25
 [<ffffffff81439695>] ip_send_skb+0x19/0x3e
 [<ffffffff81455ea2>] udp_send_skb+0x239/0x29b
 [<ffffffff8145763f>] udp_sendmsg+0x5a1/0x7d4
 [<ffffffff813f67d5>] ? release_sock+0x35/0x155
 [<ffffffff8143718c>] ? ip_select_ident+0x3d/0x3d
 [<ffffffff81062703>] ? local_bh_enable_ip+0xe/0x10
 [<ffffffff814f1231>] ? _raw_spin_unlock_bh+0x40/0x44
 [<ffffffff813f68ec>] ? release_sock+0x14c/0x155
 [<ffffffff8145eb58>] inet_sendmsg+0x66/0x6f
 [<ffffffff813f1d92>] sock_sendmsg+0xe6/0x109
 [<ffffffff8108f1c8>] ? lock_acquire+0x10f/0x13e
 [<ffffffff8110dd34>] ? might_fault+0x5c/0xac
 [<ffffffff8108f08c>] ? lock_release+0x1a4/0x1d1
 [<ffffffff8110dd7d>] ? might_fault+0xa5/0xac
 [<ffffffff813f2ad7>] ? copy_from_user+0x2f/0x31
 [<ffffffff813f496d>] sys_sendto+0x132/0x174
 [<ffffffff8124ef6e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff814f80c2>] system_call_fastpath+0x16/0x1b
---[ end trace 0e82aef47f8d8552 ]---
------------[ cut here ]------------

all the traces he's hit so far seem to be caused by udp, and they all seem to be
going from 192.168.2.5 -> 255.255.255.255

https://bugzilla.redhat.com/show_bug.cgi?id=712632 is his full report with similar traces.

	Dave

