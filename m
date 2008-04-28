From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Mon, 28 Apr 2008 10:51:55 +0300
Message-ID: <200804281051.55711.joakim.koskela@hiit.fi>
References: <200803261115.26157.joakim.koskela@hiit.fi> <200804231013.38390.joakim.koskela@hiit.fi> <20080423073003.GB29767@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:37741 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750898AbYD1Hs7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 03:48:59 -0400
In-Reply-To: <20080423073003.GB29767@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 April 2008 10:30, Herbert Xu wrote:
> On Wed, Apr 23, 2008 at 10:13:38AM +0300, Joakim Koskela wrote:
> > Sorry, I know really should. I'll try to get back on this asap with some
> > more details. But in a nutshell - I get crashes on 4-6 (inner-outer), and
> > although 6-4 gets packets on the wire, they're somehow wrong. Hm, don't
> > actually think there's anything wrong with 6-6 though, I'll have to
> > recheck that..
>
> OK I'll try to get my test environment back up to have a look.
>
> Thanks,

Here's a calltrace from 4 inner, 6 outer. I do a manual key setup, and try to
ping the other host.

------------[ cut here ]------------
invalid opcode: 0000 [#4] PREEMPT
Process ping (pid: 5516, ti=d9598000 task=d957b140 task.ti=d9598000)
Stack: e086f700 e1b9a5ec 00000000 00000014 d9599c17 dc3fbc40 dfa68a80 dfa68a80
       00000078 00000000 00000001 c069a3a0 deef2000 00000000 dc3fbc40 dfa68aa0
       d9569040 dfa68a80 c03d2c04 00000054 d9569038 c0476b1d 00000054 dc35e600
Call Trace:
 [<c03d2c04>] skb_to_sgvec+0x14/0x30
 [<c0476b1d>] esp6_output+0x1ad/0x270
 [<c0441fa4>] xfrm_output_resume+0x2a4/0x320
 [<c03fad17>] __ip_local_out+0x97/0xa0
 [<c03fad35>] ip_local_out+0x15/0x20
 [<c03faf4a>] ip_push_pending_frames+0x20a/0x350
 [<c03f3ea4>] ip_route_output_flow+0x74/0x290
 [<c041688f>] raw_sendmsg+0x69f/0x750
 [<c041eb27>] inet_sendmsg+0x37/0x70
 [<c03cde7d>] sock_sendmsg+0xcd/0x100
 [<c03fd407>] ip_setsockopt+0x147/0xc40
 [<c0136550>] autoremove_wake_function+0x0/0x50
 [<c011ce9c>] set_next_entity+0x1c/0x50
 [<c04cbfb7>] schedule+0x177/0x310
 [<c03d5afa>] verify_iovec+0x2a/0x90
 [<c03ce011>] sys_sendmsg+0x161/0x270
 [<c0359f6a>] tty_ioctl+0x73a/0xec0
 [<c014e7ae>] find_lock_page+0x2e/0xd0
 [<c0150e2f>] filemap_fault+0x1ef/0x460
 [<c015b291>] __do_fault+0x171/0x3b0
 [<c0150c40>] filemap_fault+0x0/0x460
 [<c015d0c2>] handle_mm_fault+0xf2/0x600
 [<c03cf42f>] sys_socketcall+0x24f/0x280
 [<c013b62d>] do_gettimeofday+0xd/0x30
 [<c0102f3d>] sysenter_past_esp+0x6a/0x91
 =======================
Code: ff ff c7 44 24 0c 74 09 00 00 c7 44 24 08 a9 37 5a c0 c7 44 24 04 bb 37 5a c0 c7 04 24 2c 6e 5a c0 e8 95 1c d5 ff e9 02 ff ff ff <0f> 0b eb fe 0f 0b eb fe 90 8d b4 26 00 00 00 00 53 89 d3 83 ec
EIP: [<c03d2be0>] __skb_to_sgvec+0x280/0x290 SS:ESP 0068:d9599bd0

Modules linked in: radeon drm rfcomm l2cap binfmt_misc ppdev lp cpufreq_userspace cpufreq_conservative cpufreq_powersave cpufreq_ondemand ipt_TTL ipt_ttl ipt_REDIRECT ipt_recent ipt_NETMAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_addrtype nf_nat_tftp nf_nat_snmp_basic nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp nf_conntrack_amanda nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netbios_ns nf_conntrack_irc nf_conntrack_h323 nf_conntrack_ftp xt_tcpmss xt_pkttype xt_mark xt_mac xt_limit xt_length xt_helper xt_hashlimit xt_dccp xt_conntrack xt_CONNMARK xt_connmark xt_state iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nls_cp437 loop 8250_pci hci_usb bluetooth snd_intel8x0m snd_inte
 l8x0 snd_ac97_codec irtty_sir ac97_bus sir_dev snd_pcm_oss snd_mixer_oss parport_pc 8250_pnp snd_pcm 8250 irda snd_timer serial_core snd parport crc_ccitt floppy soundcore ide_cd_mod ipw2100 cdro
 i2c_i801 snd_page_alloc ieee80211 ieee80211_crypt e1000 ehci_hcd uhci_hcd video usbcore output evdev

Pid: 5516, comm: ping Tainted: G      D  (2.6.25-02632-g358c129 #3)
EIP: 0060:[<c03d2be0>] EFLAGS: 00010206 CPU: 0
EIP is at __skb_to_sgvec+0x280/0x290
EAX: dc3fbc40 EBX: 00000048 ECX: dfa68a80 EDX: d9569100
ESI: 00000000 EDI: 00000014 EBP: 00000078 ESP: d9599bd0
 DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
---[ end trace ff7f9acec52365a5 ]---



