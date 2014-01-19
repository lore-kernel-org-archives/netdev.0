From: James Hogan <james.hogan@imgtec.com>
Subject: Re: [PATCH linux-next] net: batman-adv: use "__packed __aligned(2)" for each structure instead of "__packed(2)" region
Date: Sun, 19 Jan 2014 01:10:39 +0000
Message-ID: <4915262.qEFumRrH4p@radagast>
References: <52DA65F4.5070501@gmail.com> <52DA7B9E.4040202@meshcoding.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5248907.2zWhsaco1j"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: Chen Gang <gang.chen.5i5j@gmail.com>,
	David Miller <davem@davemloft.net>, mareklindner@neomailbox.ch,
	sw@simonwunderlich.de, b.a.t.m.a.n@lists.open-mesh.org,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-metag@vger.kernel.org
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52DA7B9E.4040202@meshcoding.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nextPart5248907.2zWhsaco1j
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Saturday 18 January 2014 14:03:26 Antonio Quartulli wrote:
> On 18/01/14 12:31, Chen Gang wrote:
> > Unfortunately, not all compilers assumes the structures within a pack
> > region also need be packed (e.g. metag), so need add a pack explicitly
> > to satisfy all compilers.
> > 
> > The related error (under metag with allmodconfig):
> >     MODPOST 2952 modules
> >   
> >   ERROR: "__compiletime_assert_431" [net/batman-adv/batman-adv.ko]
> >   undefined!
> >   ERROR: "__compiletime_assert_432" [net/batman-adv/batman-adv.ko]
> >   undefined!
> >   ERROR: "__compiletime_assert_429" [net/batman-adv/batman-adv.ko]
> >   undefined!
> >   ERROR: "__compiletime_assert_428" [net/batman-adv/batman-adv.ko]
> >   undefined!
> >   ERROR: "__compiletime_assert_423" [net/batman-adv/batman-adv.ko]
> >   undefined!
> > 
> > Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> David, what do you think about this change?
> 
> 
> Can "__packed __aligned(2)" generate a different structure padding than
> "#pragma pack(2)" ?
> 
> I am not really sure about the difference between the two. But if we
> have the possibility that the padding may change then this patch should
> go into net, otherwise we will have a protocol compatibility problem
> between 3.13 and 3.14.

(Chen: sorry I didn't twig what you were referring to before about #pragma 
pack not working)

It appears that the following gcc patch adds support for #pragma pack:
http://gcc.gnu.org/ml/gcc-patches/2006-10/msg01115.html

I gave it a quick spin on metag gcc (which is unfortunately stuck on an old 
version) and it seems to fix my simple test case so that #pragma pack(2) 
becomes equivalent to __packed __aligned(2) (for sizeof and __alignof__).


However, the __packed and __aligned are linux specific macros to abstract 
compiler details, whereas #pragma pack appears to be a compiler-specific WIN32 
style equivalent to GCC's __attribute__((packed)) and 
__attribute__((aligned(2))) (these are what __packed and __aligned use in 
compiler-gcc.h).

Therefore I believe using the Linux abstractions is still more correct here.

Cheers
James

--nextPart5248907.2zWhsaco1j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABAgAGBQJS2yYYAAoJEKHZs+irPybfwPgP/RpixtlwIvbQJQ29rTzabkgS
deB6rN/4332leZtIX1REV3s5zFxRJ5iC+NstNMtV8gLZY8JiBPy+RPOU45m7O77X
b/Ryey4NKy7A0X2fxM8GrR+xZAVSLEJ+N21Ra6QpLOIFdRwL6RL1pBZ7OBfW85Wr
4tVt18bjZkeFMq2BRqC6xyik3RsXMyyKx4Rk1w8ruEJPJWFzqfSv1Q8G6EiV3lD5
bJ7A6KHagjI717VmB1QkPQhXBZXQF4Xut4yuC/0yZ/5Ivgp31Ve8Siu+uapgIeGA
q1QV/SVA6sIpwmpoAooDUhUMmR2e0N2RBGBWCD10B+oFZbJ/5WFwqOyGkqhwDLNL
rFBgeXNE9jYZsr1wZz/rH9NudZImExhQF3wmcHo0y/hZ3f4Qb3s3AOZL4O6J5Nnx
hMkW+F6ChZywLrr4QKOymLAQrVxykyB8Z3XS6io+1MmkiFrvMTxLS2sKDV03t5HW
rgb+I3QCnS8s6TKGTula72cKX4nq3FQ1p3wIPib+08nc92eruTpXclwmHWGbQeyl
7krH+toHGBMP0rK6ndeMkk4E42+LMuXalf182umFz1y/eweUP4mZtZkPNviAfrhR
yQ/3cH46tv0DwDZfPtotCoLMZtZ58wjQOQR5CY5WFmTiRE197zApWvruOGGoKU27
enJQ/rrackYEQQzkUP8e
=wy98
-----END PGP SIGNATURE-----

--nextPart5248907.2zWhsaco1j--
