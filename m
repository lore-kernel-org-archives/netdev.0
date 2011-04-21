From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] net: bnx2x: convert to hw_features
Date: Thu, 21 Apr 2011 16:52:11 +0200
Message-ID: <1303397531.3685.16.camel@edumazet-laptop>
References: <20110412144940.GA26043@rere.qmqm.pl>
	 <20110411202630.C079D13909@rere.qmqm.pl>
	 <1302610228.32697.298.camel@lb-tlvb-vladz>
	 <20110412140708.GA21835@rere.qmqm.pl>
	 <1302619012.6750.8.camel@lb-tlvb-vladz>
	 <20110412193823.0823213A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vladislav Zolotarov <vladz@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57530 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219Ab1DUOwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 10:52:16 -0400
Received: by wwa36 with SMTP id 36so2184343wwa.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2011 07:52:15 -0700 (PDT)
In-Reply-To: <20110412193823.0823213A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 21:38 +0200, Micha=C5=82 Miros=C5=82aw a =
=C3=A9crit :
> Since ndo_fix_features callback is postponing features change when
> bp->recovery_state !=3D BNX2X_RECOVERY_DONE, netdev_update_features()
> has to be called again when this condition changes. Previously,
> ethtool_ops->set_flags callback returned -EBUSY in that case
> (it's not possible in the new model).
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
>=20
> v5: - don't delay set_features, as it's rtnl_locked - same as recover=
y process
> v4: - complete bp->rx_csum -> NETIF_F_RXCSUM conversion
>     - add check for failed ndo_set_features in ndo_open callback
> v3: - include NETIF_F_LRO in hw_features
>     - don't call netdev_update_features() if bnx2x_nic_load() failed
> v2: - comment in ndo_fix_features callback
> ---

Hi guys

I am not sure its related to these changes, but I now have in
net-next-2.6 :

[   23.674263] ------------[ cut here ]------------
[   23.674266] WARNING: at net/core/dev.c:1318 dev_disable_lro+0x83/0x9=
0()
[   23.674270] Hardware name: ProLiant BL460c G6
[   23.674273] Modules linked in: tg3 libphy sg
[   23.674280] Pid: 3070, comm: sysctl Tainted: G        W   2.6.39-rc2=
-01242-g3ef22b9-dirty #669
[   23.674282] Call Trace:
[   23.674285]  [<ffffffff813b94f3>] ? dev_disable_lro+0x83/0x90
[   23.674291]  [<ffffffff81042c9b>] warn_slowpath_common+0x8b/0xc0
[   23.674298]  [<ffffffff81042ce5>] warn_slowpath_null+0x15/0x20
[   23.674304]  [<ffffffff813b94f3>] dev_disable_lro+0x83/0x90
[   23.674309]  [<ffffffff81429789>] devinet_sysctl_forward+0x199/0x210
[   23.674313]  [<ffffffff814296e4>] ? devinet_sysctl_forward+0xf4/0x21=
0
[   23.674318]  [<ffffffff8104e712>] ? capable+0x12/0x20
[   23.674324]  [<ffffffff81168f45>] proc_sys_call_handler+0xb5/0xd0
[   23.674328]  [<ffffffff81168f6f>] proc_sys_write+0xf/0x20
[   23.674334]  [<ffffffff81105f39>] vfs_write+0xc9/0x170
[   23.674339]  [<ffffffff81106550>] sys_write+0x50/0x90
[   23.674345]  [<ffffffff814b95a0>] sysenter_dispatch+0x7/0x33
[   23.674350] ---[ end trace 051ec497c66b228e ]---

Thanks


