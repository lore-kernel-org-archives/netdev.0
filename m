From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Wed, 11 Feb 2009 16:26:02 +0100
Message-ID: <BAY103-DAV55D390C73C4EC5373A371B2BA0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s6.bay0.hotmail.com ([65.54.246.142]:34472 "EHLO
	bay0-omc2-s6.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757326AbZBKPcz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 10:32:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Folks,

I'm getting this error on 2.6.28.4 when I run tcpdump on
the interface where ipsec packets are enc/decrypted.

TIA

> Feb 11 10:53:55 Pleiadi kernel: ------------[ cut here ]------------
> Feb 11 10:53:55 Pleiadi kernel: WARNING: at net/core/skbuff.c:154 skb_truesize_bug+0x2e/0x33()
> Feb 11 10:53:55 Pleiadi kernel: SKB BUG: Invalid truesize (268) len=134, sizeof(sk_buff)=172
> Feb 11 10:53:55 Pleiadi kernel: Modules linked in: twofish_i586 twofish_common serpent blowfish ecb nf_nat_pptp nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp 3c59x mii
> Feb 11 10:53:55 Pleiadi kernel: Pid: 4302, comm: tcpdump Tainted: G        W  2.6.28.4 #1
> Feb 11 10:53:55 Pleiadi kernel: Call Trace:
> Feb 11 10:53:55 Pleiadi kernel:  [<c01157b4>] warn_slowpath+0x58/0x71
> Feb 11 10:53:55 Pleiadi kernel:  [<c0111909>] set_next_entity+0x14/0x39
> Feb 11 10:53:55 Pleiadi kernel:  [<c02ae273>] __sched_text_start+0x233/0x24f
> Feb 11 10:53:55 Pleiadi kernel:  [<c024a46d>] wait_for_packet+0x109/0x113
> Feb 11 10:53:55 Pleiadi kernel:  [<c0122d56>] autoremove_wake_function+0x0/0x2d
> Feb 11 10:53:55 Pleiadi kernel:  [<c01ea285>] __copy_to_user_ll+0x3e/0x45
> Feb 11 10:53:55 Pleiadi kernel:  [<c01ea3c4>] copy_to_user+0x27/0x2f
> Feb 11 10:53:55 Pleiadi kernel:  [<c0247612>] skb_truesize_bug+0x2e/0x33
> Feb 11 10:53:55 Pleiadi kernel:  [<c0246363>] sock_rfree+0x1e/0x42
> Feb 11 10:53:55 Pleiadi kernel:  [<c0247909>] skb_release_head_state+0x4c/0x7d
> Feb 11 10:53:55 Pleiadi kernel:  [<c0247942>] skb_release_all+0x8/0x10
> Feb 11 10:53:55 Pleiadi kernel:  [<c0247952>] __kfree_skb+0x8/0x10
> Feb 11 10:53:55 Pleiadi kernel:  [<c024a55b>] skb_free_datagram+0xa/0x29
> Feb 11 10:53:55 Pleiadi kernel:  [<c02a5c19>] packet_recvmsg+0x180/0x18c
> Feb 11 10:53:55 Pleiadi kernel:  [<c0111ac2>] wakeup_preempt_entity+0x26/0x3f
> Feb 11 10:53:55 Pleiadi kernel:  [<c0111b50>] check_preempt_wakeup+0x49/0xac
> Feb 11 10:53:55 Pleiadi kernel:  [<c0243d74>] sock_recvmsg+0xbf/0xda
> Feb 11 10:53:55 Pleiadi kernel:  [<c0112c3d>] __wake_up+0x11/0x1a
> Feb 11 10:53:55 Pleiadi kernel:  [<c0220619>] n_tty_receive_buf+0x811/0x82d
> Feb 11 10:53:55 Pleiadi kernel:  [<c0122d56>] autoremove_wake_function+0x0/0x2d
> Feb 11 10:53:55 Pleiadi kernel:  [<c026cf4b>] ip_forward+0x251/0x292
> Feb 11 10:53:55 Pleiadi kernel:  [<c026c03f>] ip_rcv_finish+0x215/0x229
> Feb 11 10:53:55 Pleiadi kernel:  [<c01ea3c4>] copy_to_user+0x27/0x2f
> Feb 11 10:53:55 Pleiadi kernel:  [<c0244ce2>] sys_recvfrom+0xa9/0x100
> Feb 11 10:53:55 Pleiadi kernel:  [<c021f8d8>] opost+0x184/0x18b
> Feb 11 10:53:55 Pleiadi kernel:  [<c02210ce>] n_tty_write+0x188/0x1a1
> Feb 11 10:53:55 Pleiadi kernel:  [<c0112bc4>] default_wake_function+0x0/0xc
> Feb 11 10:53:55 Pleiadi kernel:  [<c0112c3d>] __wake_up+0x11/0x1a
> Feb 11 10:53:55 Pleiadi kernel:  [<c01e7d6c>] __rb_erase_color+0x95/0x13f
> Feb 11 10:53:55 Pleiadi kernel:  [<c02452ec>] sys_socketcall+0x115/0x18a
> Feb 11 10:53:55 Pleiadi kernel:  [<c0102aae>] syscall_call+0x7/0xb
> Feb 11 10:53:55 Pleiadi kernel: ---[ end trace f36cb14ebd5b6b5f ]---

Maybe related thread: http://lkml.indiana.edu/hypermail/linux/kernel/0902.0/02757.html
