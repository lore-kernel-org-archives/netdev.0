From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: [PATCH] change sk->sk_forward_alloc to atomic
Date: Fri, 03 Sep 2010 01:46:32 +0400
Message-ID: <201161283463993@web118.yandex.ru>
References: <20100902204706.29795.6982.stgit@maxim-laptop> <1283461413.3699.272.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8.mail.yandex.net ([77.88.61.38]:49788 "EHLO
	forward8.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab0IBVqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 17:46:36 -0400
In-Reply-To: <1283461413.3699.272.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



03.09.10, 01:03, "Eric Dumazet" <eric.dumazet@gmail.com>:

> Le vendredi 03 septembre 2010 =C3=A0 00:47 +0400, Eric Franchoze a =C3=
=A9crit :
>  > Patch fixes issue bellow.
>  > kernel: ------------[ cut here ]------------
>  >  kernel: WARNING: at net/ipv4/af_inet.c:153 inet_sock_destruct+0xf=
b/0x114()
>  >  kernel: Hardware name: PowerEdge SC1435
>  >  kernel: Modules linked in: ipt_REJECT xt_connlimit xt_limit iptab=
le_filter ipt_REDIRECT xt_tcpudp xt_state xt_multiport iptable_nat nf_n=
at nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables tun=
 8021q dm_mirror dm_multipath scsi_dh sbs sbshc power_meter hwmon batte=
ry ac sg dcdbas tpm_tis tpm serio_raw tpm_bios button rtc_cmos rtc_core=
 rtc_lib tg3 firmware_class libphy amd64_edac_mod edac_core i2c_piix4 i=
2c_core dm_region_hash dm_log dm_mod sata_svw libata sd_mod scsi_mod ex=
t3 jbd
>  >  kernel: Pid: 15163, comm: openvpn Tainted: G        W  2.6.32.17 =
#3
>  >  kernel: Call Trace:
>  >  kernel:  [] ? inet_sock_destruct+0xfb/0x114
>  >  kernel:  [] warn_slowpath_common+0x77/0x8f
>  >  kernel:  [] warn_slowpath_null+0xf/0x11
>  >  kernel:  [] inet_sock_destruct+0xfb/0x114
>  >  kernel:  [] __sk_free+0x1e/0xdb
>  >  kernel:  [] sk_free+0x17/0x19
>  >  kernel:  [] sock_put+0x14/0x16
>  >  kernel:  [] sk_common_release+0xac/0xb1
>  >  kernel:  [] udp_lib_close+0x9/0xb
>  >  kernel:  [] inet_release+0x58/0x5f
>  >  kernel:  [] sock_release+0x1a/0x6c
>  >  kernel:  [] sock_close+0x22/0x26
>  >  kernel:  [] __fput+0xf6/0x193
>  >  kernel:  [] fput+0x15/0x17
>  >  kernel:  [] filp_close+0x67/0x72
>  >  kernel:  [] put_files_struct+0x77/0xcb
>  >  kernel:  [] exit_files+0x36/0x3b
>  >  kernel:  [] do_exit+0x23f/0x65e
>  >  kernel:  [] ? set_tsk_thread_flag+0xd/0xf
>  >  kernel:  [] ? recalc_sigpending_tsk+0x36/0x3d
>  >  kernel:  [] sys_exit_group+0x0/0x16
>  >  kernel:  [] get_signal_to_deliver+0x33a/0x38d
>  >  kernel:  [] do_notify_resume+0x8c/0x6bb
>  >  kernel:  [] ? _spin_lock_irqsave+0x18/0x34
>  >  kernel:  [] ? remove_wait_queue+0x4c/0x51
>  >  kernel:  [] ? do_wait+0x216/0x222
>  >  kernel:  [] ? sys_wait4+0xad/0xbf
>  >  kernel:  [] int_signal+0x12/0x17
>  >  kernel: ---[ end trace 9ae8be71cf9ee7de ]---
>  > Signed-off-by: Eric Franchoze=20
> =20
>  You must be kidding.
> =20
>  sk_forward_alloc will stay as it is : not atomic.
> =20
>  Probably bug is already fixed in current kernel.
> =20
>  Check if your kernel got commits=20
> =20
>  b1faf5666438090a4dc4fceac8502edc7788b7e3
>  (net: sock_queue_err_skb() dont mess with sk_forward_alloc)
> =20
>  2903037400a26e7c0cc93ab75a7d62abfacdf485
>  (net: fix sk_forward_alloc corruptions)
> =20
>  9d410c796067686b1e032d54ce475b7055537138
>  (net: fix sk_forward_alloc corruption)
> =20
> =20

Thanks. Both kernels have only commit 3. I jumped while  doing this pat=
ch from 2.6.32.17 to 2.6.32.20 but looks like there were nothing in com=
mits related to it.
Will backport first 2 patches to 2.6.32 and test.
