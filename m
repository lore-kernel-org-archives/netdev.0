From: Neal Cardwell <ncardwell@google.com>
Subject: Re: backport "tcp: fix tcp_mark_head_lost to check skb len before
 fragmenting" to 4.4-stable?
Date: Tue, 2 Aug 2016 10:49:22 -0400
Message-ID: <CADVnQynQy_c6wQ5PGRHr9dvpvHTTHi71GdAA36azYd7Bu_ERkw@mail.gmail.com>
References: <20160711090526.GN10080@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: stable@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yuchung Cheng <ycheng@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:35307 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbcHBOtx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Aug 2016 10:49:53 -0400
Received: by mail-oi0-f43.google.com with SMTP id 4so29663301oih.2
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2016 07:49:53 -0700 (PDT)
In-Reply-To: <20160711090526.GN10080@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, it would make sense to backport d88270e ("tcp: fix
tcp_mark_head_lost to check skb len before fragmenting") to
4.4-stable.

It would also work to backport it further (as far back as, e.g. 3.2
stable releases), but (a) the patch would need to resolve conflicts,
since the GFP_ATOMIC parameter is not in older kernels, and (b) it's
only to remove a WARN_ON, so it's probably not worth the effort for
those older kernels, IMHO.

neal

On Mon, Jul 11, 2016 at 5:05 AM, Lennert Buytenhek
<buytenh@wantstofly.org> wrote:
> Hi!
>
> I am seeing this on 4.4.6-with-some-local-patches:
>
> ------------[ cut here ]------------
> WARNING: CPU: 5 PID: 117300 at net/ipv4/tcp_output.c:1147 tcp_fragment+0x2d8/0x2e0()
> Modules linked in: ip6t_REJECT nf_reject_ipv6 nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_mangle ip6table_filter ip6table_raw xt_set xt_DSCP xt_TEE nf_dup_ipv4 nf_dup_ipv6 xt_dscp xt_devgroup xt_comment iptable_nat nf_nat_ipv4 nf_nat macvlan ip6_tables msr ip_set_hash_ip ip_set x86_pkg_temp_thermal coretemp crct10dif_pclmul crc32_pclmul sb_edac input_leds edac_core lpc_ich mfd_core tpm_tis tpm ipmi_watchdog igb i2c_algo_bit isci libsas ixgbe ptp pps_core vxlan udp_tunnel ip6_udp_tunnel mdio
> CPU: 5 PID: 117300 Comm: healthcheck-con Tainted: G        W       4.4.6-XXX
> Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0a 12/04/2013
>  0000000000000000 ffff885eff943788 ffffffff81377011 0000000000000000
>  000000000000047b ffff885eff9437c8 ffffffff8107fe07 ffff885eff403500
>  ffff885e68e26c00 ffff885c817abc00 00000000000054d8 0000000000005268
> Call Trace:
>  <IRQ>  [<ffffffff81377011>] dump_stack+0x4d/0x6c
>  [<ffffffff8107fe07>] warn_slowpath_common+0x97/0xe0
>  [<ffffffff8107fe6a>] warn_slowpath_null+0x1a/0x20
>  [<ffffffff816f0ee8>] tcp_fragment+0x2d8/0x2e0
>  [<ffffffff816e780b>] tcp_mark_head_lost+0xdb/0x240
>  [<ffffffff816e858c>] tcp_update_scoreboard+0x4c/0x70
>  [<ffffffff816ec9e1>] tcp_fastretrans_alert+0x761/0xa80
>  [<ffffffff816edc83>] tcp_ack+0x933/0x11a0
>  [<ffffffff816eeb13>] tcp_rcv_established+0x293/0x750
>  [<ffffffff81788ce8>] ? tcp_v4_inbound_md5_hash+0x61/0x152
>  [<ffffffff816f89e2>] tcp_v4_do_rcv+0x122/0x220
>  [<ffffffff816fa036>] tcp_v4_rcv+0x9a6/0xa80
>  [<ffffffff816d567a>] ip_local_deliver_finish+0x9a/0x200
>  [<ffffffff816d5994>] ip_local_deliver+0x64/0xd0
>  [<ffffffff816d55e0>] ? ip_rcv_finish+0x350/0x350
>  [<ffffffff816d53e1>] ip_rcv_finish+0x151/0x350
>
> [...]
>
> This upstream patch seems to address this issue:
>
> commit d88270eef4b56bd7973841dd1fed387ccfa83709
> Author: Neal Cardwell <ncardwell@google.com>
> Date:   Mon Jan 25 14:01:53 2016 -0800
>
>     tcp: fix tcp_mark_head_lost to check skb len before fragmenting
>
>     This commit fixes a corner case in tcp_mark_head_lost() which was
>     causing the WARN_ON(len > skb->len) in tcp_fragment() to fire.
>
>     [...]
>
> But it doesn't seem to have been backported to 4.4.  Would it make
> sense to backport it to 4.4-stable?
>
> Thanks!
>
>
> Cheers,
> Lennert
