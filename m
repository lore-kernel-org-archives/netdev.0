From: Paul Menzel <pm.debian@googlemail.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network
 device stays down after resume
Date: Wed, 08 Feb 2012 16:28:37 +0100
Message-ID: <1328714917.3483.21.camel@mattotaupa>
References: <1326896138.29125.86.camel@mattotaupa>
	 <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa>
	 <1326901834.3271.8.camel@deadeye> <1328383563.20142.23.camel@mattotaupa>
	 <20120205175730.GA23604@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-gMJqZhbWv1sz/Ewo+iBk"
Cc: nic_swsd@realtek.com, 656331@bugs.debian.org,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54911 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639Ab2BHP2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 10:28:42 -0500
Received: by bkcjm19 with SMTP id jm19so615126bkc.19
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2012 07:28:41 -0800 (PST)
In-Reply-To: <20120205175730.GA23604@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gMJqZhbWv1sz/Ewo+iBk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Dear Francois,


thank you for your fast reply.


Am Sonntag, den 05.02.2012, 18:57 +0100 schrieb Francois Romieu:
> Paul Menzel <pm.debian@googlemail.com> :
> [http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D656331]
> > I experienced this problem (only) three times until now. If I remember
> > correctly the last time with 3.2.1. I still do not know how to reproduc=
e
> > this.
>=20
> (good PR, nice)
>=20
> An 'ethtool -d' and a 'mii-tool -v' of the device after a successful resu=
me
> and a failed one could help if it's a driver thing.

The problem has not shown up again until now so I only send the output
from the successful resume. Currently Linux version 3.2.4 is installed.
The following outputs are identical after startup and (a successful)
resume.

        $ sudo ethtool --version
        ethtool version 3.1
        $ sudo ethtool eth0 # The option `-d` does not exist.
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
        	Link detected: yes

        $ sudo mii-tool --version
        $Id: mii-tool.c,v 1.9 2006/09/27 20:59:18 ecki Exp $
        (Author: David Hinds based on Donald Becker's mii-diag)
        net-tools 1.60
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

> You may check if runtime power management is enabled or not, especially
> after a failed resume. See the /sys/devices/pci....:../....:..:..../power
> directory and its control, runtime_enabled and runtime_status files
> (control =3D on -> runtime PM disabled, see Documentation/power/runtime_p=
m.txt)

The document is online at [1].

For some reason the ethernet controller is not listed under
`/sys/devices`.

        $ lspci | grep RTL
        02:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL811=
1/8168B PCI Express Gigabit Ethernet controller (rev 01)
        $ lspci -n -s 02:00.0
        02:00.0 0200: 10ec:8168 (rev 01)
        $ ls /sys/devices/
        breakpoint  i2c-2  LNXSYSTM:00  pnp0      tracepoint
        cpu         i2c-3  pci0000:00   software  virtual
        i2c-1       i2c-4  platform     system

I use `/sys/bus/pci/devices` instead.

        $ more /sys/bus/pci/devices/0000\:02\:00.0/power/{control,runtime_e=
nabled,runtime_status}
        ::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/control
        ::::::::::::::
        on
        --More--(Next file: /sys/bus/pci/devices/0000:02:00.0/power/runtime=
_::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_enabled
        ::::::::::::::
        forbidden
        --More--(Next file: /sys/bus/pci/devices/0000:02:00.0/power/runtime=
_::::::::::::::
        /sys/bus/pci/devices/0000:02:00.0/power/runtime_status
        ::::::::::::::
        active

> If it is enabled and the link does not come up fast enough (5 s), runtime
> PM will suspend the device. It should not matter as long as the link is
> still present because the device should (TM) soon generate a power manage=
ment
> event. The latter not happening or the PME being ignored could explain
> the bug. If so, temporarily disabling runtime PM for your device after a
> failed resume instead of removing the module or the cable may be enough
> to recover the link. It's just a guess though.

So judging from the output above runtime power management is disabled
after a fresh boot and (a successful) resume and something else went
wrong.

I will report back as soon as I get a failed resume.

> Please stay with v3.2 or above in the meantime.

I will.


Thanks,

Paul


[1] http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dblob=
;f=3DDocumentation/power/runtime_pm.txt;h=3D4abe83e1045a4b38e85b05ebfeb3e8e=
62841a7f6;hb=3DHEAD

--=-gMJqZhbWv1sz/Ewo+iBk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAk8ylKUACgkQPX1aK2wOHVgL+QCdGsn9RbTZivO0TSTZky5OLx+5
jNUAn2DyribY5BOu+fj9JCTVxxxmur1d
=eGuU
-----END PGP SIGNATURE-----

--=-gMJqZhbWv1sz/Ewo+iBk--
