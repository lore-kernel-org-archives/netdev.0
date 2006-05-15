From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 18:06:42 +0400
Message-ID: <20060515180642.75269d8c.vsu@altlinux.ru>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="pgp-sha1";
 boundary="Signature=_Mon__15_May_2006_18_06_42_+0400_2=iWMe=8p+8MU40j"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mivlgu.ru ([81.18.140.87]:5551 "EHLO mail.mivlgu.ru")
	by vger.kernel.org with ESMTP id S964927AbWEOOGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 10:06:46 -0400
To: "Mark Wallis" <mwallis@serialmonkey.com>
In-Reply-To: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__15_May_2006_18_06_42_+0400_2=iWMe=8p+8MU40j
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: 7bit

On Mon, 15 May 2006 22:57:12 +1000 Mark Wallis wrote:

> What are peoples thoughts here, should we 
> 
> A. be handling this within our drivers and doing "what the user expects" and
> disabling the hardware radio, or 
> 
> B. should we be firing an ACPI event and getting the distro's to add scripts
> so when this event is fired they bring down all the wireless interfaces.

Using ACPI events for this purpose seems wrong:

- ACPI is not available on all architectures supported by Linux,
  therefore it cannot be an universal solution;

- even if ACPI is available, it may be turned off for some reason.

In fact, many people consider the separate /proc/acpi/event interface
for ACPI events to be a mistake, and there is some movement to make ACPI
use the input layer instead:

  http://lkml.org/lkml/2006/4/19/275

There is even a KEY_RADIO defined in <linux/input.h> (however, it was
probably intended to be used for a remote control key, like
TV/VCR/CD/Tape/... defined near it, so I'm not sure whether it would be
the proper event to use here).

--Signature=_Mon__15_May_2006_18_06_42_+0400_2=iWMe=8p+8MU40j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFEaIr0W82GfkQfsqIRAnbEAJ9Nrd/sBPV5+akX2B9A7rIYa9OEcwCdGq4R
oF22LhGG8VcMP8cSN3bl/PE=
=gjID
-----END PGP SIGNATURE-----

--Signature=_Mon__15_May_2006_18_06_42_+0400_2=iWMe=8p+8MU40j--
