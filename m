From: Silviu Vlasceanu <silviuvlasceanu@yahoo.com>
Subject: Re: [BUG,NETFILTER] =?utf-8?b?bmZxbmxfbWFuZ2xlKCk=?= not requesting enough space for bigger reinjected packet.
Date: Tue, 29 Apr 2008 14:07:39 +0000 (UTC)
Message-ID: <loom.20080429T135716-549@post.gmane.org>
References: <87hcdo8r6y.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:40779 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156AbYD2OKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 10:10:12 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JqqWw-0000w4-AG
	for netdev@vger.kernel.org; Tue, 29 Apr 2008 14:10:02 +0000
Received: from machine107.rd.francetelecom.com ([193.49.124.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 14:10:02 +0000
Received: from silviuvlasceanu by machine107.rd.francetelecom.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2008 14:10:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaud Ebalard <arno <at> natisbad.org> writes:

> 
> Hi,
> 
> While reinjecting *bigger* modified versions of IPv6 packets using
> libnetfilter_queue, things work fine on a 2.6.24 kernel (2.6.22 too)
> but I get the following on recents kernels (2.6.25, trace below is
> against today's net-2.6 git tree):
> 
> skb_over_panic: text:c04fddb0 len:696 put:632 head:f7592c00 data:f7592c00
tail:0xf7592eb8
> end:0xf7592e80 dev:eth0
> ------------[ cut here ]------------
> invalid opcode: 0000 [#1] PREEMPT 
> Process sendd (pid: 3657, ti=f6014000 task=f77c31d0 task.ti=f6014000)
> Stack: c071e638 c04fddb0 000002b8 00000278 f7592c00 f7592c00 f7592eb8 f7592e80 
>        f763c000 f6bc5200 f7592c40 f6015c34 c04cdbfc f6bc5200 00000278 f6015c60 
>        c04fddb0 00000020 f72a10c0 f751b420 00000001 0000000a 000002b8 c065582c 
> Call Trace:
>  [<c04fddb0>] ? nfqnl_recv_verdict+0x1c0/0x2e0
>  [<c04cdbfc>] ? skb_put+0x3c/0x40
>  [<c04fddb0>] ? nfqnl_recv_verdict+0x1c0/0x2e0
>  [<c04fd115>] ? nfnetlink_rcv_msg+0xf5/0x160
>  [<c04fd03e>] ? nfnetlink_rcv_msg+0x1e/0x160
>  [<c04fd020>] ? nfnetlink_rcv_msg+0x0/0x160
>  [<c04f8ed7>] ? netlink_rcv_skb+0x77/0xa0
>  [<c04fcefc>] ? nfnetlink_rcv+0x1c/0x30
>  [<c04f8c73>] ? netlink_unicast+0x243/0x2b0
>  [<c04cfaba>] ? memcpy_fromiovec+0x4a/0x70
>  [<c04f9406>] ? netlink_sendmsg+0x1c6/0x270
>  [<c04c8244>] ? sock_sendmsg+0xc4/0xf0
>  [<c011970d>] ? set_next_entity+0x1d/0x50
>  [<c0133a80>] ? autoremove_wake_function+0x0/0x40
>  [<c0118f9e>] ? __wake_up_common+0x3e/0x70
>  [<c0342fbf>] ? n_tty_receive_buf+0x34f/0x1280
>  [<c011d308>] ? __wake_up+0x68/0x70
>  [<c02cea47>] ? copy_from_user+0x37/0x70
>  [<c04cfd7c>] ? verify_iovec+0x2c/0x90
>  [<c04c837a>] ? sys_sendmsg+0x10a/0x230
>  [<c011967a>] ? __dequeue_entity+0x2a/0xa0
>  [<c011970d>] ? set_next_entity+0x1d/0x50
>  [<c0345397>] ? pty_write+0x47/0x60
>  [<c033d59b>] ? tty_default_put_char+0x1b/0x20
>  [<c011d2e9>] ? __wake_up+0x49/0x70
>  [<c033df99>] ? tty_ldisc_deref+0x39/0x90
>  [<c033ff20>] ? tty_write+0x1a0/0x1b0
>  [<c04c93af>] ? sys_socketcall+0x7f/0x260
>  [<c0102ff9>] ? sysenter_past_esp+0x6a/0x91
>  [<c05f0000>] ? snd_intel8x0m_probe+0x270/0x6e0
>  =======================
> Code: 00 00 89 5c 24 14 8b 98 9c 00 00 00 89 54 24 0c 89 5c 24 10 8b 40 50 89
4c 24 04 c7 04 24 38 e6 71 c0 89 44 24 08 e8 c4 46 c5
> ff <0f> 0b eb fe 55 89 e5 56 89 d6 53 89 c3 83 ec 0c 8b 40 50 39 d0 
> EIP: [<c04ccdfc>] skb_over_panic+0x5c/0x60 SS:ESP 0068:f6015bf8
> 
> Looking at the code, I ended up in nfq_mangle() function (called by
> nfqnl_recv_verdict()) which performs a call to skb_copy_expand() due to
> the increased size of data passed to the function. AFAICT, it should ask
> for 'diff' instead of 'diff - skb_tailroom(e->skb)'. Because the
> resulting sk_buff has not enough space to support the skb_put(skb, diff)
> call a few lines later, this results in the call to skb_over_panic().
> 
> The patch below asks for allocation of a copy with enough space for
> mangled packet and the same amount of headroom as old sk_buff. While
> looking at how the regression appeared (e2b58a67), I noticed the same
> pattern in ipq_mangle_ipv6() and ipq_mangle_ipv4(). The patch corrects
> those locations too.
> 
> Tested with bigger reinjected IPv6 packets (nfqnl_mangle() path), things
> are ok (2.6.25 and today's net-2.6 git tree).
> 
> Don't hesitate if I missed something.
> 
> Cheers,
> 
> a+
> 
> 
> Attachment (bad_argument_to_skb_copy_expand_in_nfqnl_mangle.patch):
text/x-diff, 2002 bytes

Hello,

I have tried sendd on 2.6.24-1 and there still seems to be a problem with it:

ip6_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
skb_over_panic: text:e01fcb93 len:432 put:368 head:de406c00 data:de406c00
tail:0xde406db0 end:0xde406d20 dev:eth0
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:95!
invalid opcode: 0000 [#1] SMP
Modules linked in: nfnetlink_queue nfnetlink xt_NFQUEUE ip6table_filter
ip6_tables x_tables ppdev lp ac battery ipv6 fuse dm_snapshot dm_mirror dm_mod
loop snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq
parport_pc parport snd_timer snd_seq_device serio_raw snd soundcore psmouse
snd_page_alloc pcspkr iTCO_wdt rtc i2c_i801 i2c_core shpchp pci_hotplug button
intel_agp agpgart evdev ext3 jbd mbcache ide_cd cdrom ide_disk generic usbhid
hid piix ide_core floppy ata_generic e1000 ehci_hcd uhci_hcd libata scsi_mod
usbcore thermal processor fan

Pid: 2265, comm: sendd Not tainted (2.6.24-1-686 #1)
EIP: 0060:[<c0258a2d>] EFLAGS: 00210296 CPU: 0
EIP is at skb_over_panic+0x59/0x5d
EAX: 00000075 EBX: de406c00 ECX: 00200082 EDX: 00200000
ESI: ddb43000 EDI: dd832280 EBP: ded71b80 ESP: ded6fc28
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process sendd (pid: 2265, ti=ded6e000 task=ded05250 task.ti=ded6e000)
Stack: c032814b e01fcb93 000001b0 00000170 de406c00 de406c00 de406db0 de406d20
       ddb43000 000001b0 00000170 e01fcb98 00000020 ddffdc20 dda4d180 00000001
       e01fcf8c e01fcf80 0000000c ded6fce0 e02f820c ded6fc90 e01fcfc0 ffffffff
Call Trace:
 [<e01fcb93>] nfqnl_recv_verdict+0x181/0x20e [nfnetlink_queue]
 [<e01fcb98>] nfqnl_recv_verdict+0x186/0x20e [nfnetlink_queue]
 [<e02f820c>] nfnetlink_rcv_msg+0x114/0x154 [nfnetlink]
 [<e02f80f8>] nfnetlink_rcv_msg+0x0/0x154 [nfnetlink]
 [<c0272f0d>] netlink_rcv_skb+0x2d/0x7e
 [<e02f8019>] nfnetlink_rcv+0x19/0x24 [nfnetlink]
 [<c0272cf4>] netlink_unicast+0x199/0x1f4
 [<c02734ec>] netlink_sendmsg+0x27c/0x288
 [<c0225db7>] __add_entropy_words+0x58/0x176
 [<c02549fb>] sock_sendmsg+0xc9/0xe4
 [<c01353f9>] autoremove_wake_function+0x0/0x35
 [<c0254ba8>] sys_sendmsg+0x192/0x1f7
 [<c016615f>] __do_fault+0x32b/0x36c
 [<c013abdc>] clocksource_get_next+0x39/0x3f
 [<c0139c51>] update_wall_time+0x541/0x6a5
 [<c01680e5>] handle_mm_fault+0x2cf/0x685
 [<c0115944>] lapic_next_event+0xc/0x10
 [<c013c08d>] clockevents_program_event+0xe0/0xee
 [<c012c6a2>] lock_timer_base+0x19/0x35
 [<c012c7b6>] __mod_timer+0x9a/0xa4
 [<c0255e01>] sys_socketcall+0x240/0x261
 [<c0129294>] irq_exit+0x53/0x6b
 [<c0115e6c>] smp_apic_timer_interrupt+0x71/0x7d
 [<c0103e5e>] sysenter_past_esp+0x6b/0xa1
 =======================
Code: 00 00 89 5c 24 14 8b 98 a0 00 00 00 89 54 24 0c 89 5c 24 10 8b 40 50 89 4c
24 04 c7 04 24 4b 81 32 c0 89 44 24 08 e8 75 c7 ec ff <0f> 0b eb fe 56 89 d6 53
89 c3 83 ec 0c 8b 40 50 39 c2 76 04 0f
EIP: [<c0258a2d>] skb_over_panic+0x59/0x5d SS:ESP 0068:ded6fc28
---[ end trace 012d67e9de71128b ]---
[drm] Initialized drm 1.1.0 20060810
sid:~# uname -r
2.6.24-1-686

I have't patched yet my 2.6.25 kernel with the patch you provided, so I have
tried sendd on 2.6.24-1, as you said there are no problems with it (sendd
installed via the .deb packages you uploaded on rfc. ...

Do you have idea of what could be causing this?

Thanks,

Silviu


