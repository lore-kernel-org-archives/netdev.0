From: Frank v Waveren <fvw@var.cx>
Subject: forcedeth gigabit detection
Date: Mon, 7 Aug 2006 17:42:35 +0200
Message-ID: <20060807154235.GA26603@var.cx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: c-d.hailfinger.kernel.2004@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-230-146.dsl.uva.nl ([146.50.230.146]:58024 "EHLO
	hypnos.var.cx") by vger.kernel.org with ESMTP id S932171AbWHGPmh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 11:42:37 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

(sorry about sending this to you twice Carl-Daniel, I sent this to
@oss.sgi.com by accident)

The nforce2 builtin network on my A7N8X-delux motherboard won't detect
as gigabit-capable using the forcedeth driver.=20

I'm using the forcedeth driver that comes with linux 2.6.17 (which is
0.54).

Ethtool gives:
Settings for eth1:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: external
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Link detected: yes

I assume the supported link modes are those supported by the NIC, not
the link (It's a short piece of cat5 between the two cards (no
switch/hub), it should support gigabit but you never know)?

The odd thing is the NIC on the other side of the cable (which is also
a forcedeth from the nforce3 chipset) detects as:
Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Full=20
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 1
        Transceiver: externel
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Link detected: yes

Here's the debugging output from the forcedeth that won't do gigabit
on module load and bringing the interface up:
Aug  7 15:52:46 jupiter kernel: PCI: Setting latency timer of device 0000:0=
0:04.0 to 64
Aug  7 15:52:46 jupiter kernel: 0000:00:04.0: resource 0 start df083000 len=
 4096 flags 0x00000200.
Aug  7 15:52:46 jupiter kernel: 0000:00:04.0: MAC Address 00:0e:a6:0b:6f:73
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 2 at PHY 1: 0x=
0.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 3 at PHY 1: 0x=
8201.
Aug  7 15:52:46 jupiter kernel: 0000:00:04.0: open: Found PHY 0000:0020 at =
address 1.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 4 at PHY 1: 0x=
1e1.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw wrote 0xde1 to reg 4 at PHY 1
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 1 at PHY 1: 0x=
786d.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 0 at PHY 1: 0x=
3100.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw wrote 0xb100 to reg 0 at PHY=
 1
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 0 at PHY 1: 0x=
3000.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw read from reg 0 at PHY 1: 0x=
3000.
Aug  7 15:52:46 jupiter kernel: eth%%d: mii_rw wrote 0x3200 to reg 0 at PHY=
 1
Aug  7 15:53:03 jupiter kernel: nv_open: begin
Aug  7 15:53:03 jupiter kernel: eth1: nv_alloc_rx: Packet 0 marked as Avail=
able
=2E..
Aug  7 15:53:03 jupiter kernel: eth1: nv_alloc_rx: Packet 127 marked as Ava=
ilable
Aug  7 15:53:03 jupiter kernel: eth1: nv_txrx_reset
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 1 at PHY 1: 0x78=
6d.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 1 at PHY 1: 0x78=
6d.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 4 at PHY 1: 0x1e=
1.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 5 at PHY 1: 0xc5=
e1.
Aug  7 15:53:03 jupiter kernel: eth1: nv_update_linkspeed: PHY advertises 0=
x01e1, lpa 0xc5e1.
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_tx
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_stop_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_rx to duplex 1, speed 0x0001=
0064.
Aug  7 15:53:03 jupiter kernel: eth1: nv_nic_irq
Aug  7 15:53:03 jupiter kernel: eth1: irq: 00000020
Aug  7 15:53:03 jupiter kernel: eth1: nv_rx_process: looking at packet 128,=
 Flags 0x8000061c.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 1 at PHY 1: 0x78=
6d.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 1 at PHY 1: 0x78=
6d.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 4 at PHY 1: 0x1e=
1.
Aug  7 15:53:03 jupiter kernel: eth1: mii_rw read from reg 5 at PHY 1: 0xc5=
e1.
Aug  7 15:53:03 jupiter kernel: eth1: nv_update_linkspeed: PHY advertises 0=
x01e1, lpa 0xc5e1.
Aug  7 15:53:03 jupiter kernel: eth1: irq: 00000000
Aug  7 15:53:03 jupiter kernel: eth1: nv_nic_irq completed
Aug  7 15:53:03 jupiter kernel: eth1: nv_start_xmit: packet 0 (entries 1) q=
ueued for transmission. tx_flags_extra: 0
Aug  7 15:53:03 jupiter kernel: eth1: nv_nic_irq
Aug  7 15:53:03 jupiter kernel: eth1: irq: 00000010
Aug  7 15:53:03 jupiter kernel: eth1: nv_tx_done: looking at packet 0, Flag=
s 0x1005e.
Aug  7 15:53:03 jupiter kernel: eth1: nv_rx_process: looking at packet 128,=
 Flags 0x8000061c.
Aug  7 15:53:03 jupiter kernel: eth1: irq: 00000000
Aug  7 15:53:03 jupiter kernel: eth1: nv_nic_irq completed
Aug  7 15:53:03 jupiter kernel: eth1: nv_nic_irq
Aug  7 15:53:03 jupiter kernel: eth1: irq: 00000020

I haven't tried the old closed-source nvnet driver yet as it won't
compile with gcc 4, but I can get an older gcc and recompile
the kernel if necessary.

I'd be most grateful for any advice you might have on getting things
working, if anyone needs any further information please let me know.

--=20
Frank v Waveren                                  Key fingerprint: BDD7 D61E
fvw@var.cx                                              5D39 CF05 4BFC F57A
Public key: hkp://wwwkeys.pgp.net/468D62C8              FA00 7D51 468D 62C8

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFE119r+gB9UUaNYsgRAg3RAJ91YsBpLxpfTf4VIz+bU/hGQs/xaQCfeCkK
jqWnbDzfdUUVdCX4dGa0Vko=
=B7AG
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
