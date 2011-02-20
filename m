From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix unreg list corruption in dev_deactivate()
Date: Sun, 20 Feb 2011 13:11:30 +0100
Message-ID: <1298203890.8559.54.camel@edumazet-laptop>
References: <20110220113429.GA27047@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stanislaw Gruszka <stf_xl@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42074 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab1BTMLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 07:11:47 -0500
Received: by fxm17 with SMTP id 17so648328fxm.19
        for <netdev@vger.kernel.org>; Sun, 20 Feb 2011 04:11:46 -0800 (PST)
In-Reply-To: <20110220113429.GA27047@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 f=C3=A9vrier 2011 =C3=A0 12:34 +0100, Stanislaw Gruszka =
a =C3=A9crit :
> Patch fix issue introduced by 443457242beb6716b43db4d62fe148eab551550=
5=20
> "net: factorize sync-rcu call in unregister_netdevice_many". It manif=
est
> on my system by following warning when removing usb wireless device.
>=20
> [ 3539.368139] WARNING: at lib/list_debug.c:53 __list_del_entry+0x62/=
0x71()
> [ 3539.368149] list_del corruption. prev->next should be f035e05c, bu=
t was f1ce670c
> [ 3539.368242] Call Trace:
> [ 3539.368254]  [<c04393d7>] ? warn_slowpath_common+0x6a/0x7f
> [ 3539.368262]  [<c05bd062>] ? __list_del_entry+0x62/0x71
> [ 3539.368269]  [<c043945f>] ? warn_slowpath_fmt+0x2b/0x2f
> [ 3539.368276]  [<c05bd062>] ? __list_del_entry+0x62/0x71
> [ 3539.368286]  [<c06f6d06>] ? unregister_netdevice_queue+0x41/0x6e
> [ 3539.368322]  [<fa1ee998>] ? ieee80211_remove_interfaces+0x7b/0x9a =
[mac80211]
> [ 3539.368348]  [<fa1e208a>] ? ieee80211_unregister_hw+0x48/0xf9 [mac=
80211]
> [ 3539.368363]  [<fa223903>] ? rt2x00lib_remove_dev+0x76/0xd1 [rt2x00=
lib]
> [ 3539.368372]  [<fa2770b1>] ? rt2x00usb_disconnect+0x29/0x8c [rt2x00=
usb]
> [ 3539.368382]  [<c069ef8c>] ? usb_unbind_interface+0x48/0xfd
>=20
> I'm no longer seeing warning with patch applied.
>=20
> Signed-off-by: Stanislaw Gruszka <stf_xl@wp.pl>
> ---
> I did not try review related code. I think someone who understand it,
> should audit it carefully to exclude similar issues. Adding
> dev->unreg_list to various local list, when device will not gonna be
> destroyed looks really fishy.
>=20
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 34dc598..1bc6980 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -839,6 +839,7 @@ void dev_deactivate(struct net_device *dev)
> =20
>  	list_add(&dev->unreg_list, &single);
>  	dev_deactivate_many(&single);
> +	list_del(&single);
>  }
> =20
>  static void dev_init_scheduler_queue(struct net_device *dev,


Hmm, you should read Eric B patch, he already addressed this problem a
few hours ago.

A full audit _is_ needed.

https://lkml.org/lkml/2011/2/20/4



