From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Sat, 7 Jul 2012 10:13:42 -0400 (EDT)
Message-ID: <2060381397.2115.1341670422805.JavaMail.root@mail.savoirfairelinux.com>
References: <20120706221102.GA14276@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>, netdev@vger.kernel.org,
	Nancy Lin <nancy.lin@smsc.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:57842 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab2GGONu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 10:13:50 -0400
In-Reply-To: <20120706221102.GA14276@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Mail original -----
> =C3=89meric Vigier <emeric.vigier@savoirfairelinux.com> :
> [...]
> > Yes, there are 16 bits wide according to smsc95xx.h.
> > But other smsc drivers define 32bit wide PHY regs. I made myself
> > believe
> > that smsc would use the same PHY for each ethernet chip.
>=20
> SMSC people would surely answer before I find the relevant datasheet.
>=20
> Anyway the PHY registers are accessed indirectly through the
> MII_{ADDR, DATA}
> registers and MII_DATA r/w mask is limited to the lower 16 bits.
>=20
> > So would something like s/32 * sizeof(u32)/PHY_SPECIAL *
> > sizeof(u16)/ solve the issue here?
>=20
> You would have to pack data[] as well. Or use u16 *.

I will check this out next week.

>=20
> > Concerning the ioctl, I found ethtool much easier to use. And I
> > believe
> > smsc9514 is a very popular chipset, so this could help others
> > debugging it.
>=20
> # mii-tool -vv e1000
> Using SIOCGMIIPHY=3D0x8947
> e1000: no autonegotiation, 10baseT-HD, link ok
>   registers for MII PHY 0:
>     1140 796d 0141 0c30 0de1 0021 0004 0000
>     0000 0200 0000 0000 0000 0000 0000 3000
>     0000 0000 0000 0000 0174 0000 0000 0000
>     4100 0000 000d 000f 0000 0000 0000 0000
>   product info: vendor 00:50:43, model 3 rev 0
>   basic mode:   autonegotiation enabled
>   basic status: autonegotiation complete, link ok
>   capabilities: 1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
>   10baseT-HD
>   advertising:  1000baseT-FD 100baseTx-FD 100baseTx-HD 10baseT-FD
>   10baseT-HD flow-control
>   link partner: 10baseT-HD
>=20
> It is not that bad for the first 32 PHY registers.

I didn't know about mii-tool. Thanks.

>=20
> [...]
> > Do you mean LTT? I am not familiar with it, I should have a look.
>=20
> Documentation/trace/ftrace.txt

ok

>=20
> [...]
> > I should change that in previous "for" loop as well I suppose?
>=20
> You may.

Thanks for your patience.

>=20
> --
> Ueimor
>=20

--=20
Emeric
