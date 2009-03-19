From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Wed, 18 Mar 2009 23:35:45 -0700 (PDT)
Message-ID: <20090318.233545.163357233.davem@davemloft.net>
References: <20090318064010.GA13399@electric-eye.fr.zoreil.com>
	<200903181300.00591.fzu@wemgehoertderstaat.de>
	<20090318223629.GA2306@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fzu@wemgehoertderstaat.de, netdev@vger.kernel.org, rjw@sisk.pl
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754857AbZCSGf6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 02:35:58 -0400
In-Reply-To: <20090318223629.GA2306@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 18 Mar 2009 23:36:29 +0100

> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> > Am Mittwoch 18 M=E4rz 2009 schrieb Francois Romieu:
> [...]
> > > If netif_rx_schedule fails after napi is enabled, there is a
> > > racing poll thread to care for the transfer.
> > >=20
> > > Stated differently the bug is noticeable because napi_enable()=20
> > > should be called before request_irq() in rtl8169_open, right ?
> >=20
> > Propably yes. That would mean the first interrupt is received befor=
e
> > rtl_hw_start() is called in rtl8169_open. The source of that
> > interrupt would be something else then?
>=20
> All we need is thus a shared interrupt racing on a different CPU
> with rtl8169_open and some IO versus memory reordering so that
> the hardware is started and a change in the status register can
> be seen in the IRQ handler before napi_enable/NAPI_STATE_SCHED
> escapes from the CPU where rtl8169_open is running...
>=20
> It does not look like a credible explanation. :o/

Agreed, looking at how this part of the driver works I can't
see how this condition can arise either.
