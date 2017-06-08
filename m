From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next 0/3] LiquidIO: avoid VM low memory crashes
Date: Thu, 8 Jun 2017 10:12:37 +0300
Message-ID: <20170608071237.GL1127@mtr-leonro.local>
References: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="7vAdt9JsdkkzRPKN"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42356 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751418AbdFHHMn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 03:12:43 -0400
Content-Disposition: inline
In-Reply-To: <20170608035045.GA1608@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7vAdt9JsdkkzRPKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 07, 2017 at 08:50:45PM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> This patchset addresses issues brought about by low memory conditions
> in a VM.  These conditions were only seen when VM's were intentionally
> created with small amounts of memory (for stress testing).
>
> 1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
>    This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
>    in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.
> 2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
> 3. For defensive programming, zero the allocated block 'oct->droq[0]' in
>    octeon_setup_output_queues() and 'oct->instr_queue[0]' in
>    octeon_setup_instr_queues().
>

While these patches are harmless, I don't really understand how
allocating the same arrays just with zeros in it can prevent low memory
crashes. Once you used v[m,z]alloc, you should expect for failures in
these flows and relying on content of that page is not called "solve the
bug".

Thanks



>  drivers/net/ethernet/cavium/liquidio/octeon_device.c | 8 ++++----
>  drivers/net/ethernet/cavium/liquidio/octeon_droq.c   | 6 ++++--
>  2 files changed, 8 insertions(+), 6 deletions(-)
>
> --
> 1.8.3.1
>

--7vAdt9JsdkkzRPKN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk4+OUACgkQ5GN7iDZy
WKfNoxAAgm/6G/HM9CrQWqtbN9ySF0bClgWn1/QJDB4MymfkQdSF8Dcalxl5v8hH
3ay6mhUe1i6eDq8vYQPZnLOioZhIb/10Ag1PmKHTudPTKB/muTzhj/0hWwvVlOxO
SjxNKwzUhMh06liDNoSs5W/iaKK2CYpGDbXuwSrmKzt1ljHDiV7iMTyTEnokEw3a
VT38oqX9i4LgOj+rIOUKyaIAbmXdq4i/pAcC7Ab81wFIBiqtPQ3ohk7aGe+uXxvD
WuJavvJjStyV3rzQfzXr5Nu7WhaXGbz+S+dpSJLIUG8MBAi5aeYOb7ELT2XTLPWf
8574w3SlG+FQlQOBrKoy2xD+0AiMyQ30QzhJXM0TM8QnRzklYisXxYa9Hfuq02Om
ZXb7ZPCD32ss18jpCeJVxvbP3k+VIUviATNPF+6uISGARzmbr1vI1HhIbtx0/AWp
C6Afrw9uvbyECl4oaXM0hqzNU75GgnZn5LFlqcINYtrJQgwhUP3lF7WFHDchLVQs
aIAT+d47YO8VyoFkXNvkvEkC8bxr4BWiPqMiVJUlhJJ+Pky0om/RdzAuJqmW1paU
PT6ZEloeyO3JGTjMQnZKm/xWRGfzBfg7CyLJICW1zFpcd6gPGBUxyf6oynCNH8wg
EkzUVuqcMOJvzIyqEtjrGCtAOeTJY3BLidwYz69tb54euQmay38=
=PsdC
-----END PGP SIGNATURE-----

--7vAdt9JsdkkzRPKN--
