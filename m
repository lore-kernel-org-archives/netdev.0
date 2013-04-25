From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: 3.9.0-rc8-00005-g824282c: [24988.276086] unregister_netdevice: waiting for tap0 to become free. Usage count = 1
Date: Thu, 25 Apr 2013 08:22:38 +0200
Message-ID: <201304250822.38944.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f173.google.com ([209.85.215.173]:33830 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3DYGWm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 02:22:42 -0400
Received: by mail-ea0-f173.google.com with SMTP id m14so1037381eaj.4
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 23:22:41 -0700 (PDT)
Received: from t400.localnet ([91.234.176.244])
        by mx.google.com with ESMTPSA id cd3sm8436958eeb.6.2013.04.24.23.22.39
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Apr 2013 23:22:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


suspend & resume from ram on 3.9.0-rc8-00005-g824282c
causes problem below. 3.8.x line doesn't have this problem.

[23429.361300] Freezing user space processes ...=20
[23449.380695] Freezing of tasks failed after 20.01 seconds (1 tasks re=
fusing to freeze, wq_busy=3D0):
[23449.385438] openvpn         D 0000000000000001     0  4668      1 0x=
00000006
[23449.390225]  ffff88022a1f3b08 0000000000000046 ffff88022a1696c0 ffff=
88022a1f3fd8
[23449.395020]  0000000000012780 ffff88022a1f3fd8 ffffffff81611410 ffff=
88022a1696c0
[23449.399833]  00000000000000ce ffffffffa06e0978 0000000000000080 ffff=
880229b9c000
[23449.404619] Call Trace:
[23449.409356]  [<ffffffff81328e8d>] ? pneigh_queue_purge+0x2a/0x34
[23449.414163]  [<ffffffff8132b1da>] ? neigh_ifdown+0xc0/0xd1
[23449.418942]  [<ffffffff8103e90a>] ? lock_timer_base.isra.38+0x26/0x4=
a
[23449.423720]  [<ffffffff8103e97e>] ? try_to_del_timer_sync+0x50/0x5c
[23449.428484]  [<ffffffff813bff33>] schedule+0x60/0x62
[23449.433166]  [<ffffffff813be466>] schedule_timeout+0x1aa/0x1fd
[23449.437847]  [<ffffffff8103dfa1>] ? call_timer_fn+0x15f/0x15f
[23449.442555]  [<ffffffff813be4d2>] schedule_timeout_uninterruptible+0=
x19/0x1b
[23449.447244]  [<ffffffff8103ef24>] msleep+0x16/0x1d
[23449.451900]  [<ffffffff81324b6e>] netdev_run_todo+0x175/0x245
[23449.456498]  [<ffffffff8132e848>] rtnl_unlock+0x9/0xb
[23449.461131]  [<ffffffffa05dccd5>] tun_chr_close+0x2d/0x47 [tun]
[23449.465699]  [<ffffffff81109fe0>] __fput+0xf0/0x1e1
[23449.470227]  [<ffffffff8110a0da>] ____fput+0x9/0xb
[23449.474736]  [<ffffffff8104b6fb>] task_work_run+0x79/0x92
[23449.479169]  [<ffffffff81036088>] do_exit+0x3b8/0x8ee
[23449.483631]  [<ffffffff810406fc>] ? __dequeue_signal+0x16/0x114
[23449.488130]  [<ffffffff8103673a>] do_group_exit+0x6a/0x9d
[23449.492662]  [<ffffffff81042c7a>] get_signal_to_deliver+0x50f/0x554
[23449.497178]  [<ffffffff810020de>] do_signal+0x48/0x49f
[23449.501721]  [<ffffffff8107afe9>] ? sys_futex+0x11a/0x14d
[23449.506319]  [<ffffffff81002565>] do_notify_resume+0x30/0x6d
[23449.510881]  [<ffffffff813c1d5a>] int_signal+0x12/0x17

[23449.517219] Restarting tasks ... done.

and that ends up with:
[23527.916091] unregister_netdevice: waiting for tap0 to become free. U=
sage count =3D 1
[23537.956095] unregister_netdevice: waiting for tap0 to become free. U=
sage count =3D 1
[23548.196057] unregister_netdevice: waiting for tap0 to become free. U=
sage count =3D 1
[23558.440052] unregister_netdevice: waiting for tap0 to become free. U=
sage count =3D 1
[23568.684099] unregister_netdevice: waiting for tap0 to become free. U=
sage count =3D 1

complete dmesg: http://pastebin.com/5Eq8dz8T

--=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / maven.pl [domain blocked by vger and=
 still no clue why]
