From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: tg3 adapter losing link - PM related?
Date: Fri, 3 May 2013 21:28:44 +0200
Message-ID: <20130503192844.GA4975@nik-comp.linuxbox.cz>
References: <20130503092846.GA5126@pcnci.linuxbox.cz>
 <5183D40B.8090605@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: netdev@vger.kernel.org
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:32900 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763434Ab3ECT2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 15:28:40 -0400
Content-Disposition: inline
In-Reply-To: <5183D40B.8090605@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Nithin,

On Fri, May 03, 2013 at 08:13:15AM -0700, Nithin Nayak Sujir wrote:
> Hi Nikola,
> 1. What device is present on this server? Can you give the tg3 messages in
> /var/log/messages? Can you also give the output of "ethtool -i <iface>"?

sure, here it goes:

[  +0.273255] tg3.c:v3.119 (May 18, 2011)
[  +0.000184] tg3 0000:03:00.0: PCI INT A -> GSI 32 (level, low) -> IRQ 32
[  +0.000175] tg3 0000:03:00.0: setting latency timer to 64
[  +0.034616] tg3 0000:03:00.0: eth0: Tigon3 [partno(none) rev 5719001] (PC=
I Express) MAC address 2c:76:8a:52:a5:1c
[  +0.000255] tg3 0000:03:00.0: eth0: attached PHY is 5719C (10/100/1000Bas=
e-T Ethernet) (WireSpeed[1], EEE[1])
[  +0.000251] tg3 0000:03:00.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[1] TSOcap[0]
[  +0.000251] tg3 0000:03:00.0: eth0: dma_rwctrl[00000001] dma_mask[64-bit]


[root@atlovav1a ~]# ethtool -i eth0
driver: tg3
version: 3.119
firmware-version: 5719-v1.29 NCSI v1.0.88.0
bus-info: 0000:03:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

the box is HP ProLiant DL360p, device identifies itself in lspci as Broadco=
m Corporation NetXtreme BCM5719


>=20
> 2. Is it possible for you to try the latest 3.9 upstream kernel?

of course, It's compiling now. I'll report how it behaves.

>=20
> 3. Any reason why the link is at 100Mb? The switch does not support gig?
> What switch is it?

it's some lowcost cisco, not sure whether it's gigabit capable.. I'll find =
out on monday
and report if it's important.

>=20
> 4. I don't think you can turn off EEE in the bios, but you can try turning
> autoneg off. Try "ethtool -s <iface> speed 100 duplex full autoneg off".
> It's not exactly the same thing since the device still has EEE enabled but
> not negotiated.

forcing speed helped, I no longer see link going down!=20

of course I'll report about 3.9 kernel too..

thanks for Your reply!

nik

>=20
> Nithin.
>=20
>=20
> On 5/3/2013 2:28 AM, Nikola Ciprich wrote:
> >Hello,
> >
> >I'd like to ask about trouble I've got with new HP server: tg3 adapter k=
eeps losing
> >link every few minutes:
> >
> >Aug  3 03:58:02 atlovav1a kernel: [616741.147598] tg3 0000:03:00.0: eth0=
: Link is down
> >Aug  3 03:58:04 atlovav1a kernel: [616743.943456] tg3 0000:03:00.0: eth0=
: Link is up at 100 Mbps, full duplex
> >Aug  3 03:58:04 atlovav1a kernel: [616743.943598] tg3 0000:03:00.0: eth0=
: Flow control is on for TX and on for RX
> >Aug  3 03:58:04 atlovav1a kernel: [616743.943736] tg3 0000:03:00.0: eth0=
: EEE is enabled
> >Aug  3 04:14:29 atlovav1a kernel: [617727.980487] tg3 0000:03:00.0: eth0=
: Link is down
> >Aug  3 04:14:32 atlovav1a kernel: [617730.847245] tg3 0000:03:00.0: eth0=
: Link is up at 100 Mbps, full duplex
> >Aug  3 04:14:32 atlovav1a kernel: [617730.847387] tg3 0000:03:00.0: eth0=
: Flow control is on for TX and on for RX
> >Aug  3 04:14:32 atlovav1a kernel: [617730.847525] tg3 0000:03:00.0: eth0=
: EEE is enabled
> >Aug  3 06:47:13 atlovav1a kernel: [626885.452974] tg3 0000:03:00.0: eth0=
: Link is down
> >Aug  3 06:47:15 atlovav1a kernel: [626888.218702] tg3 0000:03:00.0: eth0=
: Link is up at 100 Mbps, full duplex
> >Aug  3 06:47:15 atlovav1a kernel: [626888.218844] tg3 0000:03:00.0: eth0=
: Flow control is on for TX and on for RX
> >Aug  3 06:47:15 atlovav1a kernel: [626888.218982] tg3 0000:03:00.0: eth0=
: EEE is enabled
> >Aug  3 06:51:44 atlovav1a kernel: [627156.293386] tg3 0000:03:00.0: eth0=
: Link is down
> >Aug  3 06:51:46 atlovav1a kernel: [627159.123347] tg3 0000:03:00.0: eth0=
: Link is up at 100 Mbps, full duplex
> >Aug  3 06:51:46 atlovav1a kernel: [627159.123491] tg3 0000:03:00.0: eth0=
: Flow control is on for TX and on for RX
> >Aug  3 06:51:46 atlovav1a kernel: [627159.123629] tg3 0000:03:00.0: eth0=
: EEE is enabled
> >Aug  3 07:13:10 atlovav1a kernel: [628441.722197] tg3 0000:03:00.0: eth0=
: Link is down
> >Aug  3 07:13:13 atlovav1a kernel: [628444.615548] tg3 0000:03:00.0: eth0=
: Link is up at 100 Mbps, full duplex
> >Aug  3 07:13:13 atlovav1a kernel: [628444.615690] tg3 0000:03:00.0: eth0=
: Flow control is on for TX and on for RX
> >Aug  3 07:13:13 atlovav1a kernel: [628444.615828] tg3 0000:03:00.0: eth0=
: EEE is enabled
> >
> >I can't exclude the possibility it's switch problem, but I don't have ac=
cess to box now and the
> >switch is not managed, so I'd like to try other ways first..
> >
> >Could this somehow be power management related? I don't see what else PM=
-related could I disable
> >in the bios to disable this EEE stuff.. Didn't anyone met similar proble=
m?
> >
> >the system is running Centos6 with x86_64 3.0.76 kernel
> >
> >thanks in advance for any reply
> >
> >BR
> >
> >nik
> >
> >
>=20

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28. rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799

www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlGED+wACgkQ3xdJJrLygV7n1ACeOeo0Zfw56pAcc8wXIGIHvhQC
EoEAn26+bi1kHDa7Im6rLZxRbvg63+zM
=Q4Uo
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
