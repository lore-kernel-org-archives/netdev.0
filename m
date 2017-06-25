From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH net-next] liquidio: standardization: use min_t instead of
 custom macro
Date: Sun, 25 Jun 2017 09:09:06 +0300
Message-ID: <20170625060906.GO1248@mtr-leonro.local>
References: <20170624113156.GA1313@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="aMDdG8xNveJz2ruI"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, ricardo.farrington@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:39720 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbdFYGJK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Jun 2017 02:09:10 -0400
Content-Disposition: inline
In-Reply-To: <20170624113156.GA1313@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aMDdG8xNveJz2ruI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 24, 2017 at 04:31:56AM -0700, Felix Manlunas wrote:
> From: Rick Farrington <ricardo.farrington@cavium.com>
>
> Replaced custom MIN macro with use of standard 'min_t'.
>
> Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/octeon_console.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> index 53f38d0..2dc0e30 100644
> --- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> +++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
> @@ -42,7 +42,6 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
>  MODULE_PARM_DESC(console_bitmask,
>  		 "Bitmask indicating which consoles have debug output redirected to syslog.");
>
> -#define MIN(a, b) min((a), (b))
>  #define CAST_ULL(v) ((u64)(v))

It will be awesome to drop this macro too. It is used in one place and
hides important information.

Thanks

>
>  #define BOOTLOADER_PCI_READ_BUFFER_DATA_ADDR    0x0006c008
> @@ -704,7 +703,7 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
>  	if (bytes_to_read <= 0)
>  		return bytes_to_read;
>
> -	bytes_to_read = MIN(bytes_to_read, (s32)buf_size);
> +	bytes_to_read = min_t(s32, bytes_to_read, buf_size);
>
>  	/* Check to see if what we want to read is not contiguous, and limit
>  	 * ourselves to the contiguous block
> --
> 1.8.3.1
>

--aMDdG8xNveJz2ruI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllPU4IACgkQ5GN7iDZy
WKedmxAArUEJGt2UUdOp+YB2wp2K9q5eybvoMrhs9pm5AN+8QRLfpVW4wnV4GGg0
WOtnnp2W+jmr+J7BKA3X31wqNNIVhshY3MmkFgzPdwg5nG4NLrCe0LmZxgGSF+wM
S1UnB6HO/EzMJpni6fSwRfdB4FcERFBxl61zRq0d3A82xWpEznWeYNMKDcyIfHAq
6ANRrR6CMfTtz231eZHoAGm9sEYpVJBm9gH6V8TYdf7hwqVALUj4h+niz/EM9RiW
mXACStL0NtAt5rDHmMGtJyy/04bMObozvu6rUPr3CUNJxWGxb9R11EIiJBSCRZBz
amiBamt6kFidn8hZc4SElJfibq/OVMa1Dcy5eIXMIg8EU8i8aBZ7BMDtiGNZtgIP
LHoJGBjmrSZiWK8E4BwRIZFTbAJrbsM4Mo0XCAxYm4lrreMpVtR4rtOqzXnBhyFC
pkOLHKNit57P74s/pDUSZf+HCcO2e47lQ+OU2x72dbVIT4Ppi+/aYYNNKZYsUTbg
9cxOcOmQycpCtCam6tQEJFQRb/QV5xzq5aIKQJ5maUKl6e04DL7Q0Pjqol/8MpfG
lkdpfbw13BG9B4GYT8FKHokw/Sij77f1JmoY+cRfz2AfFAZlrTp8050tRgDIL6DJ
DvR5cvqeX4Wn8ONyjXDjVtE9sK4V5Qbd5/uU2KPGFLeHZsxajiQ=
=SNuS
-----END PGP SIGNATURE-----

--aMDdG8xNveJz2ruI--
