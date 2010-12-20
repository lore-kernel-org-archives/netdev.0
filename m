From: Valdis.Kletnieks@vt.edu
Subject: Re: [PATCH v3] kptr_restrict for hiding kernel pointers
Date: Mon, 20 Dec 2010 17:26:31 -0500
Message-ID: <50259.1292883991@localhost>
References: <1292692835.10804.67.camel@dan>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1292883991_5161P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, mingo@elte.hu, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: Your message of "Sat, 18 Dec 2010 12:20:34 EST."
             <1292692835.10804.67.camel@dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1292883991_5161P
Content-Type: text/plain; charset=us-ascii

On Sat, 18 Dec 2010 12:20:34 EST, Dan Rosenberg said:

> @@ -1035,6 +1038,26 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
>  		return buf + vsnprintf(buf, end - buf,
>  				       ((struct va_format *)ptr)->fmt,
>  				       *(((struct va_format *)ptr)->va));
> +	case 'K':
> +		/*
> +		 * %pK cannot be used in IRQ context because it tests
> +		 * CAP_SYSLOG.
> +		 */
> +		if (in_irq() || in_serving_softirq() || in_nmi())
> +			WARN_ONCE(1, "%%pK used in interrupt context.\n");

Should this then continue on and test CAP_SYSLOG anyhow, or should it
return a "" or or "<invalid>" or something?

--==_Exmh_1292883991_5161P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFND9gXcC3lWbTT17ARAlDxAKD02+4VO8q2qAP1QTVvM3JbWee6kgCg9JGO
DwMSZSe+Bkbl/fGMZD4p1pM=
=571E
-----END PGP SIGNATURE-----

--==_Exmh_1292883991_5161P--

