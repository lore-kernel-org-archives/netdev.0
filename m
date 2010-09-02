From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] change sk->sk_forward_alloc to atomic
Date: Thu, 02 Sep 2010 23:03:33 +0200
Message-ID: <1283461413.3699.272.camel@edumazet-laptop>
References: <20100902204706.29795.6982.stgit@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Franchoze <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35934 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab0IBVDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 17:03:39 -0400
Received: by ewy23 with SMTP id 23so667869ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 14:03:38 -0700 (PDT)
In-Reply-To: <20100902204706.29795.6982.stgit@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 00:47 +0400, Eric Franchoze a =C3=A9=
crit :
> Patch fixes issue bellow.
> kernel: ------------[ cut here ]------------
>  kernel: WARNING: at net/ipv4/af_inet.c:153 inet_sock_destruct+0xfb/0=
x114()
>  kernel: Hardware name: PowerEdge SC1435
>  kernel: Modules linked in: ipt_REJECT xt_connlimit xt_limit iptable_=
filter ipt_REDIRECT xt_tcpudp xt_state xt_multiport iptable_nat nf_nat =
nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables tun 80=
21q dm_mirror dm_multipath scsi_dh sbs sbshc power_meter hwmon battery =
ac sg dcdbas tpm_tis tpm serio_raw tpm_bios button rtc_cmos rtc_core rt=
c_lib tg3 firmware_class libphy amd64_edac_mod edac_core i2c_piix4 i2c_=
core dm_region_hash dm_log dm_mod sata_svw libata sd_mod scsi_mod ext3 =
jbd
>  kernel: Pid: 15163, comm: openvpn Tainted: G        W  2.6.32.17 #3
>  kernel: Call Trace:
>  kernel:  [<ffffffff812a1d21>] ? inet_sock_destruct+0xfb/0x114
>  kernel:  [<ffffffff81047e4a>] warn_slowpath_common+0x77/0x8f
>  kernel:  [<ffffffff81047e71>] warn_slowpath_null+0xf/0x11
>  kernel:  [<ffffffff812a1d21>] inet_sock_destruct+0xfb/0x114
>  kernel:  [<ffffffff8124c52c>] __sk_free+0x1e/0xdb
>  kernel:  [<ffffffff8124c65a>] sk_free+0x17/0x19
>  kernel:  [<ffffffff8124c670>] sock_put+0x14/0x16
>  kernel:  [<ffffffff8124c71e>] sk_common_release+0xac/0xb1
>  kernel:  [<ffffffff812995c8>] udp_lib_close+0x9/0xb
>  kernel:  [<ffffffff812a1300>] inet_release+0x58/0x5f
>  kernel:  [<ffffffff81249ce7>] sock_release+0x1a/0x6c
>  kernel:  [<ffffffff8124a1ad>] sock_close+0x22/0x26
>  kernel:  [<ffffffff810dc8f5>] __fput+0xf6/0x193
>  kernel:  [<ffffffff810dcc36>] fput+0x15/0x17
>  kernel:  [<ffffffff810d9bc9>] filp_close+0x67/0x72
>  kernel:  [<ffffffff81049d7b>] put_files_struct+0x77/0xcb
>  kernel:  [<ffffffff81049e05>] exit_files+0x36/0x3b
>  kernel:  [<ffffffff8104af44>] do_exit+0x23f/0x65e
>  kernel:  [<ffffffff81055e91>] ? set_tsk_thread_flag+0xd/0xf
>  kernel:  [<ffffffff81055ec9>] ? recalc_sigpending_tsk+0x36/0x3d
>  kernel:  [<ffffffff8104b3f7>] sys_exit_group+0x0/0x16
>  kernel:  [<ffffffff8105829f>] get_signal_to_deliver+0x33a/0x38d
>  kernel:  [<ffffffff8100b11e>] do_notify_resume+0x8c/0x6bb
>  kernel:  [<ffffffff812db68f>] ? _spin_lock_irqsave+0x18/0x34
>  kernel:  [<ffffffff81060737>] ? remove_wait_queue+0x4c/0x51
>  kernel:  [<ffffffff8104ac2d>] ? do_wait+0x216/0x222
>  kernel:  [<ffffffff8104ace6>] ? sys_wait4+0xad/0xbf
>  kernel:  [<ffffffff8100be06>] int_signal+0x12/0x17
>  kernel: ---[ end trace 9ae8be71cf9ee7de ]---
> Signed-off-by: Eric Franchoze <franchoze@yandex.ru>

You must be kidding.

sk_forward_alloc will stay as it is : not atomic.

Probably bug is already fixed in current kernel.

Check if your kernel got commits=20

b1faf5666438090a4dc4fceac8502edc7788b7e3
(net: sock_queue_err_skb() dont mess with sk_forward_alloc)

2903037400a26e7c0cc93ab75a7d62abfacdf485
(net: fix sk_forward_alloc corruptions)

9d410c796067686b1e032d54ce475b7055537138
(net: fix sk_forward_alloc corruption)



