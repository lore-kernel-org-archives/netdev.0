From: Mark Brown <broonie@kernel.org>
Subject: linux-next: /home/broonie/tmpfs/next/kernel/bpf/verifier.c:
Date: Thu, 19 Oct 2017 14:55:23 +0100
Message-ID: <20171019135523.w7ljx34hyx7422nb@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="ydfqm7w4u4mvny7o"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Edward Cree <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ydfqm7w4u4mvny7o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

After merging the net-next tree, today's linux-next build (x86allmodconfig)
failed like this:

/home/broonie/tmpfs/next/kernel/bpf/verifier.c: In function 'check_mem_access':
/home/broonie/tmpfs/next/kernel/bpf/verifier.c:1010:12: error: passing argument 1 of 'verbose' from incompatible pointer type [-Werror=incompatible-pointer-types]
    verbose("dereference of modified ctx ptr R%d off=%d+%d, ctx+const is allowed, ctx+const+const is not\n",
            ^
/home/broonie/tmpfs/next/kernel/bpf/verifier.c:173:28: note: expected 'struct bpf_verifier_env *' but argument is of type 'char *'
 static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
                            ^
/home/broonie/tmpfs/next/kernel/bpf/verifier.c:1011:5: warning: passing argument 2 of 'verbose' makes pointer from integer without a cast [-Wint-conversion]
     regno, reg->off, off - reg->off);
     ^
/home/broonie/tmpfs/next/kernel/bpf/verifier.c:173:28: note: expected 'const char *' but argument is of type 'u32 {aka unsigned int}'
 static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
                            ^
cc1: some warnings being treated as errors
/home/broonie/tmpfs/next/scripts/Makefile.build:313: recipe for target 'kernel/bpf/verifier.o' failed

Caused by commit

  28e33f9d78eef ("bpf: disallow arithmetic operations on context pointer")

interacting with

  61bd5218eef34 ("bpf: move global verifier log into verifier environment")

--ydfqm7w4u4mvny7o
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnorsoACgkQJNaLcl1U
h9DmYwf/X/Qb4HKfx1/Ka8FbiUZp1s/A94AYaIhf2iTa1x7FFUympE5iCeeSHt05
faZ+IpZSohRdkHPiml/GC3bNc9UsZFLXXSFamIYBeNgXdySiJr1eMt8910t2SXiz
+txcpYD5tgbegNPF6M+FrUdnlhUQWcLKn8/TTM6gnVOnhAzd3pGlw6zmlhKtuu5r
cC20YPYkbOfKxKCwvqj5BQQplSr4a+RoTy3919b2ljOaWB1GaUq4dCUCAy7LT55y
kHq7Fxy1KyWuhYD6zkHP7on/pbxf1oaIosAUzh5j+lgfU1qZJK04zdJgdmlkT9/G
44EB9iKOmgQW8I7q32uA7+itpa9hJQ==
=Tq7L
-----END PGP SIGNATURE-----

--ydfqm7w4u4mvny7o--
