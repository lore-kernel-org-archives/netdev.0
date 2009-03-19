From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Thu, 19 Mar 2009 11:58:51 +0100
Message-ID: <200903191158.52436.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903181300.00591.fzu@wemgehoertderstaat.de> <20090318223629.GA2306@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout3.freenet.de ([195.4.92.93]:41781 "EHLO mout3.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190AbZCSK66 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 06:58:58 -0400
In-Reply-To: <20090318223629.GA2306@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch 18 M=E4rz 2009 schrieb Francois Romieu:
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

=46ound it: CONFIG_DEBUG_SHIRQ is set here causing a "test-call" to
rtl8169_interrupt() from irq_request().

$SUBJECT patch is ok, me still thinks. You?

Thanks,
Karsten
