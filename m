From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Thu, 16 Feb 2012 05:19:23 +0100
Message-ID: <1329365963.2469.8.camel@edumazet-laptop>
References: <20120215163748.GA3998@elliptictech.com>
	 <20120215224122.GA31463@electric-eye.fr.zoreil.com>
	 <20120215233408.GA8389@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64326 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab2BPETa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 23:19:30 -0500
Received: by wgbgn7 with SMTP id gn7so279030wgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 20:19:29 -0800 (PST)
In-Reply-To: <20120215233408.GA8389@elliptictech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 18:34 -0500, Nick Bowler a =C3=A9=
crit :
> On 2012-02-15 23:41 +0100, Francois Romieu wrote:
> > Nick Bowler <nbowler@elliptictech.com> :
> > [...]
> > > Let me know if you need any more info,
> >=20
> > Please send the XID line from the r8169 driver for this device.
>=20
> This one?
>=20
>   [   10.344571] r8169 0000:02:00.0: eth0: RTL8168d/8111d at 0xf80640=
00, bc:ae:c5:27:19:6f, XID 083000c0 IRQ 41
>=20
> > Did you enable some offload feature (see 'ethtool -k') ?
>=20
> Not beyond the defaults as far as I know.  Here's the ethtool -k outp=
ut:
>=20
>   Offload parameters for p10p1:
>   rx-checksumming: on
>   tx-checksumming: off
>   scatter-gather: off
>   tcp-segmentation-offload: off
>   udp-fragmentation-offload: off
>   generic-segmentation-offload: off
>   generic-receive-offload: on
>   large-receive-offload: off
>   rx-vlan-offload: on
>   tx-vlan-offload: on
>   ntuple-filters: off
>   receive-hashing: off
>=20
> Thanks,

1) Are you using SLUB, SLAB, or SLOB ?

2) Problem with MTU=3D9000 is that frames span several 4K pages.

Maybe some versions of r8169 hardware have problems with that ...

3) We could check in xmit handler if the frames are correct before
sending them.  (Adding a trace of ICMP frames, and check if the payload
is all 0x42 filler or not)=20
