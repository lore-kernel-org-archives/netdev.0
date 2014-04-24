From: Paul Burton <paul.burton@imgtec.com>
Subject: Re: [PATCH v3 13/14] MIPS: net: Add BPF JIT
Date: Thu, 24 Apr 2014 17:31:14 +0100
Message-ID: <20140424163114.GD36716@pburton-linux.le.imgtec.org>
References: <1396957635-27071-14-git-send-email-markos.chandras@imgtec.com>
 <1398351013-29490-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="eqp4TxRxnD4KrmFZ"
Cc: <linux-mips@linux-mips.org>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Markos Chandras <markos.chandras@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <1398351013-29490-1-git-send-email-markos.chandras@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

--eqp4TxRxnD4KrmFZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Apr 24, 2014 at 03:50:13PM +0100, Markos Chandras wrote:
> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
> new file mode 100644
> index 0000000..864e5b7
> --- /dev/null
> +++ b/arch/mips/net/bpf_jit.c

... cut ...

> +			off = offsetof(struct sk_buff, protocol);
> +			emit_half_load(r_A, r_skb, off, ctx);
> +#ifdef CONFIG_CPU_LITTLE_ENDIAN
> +			/* This needs little endian fixup */
> +			if (cpu_has_mips_r1) {

Doesn't cpu_has_mips_r1 cover everything >= r1? ie. everything will now
take this path, including systems >= r2. Don't you want the inverse
(!cpu_has_mips_r2) instead?

Paul

> +				/* Get first byte */
> +				emit_andi(r_tmp_imm, r_A, 0xff, ctx);
> +				/* Shift it */
> +				emit_sll(r_tmp, r_tmp_imm, 8, ctx);
> +				/* Get second byte */
> +				emit_srl(r_tmp_imm, r_A, 8, ctx);
> +				emit_andi(r_tmp_imm, r_tmp_imm, 0xff, ctx);
> +				/* Put everyting together in r_A */
> +				emit_or(r_A, r_tmp, r_tmp_imm, ctx);
> +			} else {
> +				/* R2 and later have the wsbh instruction */
> +				emit_wsbh(r_A, r_A, ctx);
> +			}

--eqp4TxRxnD4KrmFZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTWTxSAAoJEIIg2fppPBxlOZIP/Aii/Fp2twZI8SU0RUIQUyXH
Bd2EuTpe70yxV0F9wripDVnhaP6deBSCLZoQ3Hz10eUEX6DKGQzAJVrGhJtOOJXz
/uOsohH0aK+269Dv4VdfNwjD4ZJbS9EzgoJQbbdahao6qBIAyUXDYOm9c6HQZhdn
AIByrZDdZ6Q/56Hg4RTKQQAV+inzzMZRlbsjYBv/kA9z7guO8dKQdOdX92v5qpQe
Eg1Zj2JqkLf7X6x8HHO4/Habt1Jb1+TXZtyPsX+rusFSRm6jGuwbJAJRGhQRXtOs
eOC5XF+0qGzlMd8Kv/83YsrcP/o09z+aW65g8+n4kTLpGjLeDg+Q5hOG+VZ3SaUM
C+KdZ0ABxtPKInOYWceoOSdwr7eeirBKqsNJQV1Fiz+l7vYc/8fPCropdCbLNG/L
CJlfF8I9xamHpHdIMx/vsQmopu9nP2DllZuMVJeD9PTX7W4WHwQNT7udQ9Elg1Ul
Bv+BtzPwI646bd+y+LdWICIS+zPTW/s6VVGtNqjSV9Rki0vAtA/6JKZJvtZvbImy
XQUzz0bErKIUHDgLbATHQfatJpjCo8TF8m3KZLZy7NHpcIoji01GTCO+oiW5aOXf
Ojc4rrsL8FtNvcBvK5T62gZ1wCbS1ZUzvn3NWMGnua2SoQkAlzRSRAyvszxxxJip
1+0q2mXsTTToq6SP59NQ
=EjuO
-----END PGP SIGNATURE-----

--eqp4TxRxnD4KrmFZ--
