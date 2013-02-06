From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART messages and interrupt pipe setup
Date: Wed, 06 Feb 2013 22:11:51 +0100
Message-ID: <87ip655eqw.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<1357318289.5370.19.camel@dcbw.foobar.com>
	<1360176176.11742.16.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58549 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758462Ab3BFVMG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 16:12:06 -0500
In-Reply-To: <1360176176.11742.16.camel@dcbw.foobar.com> (Dan Williams's
	message of "Wed, 06 Feb 2013 12:42:56 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams <dcbw@redhat.com> writes:

> As part of the initialization sequence, the driver sends a SYNC messa=
ge
> via the control pipe to the firmware, which appears to request a
> firmware restart.  The firmware responds with an indication via the
> interrupt pipe set up by usbnet.  If the driver does not receive a
> RESTART indication within a certain amount of time, it will periodica=
lly
> send additional SYNC messages until it receives the RESTART indicatio=
n.
>
> Unfortunately, the interrupt URB is only submitted while the netdev
> is open, which is usually not the case during initialization, and thu=
s
> the firmware's RESTART indication is lost.  So the driver continues
> sending SYNC messages, and eventually the firmware crashes when it
> receives too many.  This leads to a wedged netdev.
>
> To ensure the firmware's RESTART indications can be received by the
> driver, request that usbnet keep the interrupt URB active via
> FLAG_INTR_ALWAYS.
>
> Second, move the code that sends the SYNC message out of the
> bind() hook and after usbnet_probe() to ensure the interrupt URB
> is set up before trying to use it.

Given this description I am wondering if you couldn't just move the
whole SYNC thing to a new reset() hook, using some private flag to make
sure it only runs once?  Does it really need to start at probe time?


Bj=C3=B8rn
