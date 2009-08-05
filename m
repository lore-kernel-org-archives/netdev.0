From: Marek Vasut <marek.vasut@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Wed, 5 Aug 2009 16:02:34 +0200
Message-ID: <200908051602.34501.marek.vasut@gmail.com>
References: <200907240257.10906.marek.vasut@gmail.com> <4A6E69FA.9010903@gmail.com> <a4423d670907290416h4a0796c2s665d3f8ca0755e67@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Miao <eric.y.miao@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	samuel@sortiz.org, netdev@vger.kernel.org
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f228.google.com ([209.85.220.228]:58445 "EHLO
	mail-fx0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933568AbZHEOCx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 10:02:53 -0400
Received: by fxm28 with SMTP id 28so108966fxm.17
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2009 07:02:53 -0700 (PDT)
In-Reply-To: <a4423d670907290416h4a0796c2s665d3f8ca0755e67@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne St 29. =C4=8Dervence 2009 13:16:25 Alexander Beregalov napsal(a):
> 2009/7/28 Eric Miao <eric.y.miao@gmail.com>:
> > Marek Vasut wrote:
> >> Hi!
> >>
> >> This patch fixes broken pxaficp-ir. The problem was in incorrect
> >> net_device_ops being specified which prevented the driver from
> >> operating. The symptoms were:
> >>  - failing ifconfig for IrLAN, resulting in
> >>       SIOCSIFFLAGS: Cannot assign requested address
> >>  - irattach working for IrCOMM, but the port stayed disabled
> >>
> >> Moreover this patch corrects missing sysfs device link.
> >>
> >> btw. guys, be honest, when did you last tested pxaficp-ir on real
> >> hardware? ;-)
> >
> > Well, this seems to be brought by the net_device_ops change, which =
seems
> > to happen silently without any of us being notified.
> >
> > OK, netdev and Alex are copied, so that we can look into this issue=
 a bit
> > deeper:
> >
> > 1. it looks to me that SIOCSIFFLAGS actually returned -EADDRNOTAVAI=
L,
> > which is likely caused by eth_validate_addr, the default eth_addr c=
omes
> > with irda should be "00:00:00:00:00:00" if not explicitly specified
> > (kzalloc), and this should be the problem, solution ?  Either give =
a
> > valid address to the irda net_device or remove this 'ndo_validate_a=
ddr'.
> > And which is a correct fix will impact on the .ndo_set_mac_address
> >
> > 2. '.ndo_change_mtu' ? It looks to me that Irda device doesn't care=
 too
> > much about the MTU, eth_change_mtu is supposed to work just fine an=
d not
> > to cause any side effects, and may just benefit later irda device d=
rivers
> > if there is a weird device happens to care about MTU
> >
> > - eric
> >
> > Marek's original patch in attachment.
>
> Sorry about that and thanks.
> Then we should fix the rest of irda drivers in the same way.

Hi!
Was my patch applied or what's the current status? Thanks
