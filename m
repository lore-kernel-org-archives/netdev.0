From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH RFC 21/26] powerpc: Remove spin_unlock_wait()
 arch-specific definitions
Date: Sun, 2 Jul 2017 11:58:07 +0800
Message-ID: <20170702035807.tnzmkynyevfobt5a@tardis>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-21-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="7nfvfvnv5t6syok4"
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        parri.andrea@gmail.com, dave@stgolabs.net,
        manfred@colorfullife.com, arnd@arndb.de, peterz@infradead.org,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        will.deacon@arm.com, oleg@redhat.com, mingo@redhat.com,
        netfilter-devel@vger.kernel.org, tj@kernel.org,
        stern@rowland.harvard.edu, akpm@linux-foundation.org,
        torvalds@linux-foundation.org, Paul Mackerras <paulus@samba.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498780894-8253-21-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7nfvfvnv5t6syok4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 29, 2017 at 05:01:29PM -0700, Paul E. McKenney wrote:
> There is no agreed-upon definition of spin_unlock_wait()'s semantics,
> and it appears that all callers could do just as well with a lock/unlock
> pair.  This commit therefore removes the underlying arch-specific
> arch_spin_unlock_wait().
>=20
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: <linuxppc-dev@lists.ozlabs.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Andrea Parri <parri.andrea@gmail.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>

Acked-by: Boqun Feng <boqun.feng@gmail.com>

Regards,
Boqun

> ---
>  arch/powerpc/include/asm/spinlock.h | 33 -------------------------------=
--
>  1 file changed, 33 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/spinlock.h b/arch/powerpc/include/a=
sm/spinlock.h
> index 8c1b913de6d7..d256e448ea49 100644
> --- a/arch/powerpc/include/asm/spinlock.h
> +++ b/arch/powerpc/include/asm/spinlock.h
> @@ -170,39 +170,6 @@ static inline void arch_spin_unlock(arch_spinlock_t =
*lock)
>  	lock->slock =3D 0;
>  }
> =20
> -static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
> -{
> -	arch_spinlock_t lock_val;
> -
> -	smp_mb();
> -
> -	/*
> -	 * Atomically load and store back the lock value (unchanged). This
> -	 * ensures that our observation of the lock value is ordered with
> -	 * respect to other lock operations.
> -	 */
> -	__asm__ __volatile__(
> -"1:	" PPC_LWARX(%0, 0, %2, 0) "\n"
> -"	stwcx. %0, 0, %2\n"
> -"	bne- 1b\n"
> -	: "=3D&r" (lock_val), "+m" (*lock)
> -	: "r" (lock)
> -	: "cr0", "xer");
> -
> -	if (arch_spin_value_unlocked(lock_val))
> -		goto out;
> -
> -	while (lock->slock) {
> -		HMT_low();
> -		if (SHARED_PROCESSOR)
> -			__spin_yield(lock);
> -	}
> -	HMT_medium();
> -
> -out:
> -	smp_mb();
> -}
> -
>  /*
>   * Read-write spinlocks, allowing multiple readers
>   * but only one writer.
> --=20
> 2.5.2
>=20

--7nfvfvnv5t6syok4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAllYbx4ACgkQSXnow7UH
+rjJoAf9ER3wqVQgGOVwgLauCT8gfxl5xT9ZzXPdSZ8ZpBbbiS3hMKitAc/pBO8c
HC/NF4DhvxyX7oogUcYIQgRGrvF1NbPpl5QwDsCmlaWSj7V/nU3R9TzOtjB0ToDq
L8s0/R6PLQHixtjpgT06/X5xF2xPHoTdD8WzfBm03chtxAKhLvuWRhS/yU46Q9aE
r0TMMq2oFtTiwH9SzL6avxd1h7hHqjAQUTLiJkncmGJpXS5bLUyxAQNw7zpWz252
yYrdC6JDqVLTrjPoeUwZIUy1WqOzvIK9/Y/7RAOYTSSYi5FWqbRIcHPmI90EzQ0r
fyAoYkKvRleSV1Lzv14RP7DLZse/tA==
=u8hv
-----END PGP SIGNATURE-----

--7nfvfvnv5t6syok4--
