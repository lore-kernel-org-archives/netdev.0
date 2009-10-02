From: Dave Young <hidave.darkstar@gmail.com>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
	invalid context at mm/slub.c:1719
Date: Fri, 2 Oct 2009 19:01:10 +0800
Message-ID: <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
References: <4AC59D8A.6000102@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:43499 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671AbZJBLBI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 07:01:08 -0400
In-Reply-To: <4AC59D8A.6000102@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 2, 2009 at 2:28 PM, Oliver Hartkopp <oliver@hartkopp.net> w=
rote:
> Hello Marcel,
>
> with current net-2.6 tree ...
>
> While starting my PPP Bluetooth dialup networking, i got this:

Hi, oliver

please try following patch:
http://patchwork.kernel.org/patch/51326/

>
> [ =C2=A0722.461549] PPP generic driver version 2.4.2
> [ =C2=A0722.477519] BUG: sleeping function called from invalid contex=
t at
> mm/slub.c:1719
> [ =C2=A0722.477530] in_atomic(): 1, irqs_disabled(): 0, pid: 4677, na=
me: pppd
> [ =C2=A0722.477537] 3 locks held by pppd/4677:
> [ =C2=A0722.477542] =C2=A0#0: =C2=A0(rfcomm_mutex){+.+.+.}, at: [<fa5=
df2a1>]
> rfcomm_dlc_open+0x28/0x2d6 [rfcomm]
> [ =C2=A0722.477568] =C2=A0#1: =C2=A0(sk_lock-AF_BLUETOOTH-BTPROTO_L2C=
AP){+.+.+.}, at:
> [<fa5414f8>] l2cap_sock_connect+0x62/0x2c6 [l2cap]
> [ =C2=A0722.477589] =C2=A0#2: =C2=A0(&hdev->lock){+...+.}, at: [<fa54=
15b4>]
> l2cap_sock_connect+0x11e/0x2c6 [l2cap]
> [ =C2=A0722.477613] Pid: 4677, comm: pppd Not tainted 2.6.31-08939-gd=
b8abec-dirty #21
> [ =C2=A0722.477619] Call Trace:
> [ =C2=A0722.477633] =C2=A0[<c1042a2b>] ? __debug_show_held_locks+0x1e=
/0x20
> [ =C2=A0722.477644] =C2=A0[<c10212a1>] __might_sleep+0xc9/0xce
> [ =C2=A0722.477655] =C2=A0[<c1078b62>] __kmalloc+0x6d/0xfb
> [ =C2=A0722.477666] =C2=A0[<c119e739>] ? kzalloc+0xb/0xd
> [ =C2=A0722.477674] =C2=A0[<c119e739>] kzalloc+0xb/0xd
> [ =C2=A0722.477683] =C2=A0[<c119ef1a>] device_private_init+0x15/0x3d
> [ =C2=A0722.477693] =C2=A0[<c11a0e1b>] dev_set_drvdata+0x18/0x26
> [ =C2=A0722.477718] =C2=A0[<f8b7ca1b>] hci_conn_init_sysfs+0x3d/0xc7 =
[bluetooth]
> [ =C2=A0722.477737] =C2=A0[<f8b791b3>] hci_conn_add+0x1c0/0x1d5 [blue=
tooth]
> [ =C2=A0722.477756] =C2=A0[<f8b79360>] hci_connect+0x71/0x17d [blueto=
oth]
> [ =C2=A0722.477769] =C2=A0[<fa54162c>] l2cap_sock_connect+0x196/0x2c6=
 [l2cap]
> [ =C2=A0722.477782] =C2=A0[<c1246e3d>] kernel_connect+0xd/0x12
> [ =C2=A0722.477795] =C2=A0[<fa5df3c3>] rfcomm_dlc_open+0x14a/0x2d6 [r=
fcomm]
> [ =C2=A0722.477810] =C2=A0[<fa5e10fa>] ? rfcomm_tty_open+0x73/0x227 [=
rfcomm]
> [ =C2=A0722.477825] =C2=A0[<fa5e1130>] rfcomm_tty_open+0xa9/0x227 [rf=
comm]
> [ =C2=A0722.477836] =C2=A0[<c1022e3f>] ? default_wake_function+0x0/0x=
d
> [ =C2=A0722.477847] =C2=A0[<c1180c79>] tty_open+0x29e/0x399
> [ =C2=A0722.477858] =C2=A0[<c107e9bd>] chrdev_open+0x13f/0x156
> [ =C2=A0722.477868] =C2=A0[<c107b0d3>] __dentry_open+0x11b/0x20f
> [ =C2=A0722.477878] =C2=A0[<c107b261>] nameidata_to_filp+0x2c/0x43
> [ =C2=A0722.477888] =C2=A0[<c107e87e>] ? chrdev_open+0x0/0x156
> [ =C2=A0722.477898] =C2=A0[<c1084e9e>] do_filp_open+0x3c6/0x70a
> [ =C2=A0722.477910] =C2=A0[<c108d3e4>] ? alloc_fd+0xc8/0xd2
> [ =C2=A0722.477920] =C2=A0[<c108d3e4>] ? alloc_fd+0xc8/0xd2
> [ =C2=A0722.477930] =C2=A0[<c107aebc>] do_sys_open+0x4a/0xe7
> [ =C2=A0722.477940] =C2=A0[<c1002acc>] ? restore_all_notrace+0x0/0x18
> [ =C2=A0722.477950] =C2=A0[<c107af9b>] sys_open+0x1e/0x26
> [ =C2=A0722.477959] =C2=A0[<c1002a18>] sysenter_do_call+0x12/0x36
> [ =C2=A0729.658613] PPP BSD Compression module registered
> [ =C2=A0729.684789] PPP Deflate Compression module registered
>
> Any idea?
>
> Regards,
> Oliver
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluet=
ooth" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>



--=20
Regards
dave
