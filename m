From: Dieter =?iso-8859-15?q?N=FCtzel?= <Dieter.Nuetzel@hamburg.de>
Subject: Re: [PATCH] Fix kernel lockup in RTL-8169 gigabit ethernet driver
Date: Tue, 6 Apr 2004 01:08:19 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200404060108.19488.Dieter.Nuetzel@hamburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Andrew Morton <akpm@osd.org>,
	Manfred Spraul <manfred@colorfullife.com>, netdev@oss.sgi.com,
	jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "Linux-Kernel List" <linux-kernel@vger.kernel.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

=46rancois Romieu <romieu@fr.zoreil.com> wrote:
> Manfred Spraul <manfred@colorfullife.com> :
> [...]
> > tx_left counts packets submitted by hard_xmit_start to the hardware=
=2E=20
> > Initially OWNbit is set, the packet is owned by the nic. The OWNbit=
 is=20
> > cleared by the hardware after the packet was sent. A packet with OW=
Nbit=20
> > set means that the nic didn't send it yet to the wire. I think the =
"else=20
> > break;" patch is correct, but someone with docs should confirm that=
=2E
>=20
> Realtek Gigabit Ethernet Media Access Controller with power managemen=
t R8169
> Rev.1.21, p.54
> [...]
> Ownership: This bit, when set, indicates that the descriptor is owned=
 by
> the NIC. When cleared, it indicates that the descriptor is owned by t=
he host
> system. NIC clears this bit when the relative buffer data is already
> transmitted. In this case, OWN=3D0.
>=20
> [...]
> > Perhaps gcc optimized away the reload from memory and loops on a=20
>=20
> Point taken.

Isn't the "current" RTL8169s (32/64) driver much outdated?

I got a version # 1.6 with all my cards.
Anyone what a copy?

/*
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
 r8169.c: A RealTek RTL8169s/8110s Gigabit Ethernet driver for Linux ke=
rnel=20
2.4.x.
 --------------------------------------------------------------------

 History:
 Feb  4 2002	- created initially by ShuChen <shuchen@realtek.com.tw>.
 May 20 2002	- Add link status force-mode and TBI mode support.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  1. The media can be forced in 5 modes.
	 Command: 'insmod r8169 media =3D SET_MEDIA'
	 Ex:	  'insmod r8169 media =3D 0x04' will force PHY to operate in 100M=
pbs=20
Half-duplex.

	 SET_MEDIA can be:
 		_10_Half	=3D 0x01
 		_10_Full	=3D 0x02
 		_100_Half	=3D 0x04
 		_100_Full	=3D 0x08
 		_1000_Full	=3D 0x10

  2. Support TBI mode.
//=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
RTL8169_VERSION "1.1"	<2002/10/4>

	The bit4:0 of MII register 4 is called "selector field", and have to b=
e
	00001b to indicate support of IEEE std 802.3 during NWay process of
	exchanging Link Code Word (FLP).

RTL8169_VERSION "1.2"	<2003/6/17>
	Update driver module name.
	Modify ISR.
        Add chip mac_version.

RTL8169_VERSION "1.3"	<2003/6/20>
        Add chip phy_version.
	Add priv->phy_timer_t, rtl8169_phy_timer_t_handler()
	Add rtl8169_hw_PHY_config()
	Add rtl8169_hw_PHY_reset()

RTL8169_VERSION "1.4"	<2003/7/14>
	Add tx_bytes, rx_bytes.

RTL8169_VERSION "1.5"	<2003/7/18>
	Set 0x0000 to PHY at offset 0x0b.
	Modify chip mac_version, phy_version
	Force media for multiple card.
RTL8169_VERSION "1.6"	<2003/8/25>
	Modify receive data buffer.
*/

Greetings,
	Dieter


--=20
Dieter N=FCtzel
@home: <Dieter.Nuetzel () hamburg ! de>
