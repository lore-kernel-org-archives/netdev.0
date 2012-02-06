From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH] bcma: don't fail for bad SPROM CRC
Date: Mon, 6 Feb 2012 20:28:44 +0100
Message-ID: <4F3029EC.3070709@broadcom.com>
References: <1328534801-3477-1-git-send-email-rydberg@euromail.se>
 <CACna6rwqO73a0G=AQhTVCm=KeLRgjgc5ohJ_B8Z4T9Y-6ZTwMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Henrik Rydberg" <rydberg@euromail.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1936 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228Ab2BFT33 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 14:29:29 -0500
In-Reply-To: <CACna6rwqO73a0G=AQhTVCm=KeLRgjgc5ohJ_B8Z4T9Y-6ZTwMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 06:08 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2012/2/6 Henrik Rydberg <rydberg@euromail.se>:
>> The brcmsmac driver is now checking the bcma SPROM CRCs, leaving som=
e
>> chipsets unrecognized that were functional prior to the switch. In
>> particular, the current code bails out on recent Macbooks. This patc=
h
>> simply ignores the outcome of the CRC check, with the argument that =
an
>> unrecognized SPROM should be treated similarly to a non-existing one=
=2E
>=20
> Have you maybe tried to look at the real solution?
>=20

It could be a new SPROM revision, but brcmsmac still does SPROM access
on its own accord and would fail the probe sequence. So it is probably
something else.

SPROM configuration can differ between chipsets and have the following
variations:

1) external SPROM: when following conditions are true
	chipcommon.capabilities & 0x40000000
	chipcommon.sromcontrol & 0x00000001
2) on-chip OTP: when following conditions are true
	for 4313: chipcommon.chipstatus & 2
	for 43224/43225: true

The real solution would be to take the variations into account. I
started tinkering on it, but not completed yet.

Gr. AvS
