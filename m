From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: MBIM device refusing to be enabled
Date: Wed, 09 Oct 2013 13:09:08 +0200
Message-ID: <87d2nezoob.fsf@nemi.mork.no>
References: <1381309180.3464.2.camel@linux-fkkt.site>
	<871u3u21zz.fsf@nemi.mork.no> <87hacqzqi0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53926 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757234Ab3JILJe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 07:09:34 -0400
In-Reply-To: <87hacqzqi0.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Wed, 09
	Oct 2013 12:29:43 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> Sorry, that was nonsense.  rfkill would only affect the HwRadioState.

Turns out I wasn't completely off anyway... by pure luck ;-)

> Looking at the commands following this message, it appears that MM
> correctly attempts to enable the SwRadioState but fails.  I don't kno=
w
> why.

Is the device by any chance a Sierra Wireless device?

I was able to recreate the behaviour you see after experimenting a bit
with my MC7710.  This device (and I assume most other MBIM capable
Sierra Wireless minicards) can be configured to enter low power mode on
rfkill (W_DISABLE asserted), instead of powering off.  Sony for example
are known to configure the built-in Sierra devices in this mode.

When low power mode is forced by rfkill this way, the firmware
erroneously[1] claims

 HwRadioState: on
 SwRadioState: off

Any attempt to change this software state using MBIM will fail with
MBIM_STATUS_FAILURE.  Exactly like your log shows.  The modem must be
enabled using rfkill before MM can use it. Changing the firmware
behaviour will not do any good - it will just cause the modem to power
off and disappear instead.

So I would start looking at rfkill after all.  There are often problems
with these platform drivers and newer laptops, due to the lack of
documentation from the vendors.  Here's one (now fixed) example:
https://bugzilla.kernel.org/show_bug.cgi?id=3D47751


[1] Section 10.5.3.6 of the MBIM v1.0 spec says
  "HwRadioState: The state of the W_DISABLE switch [..]
   SwRadioState: Software configured radio state."



Bj=C3=B8rn
