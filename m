From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Interfamily beet crashes
Date: Fri, 18 Jul 2008 12:47:15 +0300
Message-ID: <200807181247.15933.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:41099 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753698AbYGRKHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 06:07:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just tried out the new kernel version, and it seems it still crashes on 4
inner-6 outer interfamily beet the way it is right now. Here's a trace (I set up
a state manually and try pinging the other host): 

Jul 18 11:36:12 burg kernel: ------------[ cut here ]------------
Jul 18 11:36:12 burg kernel: kernel BUG at net/core/skbuff.c:2445!
Jul 18 11:36:12 burg kernel: invalid opcode: 0000 [#1] PREEMPT
Jul 18 11:36:12 burg kernel: Modules linked in: radeon drm rfcomm l2cap binfmt_misc ppdev lp cpufreq_userspace cpufreq_conservative 
cpufreq_powersave cpufreq_ondemand ipt_TTL ipt_ttl ipt_REDIRECT ipt_recent ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_addrtype 
nf_nat_tftp nf_nat_snmp_basic nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp 
nf_conntrack_amanda nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre 
nf_conntrack_netbios_ns nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_tcpmss xt_pkttype xt_mark xt_mac xt_limit xt_length 
xt_helper xt_hashlimit xt_dccp xt_conntrack xt_CONNMARK xt_connmark xt_state iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nls_cp437 
loop hci_usb bluetooth 8250_pci irtty_sir sir_dev irda 8250_pnp crc_ccitt snd_intel8x0m snd_pcm_oss snd_mixer_oss 8250 serial_core 
floppy parport_pc parport snd_intel8x0 snd_ac97_codec ipw2100 ac97_bus ieee80211 snd_pcm snd_timer uhci_hcd ehci_hcd s
Jul 18 11:36:12 burg kernel: d soundcore ieee80211_crypt e1000 snd_page_alloc ide_cd_mod i2c_i801 cdrom usbcore video output evdev
Jul 18 11:36:12 burg kernel:
Jul 18 11:36:12 burg kernel: Pid: 6559, comm: ping Not tainted (2.6.26 #1)
Jul 18 11:36:12 burg kernel: EIP: 0060:[<c03d890f>] EFLAGS: 00010206 CPU: 0
Jul 18 11:36:12 burg kernel: EIP is at __skb_to_sgvec+0x27f/0x290
Jul 18 11:36:12 burg kernel: EAX: dde25b44 EBX: 00000248 ECX: de7fd5c0 EDX: 00000000
Jul 18 11:36:12 burg kernel: ESI: 00000014 EDI: 00000078 EBP: 00000078 ESP: de7c7bd0
Jul 18 11:36:12 burg kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
Jul 18 11:36:12 burg kernel: Process ping (pid: 6559, ti=de7c6000 task=df8c2b10 task.ti=de7c6000)
Jul 18 11:36:12 burg kernel: Stack: c0439207 0300a8c1 0200a8c1 00000000 00000000 00000000 dde25b44 de7fd5c0
Jul 18 11:36:12 burg kernel:        de7fd5c0 000012e4 00000001 00000001 00000000 ded78000 00000000 dde25b44
Jul 18 11:36:12 burg kernel:        de7fd5e0 ddca5240 de7fd5c0 c03d8934 00000054 ddca5238 c047c41d 00000054
Jul 18 11:36:12 burg kernel: Call Trace:
Jul 18 11:36:12 burg kernel:  [<c0439207>] ipt_do_table+0x1e7/0x330
Jul 18 11:36:12 burg kernel:  [<c03d8934>] skb_to_sgvec+0x14/0x30
Jul 18 11:36:12 burg kernel:  [<c047c41d>] esp6_output+0x1ad/0x270
Jul 18 11:36:12 burg kernel:  [<c04474ff>] xfrm_output_resume+0x24f/0x350
Jul 18 11:36:12 burg kernel:  [<c0400927>] __ip_local_out+0x97/0xa0
Jul 18 11:36:12 burg kernel:  [<c0400945>] ip_local_out+0x15/0x20
Jul 18 11:36:12 burg kernel:  [<c0400b6c>] ip_push_pending_frames+0x21c/0x360
Jul 18 11:36:12 burg kernel:  [<c041c109>] raw_sendmsg+0x6a9/0x750
Jul 18 11:36:12 burg kernel:  [<c0424147>] inet_sendmsg+0x37/0x70
Jul 18 11:36:12 burg kernel:  [<c03d3b6d>] sock_sendmsg+0xcd/0x100
Jul 18 11:36:12 burg kernel:  [<c0136580>] autoremove_wake_function+0x0/0x50
Jul 18 11:36:12 burg kernel:  [<c013a6d4>] __atomic_notifier_call_chain+0x24/0x50
Jul 18 11:36:12 burg kernel:  [<c02e6756>] __delay+0x6/0x10
Jul 18 11:36:12 burg kernel:  [<c0317ce9>] soft_cursor+0x189/0x1f0
Jul 18 11:36:12 burg kernel:  [<c03db7ba>] verify_iovec+0x2a/0x90
Jul 18 11:36:12 burg kernel:  [<c03d3d01>] sys_sendmsg+0x161/0x270
Jul 18 11:36:12 burg kernel:  [<c015447f>] __alloc_pages+0xf/0x20
Jul 18 11:36:12 burg kernel:  [<c015dbd7>] handle_mm_fault+0x3a7/0x5c0
Jul 18 11:36:12 burg kernel:  [<c03d511f>] sys_socketcall+0x24f/0x280
Jul 18 11:36:12 burg kernel:  [<c013ba0d>] do_gettimeofday+0xd/0x30
Jul 18 11:36:12 burg kernel:  [<c0102ffd>] sysenter_past_esp+0x6a/0x91
Jul 18 11:36:12 burg kernel:  =======================
Jul 18 11:36:12 burg kernel: Code: ff ff c7 44 24 0c 7e 09 00 00 c7 44 24 08 c3 bd 5a c0 c7 44 24 04 d5 bd 5a c0 c7 04 24 0c f4 5a c0 e8 
b6 c1 d4 ff e9 f4 fe ff ff <0f> 0b eb fe 0f 0b eb fe 89 f6 8d bc 27 00 00 00 00 53 89 d3 83
Jul 18 11:36:12 burg kernel: EIP: [<c03d890f>] __skb_to_sgvec+0x27f/0x290 SS:ESP 0068:de7c7bd0
Jul 18 11:36:12 burg kernel: ---[ end trace 002976a0f01d4d2f ]---


Any thoughts on this?

br, j
