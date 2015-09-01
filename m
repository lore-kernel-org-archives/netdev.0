From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: fix device deletion order in mdiobus_unregister()
Date: Tue, 1 Sep 2015 06:55:02 -0700
Message-ID: <55E5AE36.7030906@gmail.com>
References: <1441114565-2340-1-git-send-email-msalter@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Daney <ddaney.cavm@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, buytenh@wantstofly.org,
	grant.likely@secretlab.ca
To: Mark Salter <msalter@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441114565-2340-1-git-send-email-msalter@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/01/15 06:36, Mark Salter a =C3=A9crit :
> commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, n=
ot
> the bus' parent.") uncovered a problem in mdiobus_unregister() which
> leads to this warning when I reboot an APM Mustang (arm64) platform:
>=20
>   WARNING: CPU: 7 PID: 4239 at fs/sysfs/group.c:224 sysfs_remove_grou=
p+0xa0/0xa4()
>   sysfs group fffffe0000e07a10 not found for kobject 'xgene-mii-eth0:=
03'
>   ...
>   CPU: 7 PID: 4239 Comm: reboot Tainted: G            E   4.2.0-0.18.=
el7.test15.aarch64 #1
>   Hardware name: AppliedMicro Mustang/Mustang, BIOS 1.1.0 Aug 26 2015
>   Call Trace:
>   [<fffffe000009739c>] dump_backtrace+0x0/0x170
>   [<fffffe000009752c>] show_stack+0x20/0x2c
>   [<fffffe00007436f0>] dump_stack+0x78/0x9c
>   [<fffffe00000c2cb4>] warn_slowpath_common+0xa0/0xd8
>   [<fffffe00000c2d60>] warn_slowpath_fmt+0x74/0x88
>   [<fffffe0000293d3c>] sysfs_remove_group+0x9c/0xa4
>   [<fffffe00004a8bac>] dpm_sysfs_remove+0x5c/0x70
>   [<fffffe000049b388>] device_del+0x44/0x208
>   [<fffffe000049b578>] device_unregister+0x2c/0x7c
>   [<fffffe000050dc68>] mdiobus_unregister+0x48/0x94
>   [<fffffe000052afd0>] xgene_enet_mdio_remove+0x28/0x44
>   [<fffffe000052d3f0>] xgene_enet_remove+0xd0/0xd8
>   [<fffffe000052d424>] xgene_enet_shutdown+0x2c/0x3c
>   [<fffffe00004a204c>] platform_drv_shutdown+0x24/0x40
>   [<fffffe000049d4f4>] device_shutdown+0xf0/0x1b4
>   [<fffffe00000e31ec>] kernel_restart_prepare+0x40/0x4c
>   [<fffffe00000e32f8>] kernel_restart+0x1c/0x80
>   [<fffffe00000e3670>] SyS_reboot+0x17c/0x250
>=20
> The problem is that mdiobus_unregister() deletes the bus device befor=
e
> unregistering the phy devices on the bus. This wasn't a problem befor=
e
> because the phys were not children of the bus:
>=20
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0:03
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0
>=20
> But now that they are:
>=20
>   /sys/devices/platform/APMC0D05:00/net/eth0/xgene-mii-eth0/xgene-mii=
-eth0:03
>=20
> when mdiobus_unregister deletes the bus device, the phy subdirs are
> removed from sysfs also. So when the phys are unregistered afterward,
> we get the warning. This patch changes the order so that phys are
> unregistered before the bus device is deleted.
>=20
> Signed-off-by: Mark Salter <msalter@redhat.com>

=46ixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, n=
ot
the bus' parent.")
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
--=20
=46lorian
