From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [PATCH 2.6.9-rc2 17/38] net/islpci_dev: replace
	schedule_timeout() with msleep()
Date: Thu, 23 Sep 2004 18:55:07 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040923225507.GI30131@ruslug.rutgers.edu>
References: <20040923221303.GB13244@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1666511525=="
Cc: Netdev <netdev@oss.sgi.com>, mcgrof@studorgs.rutgers.edu,
	hvr@gnu.org, margitsw@t-online.de, kernel-janitors@lists.osdl.org,
	prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20040923221303.GB13244@us.ibm.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============1666511525==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="df+09Je9rNq3P+GE"
Content-Disposition: inline


--df+09Je9rNq3P+GE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 23, 2004 at 03:13:03PM -0700, Nishanth Aravamudan wrote:
> Any comments would be appreciated.
>=20
> Description: Use msleep() instead of schedule_timeout()
> to guarantee the task delays as expected. Also set_current_state() is
> inserted before schedule_timeout(). If the for-loop were to execute
> twice, the second time would not set the state before sleeping in the
> current code; this causes schedule_timeout() to return immediately.
>=20
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
>=20
> --- 2.6.9-rc2-vanilla/drivers/net/wireless/prism54/islpci_dev.c	2004-09-1=
3 17:15:41.000000000 -0700
> +++ 2.6.9-rc2/drivers/net/wireless/prism54/islpci_dev.c	2004-09-23 13:58:=
42.000000000 -0700
> @@ -436,8 +436,7 @@ prism54_bring_down(islpci_private *priv)
>  	wmb();
> =20
>  	/* wait a while for the device to reset */
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	schedule_timeout(50*HZ/1000);
> +	msleep(50);
> =20
>  	return 0;
>  }
> @@ -489,6 +488,7 @@ islpci_reset_if(islpci_private *priv)
>  		/* The software reset acknowledge needs about 220 msec here.
>  		 * Be conservative and wait for up to one second. */
>  =09
> +		set_current_state(TASK_UNINTERRUPTIBLE);
>  		remaining =3D schedule_timeout(HZ);
> =20
>  		if(remaining > 0) {


Looks good to me. IIRC Margit had something to say about this last time
this popped around -- CC'ing her to see if there are any outstanding
comments.

PS. For future prism54 patches please feel free to CC prism54-devel and
netdev.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--df+09Je9rNq3P+GE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBU1RLat1JN+IKUl4RAk9+AJ9KiSJszt4vr2I7L1igpeJB4SNe5QCgrIa8
SUQv0TM059cGvmMHKU73qhw=
=JuFF
-----END PGP SIGNATURE-----

--df+09Je9rNq3P+GE--

--===============1666511525==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============1666511525==--
