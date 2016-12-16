From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v5 2/4] siphash: add Nu{32,64} helpers
Date: Fri, 16 Dec 2016 10:39:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0240EFA@AcuExch.aculab.com>
References: <20161215203003.31989-1-Jason@zx2c4.com>
 <20161215203003.31989-3-Jason@zx2c4.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "'Jason A. Donenfeld'" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	LKML <linux-kernel@vger.kernel.org>, "linux-crypto@vger.kernel.org"
	<linux-crypto@vger.kernel.org>, Ted Tso <tytso@mit.edu>, Hannes Frederic Sowa
	<hannes@stressinduktion.org>, Linus Torvalds <torvalds@linux-foundation.org>,
	Eric Biggers <ebiggers3@gmail.com>, Tom Herbert <tom@herbertland.com>,
	"George Spelvin" <linux@sciencehorizons.net>, Vegard Nossum
	<vegard.nossum@gmail.com>, "ak@linux.intel.com" <ak@linux.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>, "luto@amacapital.net"
	<luto@amacapital.net>
Return-path: <kernel-hardening-return-5630-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20161215203003.31989-3-Jason@zx2c4.com>
Content-Language: en-US
List-Id: netdev.vger.kernel.org

From: Jason A. Donenfeld
> Sent: 15 December 2016 20:30
> These restore parity with the jhash interface by providing high
> performance helpers for common input sizes.
...
> +#define PREAMBLE(len) \
> +	u64 v0 =3D 0x736f6d6570736575ULL; \
> +	u64 v1 =3D 0x646f72616e646f6dULL; \
> +	u64 v2 =3D 0x6c7967656e657261ULL; \
> +	u64 v3 =3D 0x7465646279746573ULL; \
> +	u64 b =3D ((u64)len) << 56; \
> +	v3 ^=3D key[1]; \
> +	v2 ^=3D key[0]; \
> +	v1 ^=3D key[1]; \
> +	v0 ^=3D key[0];

Isn't that equivalent to:
	v0 =3D key[0];
	v1 =3D key[1];
	v2 =3D key[0] ^ (0x736f6d6570736575ULL ^ 0x646f72616e646f6dULL);
	v3 =3D key[1] ^ (0x646f72616e646f6dULL ^ 0x7465646279746573ULL);

Those constants also look like ASCII strings.
What cryptographic analysis has been done on the values?

	David
