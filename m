From: Marek Vasut <marek.vasut@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Sat, 22 Aug 2009 00:54:31 +0200
Message-ID: <200908220054.31438.marek.vasut@gmail.com>
References: <200907240257.10906.marek.vasut@gmail.com> <a4423d670907290416h4a0796c2s665d3f8ca0755e67@mail.gmail.com> <200908051602.34501.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Miao <eric.y.miao@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	samuel@sortiz.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:33018 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390AbZHUWyx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 18:54:53 -0400
Received: by fxm17 with SMTP id 17so688928fxm.37
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 15:54:54 -0700 (PDT)
In-Reply-To: <200908051602.34501.marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne St 5. srpna 2009 16:02:34 Marek Vasut napsal(a):
> Dne St 29. =C4=8Dervence 2009 13:16:25 Alexander Beregalov napsal(a):
> > 2009/7/28 Eric Miao <eric.y.miao@gmail.com>:
> > > Marek Vasut wrote:
> > >> Hi!
> > >>
> > >> This patch fixes broken pxaficp-ir. The problem was in incorrect
> > >> net_device_ops being specified which prevented the driver from
> > >> operating. The symptoms were:
> > >>  - failing ifconfig for IrLAN, resulting in
> > >>       SIOCSIFFLAGS: Cannot assign requested address
> > >>  - irattach working for IrCOMM, but the port stayed disabled
> > >>
> > >> Moreover this patch corrects missing sysfs device link.
> > >>
> > >> btw. guys, be honest, when did you last tested pxaficp-ir on rea=
l
> > >> hardware? ;-)
> > >
> > > Well, this seems to be brought by the net_device_ops change, whic=
h
> > > seems to happen silently without any of us being notified.
> > >
> > > OK, netdev and Alex are copied, so that we can look into this iss=
ue a
> > > bit deeper:
> > >
> > > 1. it looks to me that SIOCSIFFLAGS actually returned -EADDRNOTAV=
AIL,
> > > which is likely caused by eth_validate_addr, the default eth_addr=
 comes
> > > with irda should be "00:00:00:00:00:00" if not explicitly specifi=
ed
> > > (kzalloc), and this should be the problem, solution ?  Either giv=
e a
> > > valid address to the irda net_device or remove this
> > > 'ndo_validate_addr'. And which is a correct fix will impact on th=
e
> > > .ndo_set_mac_address
> > >
> > > 2. '.ndo_change_mtu' ? It looks to me that Irda device doesn't ca=
re too
> > > much about the MTU, eth_change_mtu is supposed to work just fine =
and
> > > not to cause any side effects, and may just benefit later irda de=
vice
> > > drivers if there is a weird device happens to care about MTU
> > >
> > > - eric
> > >
> > > Marek's original patch in attachment.
> >
> > Sorry about that and thanks.
> > Then we should fix the rest of irda drivers in the same way.
>
> Hi!
> Was my patch applied or what's the current status? Thanks

Hi!
any updates ? Are we letting this into .32 in current broken state?

Thanks!
