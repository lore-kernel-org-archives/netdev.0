From: Paul Menzel <pm.debian@googlemail.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network
 device stays down after resume
Date: Wed, 08 Feb 2012 20:47:09 +0100
Message-ID: <1328730429.3483.35.camel@mattotaupa>
References: <1326896138.29125.86.camel@mattotaupa>
	 <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa>
	 <1326901834.3271.8.camel@deadeye> <1328383563.20142.23.camel@mattotaupa>
	 <20120205175730.GA23604@electric-eye.fr.zoreil.com>
	 <1328714917.3483.21.camel@mattotaupa>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-2pNpPFwkbFCUyEgTo3yK"
Cc: nic_swsd@realtek.com, 656331@bugs.debian.org,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44283 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756773Ab2BHTrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:47:15 -0500
Received: by bkcjm19 with SMTP id jm19so928453bkc.19
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2012 11:47:13 -0800 (PST)
In-Reply-To: <1328714917.3483.21.camel@mattotaupa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2pNpPFwkbFCUyEgTo3yK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Am Mittwoch, den 08.02.2012, 16:28 +0100 schrieb Paul Menzel:

> Am Sonntag, den 05.02.2012, 18:57 +0100 schrieb Francois Romieu:
> > Paul Menzel <pm.debian@googlemail.com> :
> > [http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D656331]
> > > I experienced this problem (only) three times until now. If I remembe=
r
> > > correctly the last time with 3.2.1. I still do not know how to reprod=
uce
> > > this.
> >=20
> > (good PR, nice)
> >=20
> > An 'ethtool -d' and a 'mii-tool -v' of the device after a successful re=
sume
> > and a failed one could help if it's a driver thing.
>=20
> The problem has not shown up again until now so I only send the output
> from the successful resume. Currently Linux version 3.2.4 is installed.

Right on time a suspend cycle later the problem turned up again.

> The following outputs are identical after startup and (a successful)
> resume.
>=20
>         $ sudo ethtool --version
>         ethtool version 3.1
>         $ sudo ethtool eth0 # The option `-d` does not exist.
>         Settings for eth0:
>         	Supported ports: [ TP MII ]
>         	Supported link modes:   10baseT/Half 10baseT/Full=20
>         	                        100baseT/Half 100baseT/Full=20
>         	                        1000baseT/Half 1000baseT/Full=20
>         	Supported pause frame use: No
>         	Supports auto-negotiation: Yes
>         	Advertised link modes:  10baseT/Half 10baseT/Full=20
>         	                        100baseT/Half 100baseT/Full=20
>         	                        1000baseT/Half 1000baseT/Full=20
>         	Advertised pause frame use: Symmetric Receive-only
>         	Advertised auto-negotiation: Yes
>         	Link partner advertised link modes:  10baseT/Half 10baseT/Full=
=20
>         	                                     100baseT/Half 100baseT/Full=
=20
>         	Link partner advertised pause frame use: Symmetric
>         	Link partner advertised auto-negotiation: Yes
>         	Speed: 100Mb/s
>         	Duplex: Full
>         	Port: MII
>         	PHYAD: 0
>         	Transceiver: internal
>         	Auto-negotiation: on
>         	Supports Wake-on: pumbg
>         	Wake-on: g
>         	Current message level: 0x00000033 (51)
>         			       drv probe ifdown ifup
>         	Link detected: yes

Now from a failed resume.

        $ sudo ethtool eth0
        Settings for eth0:
        	Supported ports: [ TP MII ]
        	Supported link modes:   10baseT/Half 10baseT/Full=20
        	                        100baseT/Half 100baseT/Full=20
        	                        1000baseT/Half 1000baseT/Full=20
        	Supported pause frame use: No
        	Supports auto-negotiation: Yes
        	Advertised link modes:  10baseT/Half 10baseT/Full=20
        	                        100baseT/Half 100baseT/Full=20
        	                        1000baseT/Half 1000baseT/Full=20
        	Advertised pause frame use: Symmetric Receive-only
        	Advertised auto-negotiation: Yes
        	Link partner advertised link modes:  10baseT/Half 10baseT/Full=20
        	                                     100baseT/Half 100baseT/Full=
=20
        	Link partner advertised pause frame use: Symmetric
        	Link partner advertised auto-negotiation: Yes
        	Speed: 100Mb/s
        	Duplex: Full
        	Port: MII
        	PHYAD: 0
        	Transceiver: internal
        	Auto-negotiation: on
        	Supports Wake-on: pumbg
        	Wake-on: g
        	Current message level: 0x00000033 (51)
        			       drv probe ifdown ifup

I could not spot a difference.

>         $ sudo mii-tool --version
>         $Id: mii-tool.c,v 1.9 2006/09/27 20:59:18 ecki Exp $
>         (Author: David Hinds based on Donald Becker's mii-diag)
>         net-tools 1.60
>         $ sudo mii-tool -v
>         eth0: negotiated 100baseTx-FD flow-control, link ok
>           product info: vendor 00:07:32, model 17 rev 2
>           basic mode:   autonegotiation enabled
>           basic status: autonegotiation complete, link ok
>           capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-=
HD 10baseT-FD 10baseT-HD
>           advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD f=
low-control
>           link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-=
HD 10baseT-FD 10baseT-HD flow-control

=46rom a failed resume it looks like the following.

        $ sudo mii-tool -v
        eth0: negotiated 100baseTx-FD flow-control, link ok
          product info: vendor 00:07:32, model 17 rev 2
          basic mode:   autonegotiation enabled
          basic status: autonegotiation complete, link ok
          capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD=
 10baseT-FD 10baseT-HD
          advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flo=
w-control
          link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD=
 10baseT-FD 10baseT-HD flow-control

This seems to be identical too.

> > You may check if runtime power management is enabled or not, especially
> > after a failed resume. See the /sys/devices/pci....:../....:..:..../pow=
er
> > directory and its control, runtime_enabled and runtime_status files
> > (control =3D on -> runtime PM disabled, see Documentation/power/runtime=
_pm.txt)
>=20
> The document is online at [1].
>=20
> For some reason the Ethernet controller is not listed under
> `/sys/devices`.
>=20
>         $ lspci | grep RTL
>         02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8=
111/8168B PCI Express Gigabit Ethernet controller (rev 01)
>         $ lspci -n -s 02:00.0
>         02:00.0 0200: 10ec:8168 (rev 01)
>         $ ls /sys/devices/
>         breakpoint  i2c-2  LNXSYSTM:00  pnp0      tracepoint
>         cpu         i2c-3  pci0000:00   software  virtual
>         i2c-1       i2c-4  platform     system
>=20
> I use `/sys/bus/pci/devices` instead.
>=20
>         $ more /sys/bus/pci/devices/0000\:02\:00.0/power/{control,runtime=
_enabled,runtime_status}
>         ::::::::::::::
>         /sys/bus/pci/devices/0000:02:00.0/power/control
>         ::::::::::::::
>         on
>         --More--(Next file: /sys/bus/pci/devices/0000:02:00.0/power/runti=
me_::::::::::::::
>         /sys/bus/pci/devices/0000:02:00.0/power/runtime_enabled
>         ::::::::::::::
>         forbidden
>         --More--(Next file: /sys/bus/pci/devices/0000:02:00.0/power/runti=
me_::::::::::::::
>         /sys/bus/pci/devices/0000:02:00.0/power/runtime_status
>         ::::::::::::::
>         active

=46rom a failed resume the output is like the following.

        $ more /sys/bus/pci/devices/0000\:02\:00.0/power/{control,runtime_e=
nabled,runtime_status}
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/control
        ::::::::::::::
        on
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_enabled
        ::::::::::::::
        forbidden
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_status
        ::::::::::::::
        active

This also seems identical.

> > If it is enabled and the link does not come up fast enough (5 s), runti=
me
> > PM will suspend the device. It should not matter as long as the link is
> > still present because the device should (TM) soon generate a power mana=
gement
> > event. The latter not happening or the PME being ignored could explain
> > the bug. If so, temporarily disabling runtime PM for your device after =
a
> > failed resume instead of removing the module or the cable may be enough
> > to recover the link. It's just a guess though.
>=20
> So judging from the output above runtime power management is disabled
> after a fresh boot and (a successful) resume and something else went
> wrong.
>=20
> I will report back as soon as I get a failed resume.

Unfortunately I was not able to change the control parameter and always
got =C2=BBThe argument is invalid.=C2=AB as an response.

        # echo off > /sys/bus/pci/devices/0000:02:00.0/power/control
        bash: echo: Schreibfehler: Das Argument ist ung=C3=BCltig.
        # echo 1 > /sys/bus/pci/devices/0000:02:00.0/power/control
        bash: echo: Schreibfehler: Das Argument ist ung=C3=BCltig.
        # echo 0 > /sys/bus/pci/devices/0000:02:00.0/power/control
        bash: echo: Schreibfehler: Das Argument ist ung=C3=BCltig.

Here are now some more values and outputs from a failed resume. Maybe
they are useful.

        $ more /sys/bus/pci/devices/0000:02:00.0/power/runtime_*
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_active_kids
        ::::::::::::::
        0
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_active_time
        ::::::::::::::
        19474892
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_enabled
        ::::::::::::::
        forbidden
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_status
        ::::::::::::::
        active
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_suspended_time
        ::::::::::::::
        0
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_usage
        ::::::::::::::
        1

Now when the module was reloaded.

        $ more /sys/bus/pci/devices/0000:02:00.0/power/runtime_*
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_active_kids
        ::::::::::::::
        0
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_active_time
        ::::::::::::::
        20478940
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_enabled
        ::::::::::::::
        forbidden
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_status
        ::::::::::::::
        active
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_suspended_time
        ::::::::::::::
        0
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_usage
        ::::::::::::::
        1

Here is the output from `dmesg`.

        $ dmesg | grep 8169
        [    1.208236] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
        [    1.208291] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)=
 -> IRQ 19
        [    1.208328] r8169 0000:02:00.0: setting latency timer to 64
        [    1.208388] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
        [    1.208944] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc9=
0000324000, 00:1e:8c:aa:1d:b5, XID 18000000 IRQ 41
        [    1.208949] r8169 0000:02:00.0: eth0: jumbo features [frames: 40=
80 bytes, tx checksumming: ko]
        [  102.065361] r8169 0000:02:00.0: eth0: link down
        [  102.065378] r8169 0000:02:00.0: eth0: link down
        [  104.172037] r8169 0000:02:00.0: eth0: link up
       =20
I am not sure why the above is there. Maybe due to some package upgrades.
       =20
        # Successful resume.
       =20
        [10395.370894] r8169 0000:02:00.0: eth0: link down
        [10395.761847] r8169 0000:02:00.0: PME# enabled
        [10395.909944] r8169 0000:02:00.0: restoring config space at offset=
 0xf (was 0x100, writing 0x10a)
        [10395.909960] r8169 0000:02:00.0: restoring config space at offset=
 0x6 (was 0x4, writing 0xfdaff004)
        [10395.909967] r8169 0000:02:00.0: restoring config space at offset=
 0x4 (was 0x1, writing 0xdc01)
        [10395.909972] r8169 0000:02:00.0: restoring config space at offset=
 0x3 (was 0x0, writing 0x8)
        [10395.909979] r8169 0000:02:00.0: restoring config space at offset=
 0x1 (was 0x100000, writing 0x100407)
        [10395.910580] r8169 0000:02:00.0: PME# disabled
        [10395.928147] r8169 0000:02:00.0: eth0: link down
        [10397.978212] r8169 0000:02:00.0: eth0: link up
       =20
        # Failed resume.
       =20
        [18764.809975] r8169 0000:02:00.0: PME# enabled
        [18764.957890] r8169 0000:02:00.0: restoring config space at offset=
 0xf (was 0x100, writing 0x10a)
        [18764.957906] r8169 0000:02:00.0: restoring config space at offset=
 0x6 (was 0x4, writing 0xfdaff004)
        [18764.957913] r8169 0000:02:00.0: restoring config space at offset=
 0x4 (was 0x1, writing 0xdc01)
        [18764.957918] r8169 0000:02:00.0: restoring config space at offset=
 0x3 (was 0x0, writing 0x8)
        [18764.957925] r8169 0000:02:00.0: restoring config space at offset=
 0x1 (was 0x100000, writing 0x100407)
        [18764.958557] r8169 0000:02:00.0: PME# disabled
        [18781.998004] r8169 0000:02:00.0: eth0: link down
        [18781.998024] r8169 0000:02:00.0: eth0: link down
       =20
        # Reloading the module.
       =20
        [19589.784094] r8169 0000:02:00.0: PCI INT A disabled
        [19592.483547] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
        [19592.483618] r8169 0000:02:00.0: PCI INT A -> GSI 19 (level, low)=
 -> IRQ 19
        [19592.483689] r8169 0000:02:00.0: setting latency timer to 64
        [19592.483783] r8169 0000:02:00.0: irq 41 for MSI/MSI-X
        [19592.485394] r8169 0000:02:00.0: eth0: RTL8168b/8111b at 0xffffc9=
0000324000, 00:1e:8c:aa:1d:b5, XID 18000000 IRQ 41
        [19592.485404] r8169 0000:02:00.0: eth0: jumbo features [frames: 40=
80 bytes, tx checksumming: ko]
        [19592.913672] r8169 0000:02:00.0: eth0: link down
        [19594.947829] r8169 0000:02:00.0: eth0: link up


> > Please stay with v3.2 or above in the meantime.
>=20
> I will.


Thanks,

Paul


> [1] http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dbl=
ob;f=3DDocumentation/power/runtime_pm.txt;h=3D4abe83e1045a4b38e85b05ebfeb3e=
8e62841a7f6;hb=3DHEAD

--=-2pNpPFwkbFCUyEgTo3yK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEUEABECAAYFAk8y0T0ACgkQPX1aK2wOHVgIPgCY6UzBml9EfAnvHw2mvudR6bTx
dgCfVtxH6UkW5chpZhDpecKihLbeYVg=
=mNxF
-----END PGP SIGNATURE-----

--=-2pNpPFwkbFCUyEgTo3yK--
