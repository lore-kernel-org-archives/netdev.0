From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 05 Oct 2006 17:13:06 +0200
Message-ID: <45252102.8030402@web.de>
References: <4523DA7D.2080604@web.de> <200610041922.39079.IvDoorn@gmail.com> <20061005133709.36a764c0@griffin.suse.cz> <200610051700.31171.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig0C658E632785174F14E9A99C"
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:15569 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP id S932104AbWJEPN5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:13:57 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610051700.31171.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0C658E632785174F14E9A99C
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Ivo van Doorn wrote:
> On Thursday 05 October 2006 13:37, Jiri Benc wrote:
>> On Wed, 4 Oct 2006 19:22:38 +0200, Ivo van Doorn wrote:
>>> Well another point of concern for me is the TSF handling, those handl=
ers are called
>>> from interrupt context as well, and also deliver problems for the USB=
 drivers in case
>>> of adhoc mode.
>> Where is a problem with tsf handlers? get_tsf is not called at all
>> (unless CONFIG_D80211_IBSS_DEBUG is set; well, that raises a question
>> why the function exists in the first place), reset_tsf returns void.
>=20
> Basically it comes down to this:
>=20
> Sep 13 12:27:34 wz4a kernel: wlan0: Creating new IBSS network, BSSID 7a=
:b9:60:8a:84:39
> Sep 13 12:27:34 wz4a kernel: BUG: scheduling while atomic: swapper/0x00=
000100/0
> Sep 13 12:27:34 wz4a kernel:  <b02701e7> schedule+0x43/0xa84  <b01ef8b8=
> extract_buf+0x97/0xc8
> Sep 13 12:27:34 wz4a kernel:  <b0270ca8> wait_for_completion+0x6a/0x9f =
 <b0116f2d> default_wake_function+0x0/0xc
> Sep 13 12:27:34 wz4a kernel:  <c08ac59f> usb_start_wait_urb+0x98/0xdc [=
usbcore]  <c08ac418> timeout_kill+0x0/0x5 [usbcore]
> Sep 13 12:27:34 wz4a kernel:  <c08ac7d5> usb_control_msg+0xc3/0xde [usb=
core]  <c0b6c0f1> rt2x00_vendor_request+0x7c/0xa6 [rt73usb]
> Sep 13 12:27:34 wz4a kernel:  <c0b6fa68> rt73usb_reset_tsf+0x30/0x59 [r=
t73usb]  <c0bdb3e8> ieee80211_sta_join_ibss+0x3a/0x572 [80211]
> Sep 13 12:27:34 wz4a kernel:  <b011cea9> printk+0x14/0x18  <c0bdaa4a> i=
eee80211_rx_bss_add+0x88/0x90 [80211]
> Sep 13 12:27:34 wz4a kernel:  <c0bdbc2e> ieee80211_sta_find_ibss+0x30e/=
0x366 [80211]  <c0bdda17> ieee80211_sta_timer+0x0/0x18f [80211]
> Sep 13 12:27:34 wz4a kernel:  <c0bdda91> ieee80211_sta_timer+0x7a/0x18f=
 [80211]  <c0bdda17> ieee80211_sta_timer+0x0/0x18f [80211]
> Sep 13 12:27:34 wz4a kernel:  <b01241b1> run_timer_softirq+0x10b/0x153 =
 <b0120a52> __do_softirq+0x58/0xc2
> Sep 13 12:27:34 wz4a kernel:  <b0120aea> do_softirq+0x2e/0x32  <b0104fe=
6> do_IRQ+0x1e/0x24
> Sep 13 12:27:34 wz4a kernel:  <b0103592> common_interrupt+0x1a/0x20  <c=
0827484> acpi_processor_idle+0x18a/0x39e [processor]
> Sep 13 12:27:34 wz4a kernel:  <b0101e77> cpu_idle+0x8f/0xa8  <b03026d2>=
 start_kernel+0x355/0x35c
>=20
> With the compilation of d80211 the CONFIG_D80211_DEBUG is set by defaul=
t,
> so no CONFIG_D80211_IBSS_DEBUG.
>=20
> This does not happen in rt2500usb driver, since no TSF handling is poss=
ible
> due to a lack of TSF registers in the device.

This path would be fixed by my conversion patch of sta.timer into
sta.work that I sent you yesterday privately. Unfortunately, I don't
have a copy at hand ATM.

What about the other timers? Can they trigger any sleeping service of
rt2x00 drivers? Ok, waiting for a BUG is always possible... ;)

Jan


--------------enig0C658E632785174F14E9A99C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFJSECniDOoMHTA+kRAjzIAJ0XXkeKTmQkibz3EfAaAcPrRW32igCfRtMl
49APcdAD+wYtudDauOFLmxQ=
=4Tig
-----END PGP SIGNATURE-----

--------------enig0C658E632785174F14E9A99C--
