From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Fri, 17 Apr 2009 01:34:50 -0700 (PDT)
Message-ID: <20090417.013450.02738760.davem@davemloft.net>
References: <20090415154658.40e3639a@surf>
	<20090416110753.5c75b805@hskinnemoen-d830>
	<20090416112435.0b779859@surf>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: haavard.skinnemoen@atmel.com, netdev@vger.kernel.org,
	michael@free-electrons.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59161
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753050AbZDQIe6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 04:34:58 -0400
In-Reply-To: <20090416112435.0b779859@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu, 16 Apr 2009 11:24:35 +0200

> Le Thu, 16 Apr 2009 11:07:53 +0200,
> Haavard Skinnemoen <haavard.skinnemoen@atmel.com> a =E9crit :
>=20
>> Hmm...is this safe? What if printk() is called from the macb interru=
pt
>> handler?
>=20
> I'm not sure, but that strategy is used in most drivers supporting th=
e
> netpoll API (3c509.c, 8139cp.c, 8139too.c, b44.c, bfin_mac.c,
> bnx2x_main.c, etc.). It also seems to be the way suggested by netpoll
> author, http://oss.sgi.com/archives/netdev/2003-10/msg00800.html.
>=20
> disable_irq() only disables the macb IRQ line. Is that an issue for
> printk() execution ?

And in response to this Haavard explained the potential deadlock
(sorry I deleted that email) and suggested to use local_irq_save()

But that won't work either, because it doesn't prevent the interrupt
handler from running on other cpus, it only prevents that on the
local cpu.

But I do wonder, because a lot of drivers do in fact use that
disable_irq() scheme to implement ->poll_controller().

I suppose one just needs to be careful about using printk from
the interrupt handler when supporting netpoll.
