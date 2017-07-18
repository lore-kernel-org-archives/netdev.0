From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v2 net-next 0/3] liquidio: avoid vm low memory crashes
Date: Tue, 18 Jul 2017 09:23:17 +0300
Message-ID: <20170718062317.GJ3259@mtr-leonro.local>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="mvpLiMfbWzRoNl4x"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59904 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750931AbdGRGXV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 02:23:21 -0400
Content-Disposition: inline
In-Reply-To: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--mvpLiMfbWzRoNl4x
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 17, 2017 at 05:49:20PM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> This patchset addresses issues brought about by low memory conditions
> in a VM.  These conditions were not seen when the driver was exercised
> normally.  Rather, they were brought about through manual fault injection.
> They are being included in the interest of hardening the driver against
> unforeseen circumstances.
>
> 1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list=
'.
>    This prevents a GPF trying to access an invalid 'recv_buf_list[i]' ent=
ry
>    in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.
> 2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
> 3. For defensive programming, zero the allocated block 'oct->droq[0]' in
>    octeon_setup_output_queues() and 'oct->instr_queue[0]' in
>    octeon_setup_instr_queues().
>
> change log:
> V1 -> V2:
> 1. Corrected syntax in 'Subject' lines; no functional or code changes.
>
> Rick Farrington (3):
>   liquidio: lowmem: init allocated memory to 0
>   liquidio: lowmem: do not dereference null ptr
>   liquidio: lowmem: init allocated memory to 0

I'm feeling d=E9j=E0 vu here. We already discussed that zero allocated arra=
ys
have nothing to do with low memory conditions. Why are you continuing to use
this misleading term here?

>
>  drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.c   | 6 ++++--
>  2 files changed, 8 insertions(+), 6 deletions(-)
>
> --
> 2.9.0
>

--mvpLiMfbWzRoNl4x
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlltqVUACgkQ5GN7iDZy
WKfWCg/+MhrYLp23BFze4xJ6/USre7dA/GJeS683/mO5wJ1nocXhiZv0ksogeCDD
LoPF3vNYMoEf/FHwrRzx7P5doh+BMHxcK5gAJTNHLYI80Aj8pICO8SbHUB81YzUh
NoCWDJ69JygBmkarYaiG7ynbpt8ZkWPfMyDWLeSooAAb1Ej1z+jhDCELHFSdGyef
SH1QB/hKZjEznGHSuHBjMCtK1i7+1wVJ4Ipe707Y8/7gtZEN6I/a3JqHacryWiBo
7M2Jbnc368NpLN5+EOGP6cXT787xLUfZPLTI1kVzNQcHr8jAOdpEiJ7NeRjPGU+p
3rrsQ/GiW49S82/MQtGciIpO7RrIynXJtcHCvHY7m8krj307vJmIj5NgHFgEfzbe
g/BV3xzeJ9WrXdf05sucwiQyqimajyOe7E34VzH3igACpIxYF7kXXOEFpxX1IpOg
L8t6/U/A0CTv2Oe96SVbT8KrA1aTPj4TxCvVYudd0n/BmpzPpOIhDo+1nv186y/M
7DKf8q/fjQCjbhOhJTUTwcL9HXflHUVrPuJxMfqgaIK66feL64E9smy6oxau4Jzg
0wqvDjONw4F//0lA2eWlIP0SgTWyOPZiiDro9XKPe9yTgdaZqoIBof8enyU6IkQ2
rI9KJF99IrO+6LyzEkeF32+vqFSTXa0wkUR6SIi/mYNTDTZF/AE=
=9qP7
-----END PGP SIGNATURE-----

--mvpLiMfbWzRoNl4x--
