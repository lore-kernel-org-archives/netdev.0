From: Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org
Subject: linux-next-20110831 build failure in iwlwifi when IWLWIFI_DEBUGFS not set
Date: Wed, 31 Aug 2011 15:16:41 -0400
Message-ID: <41822.1314818201@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1314818201_5176P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1314818201_5176P
Content-Type: text/plain; charset=us-ascii

Build error in linux-next 20110831:

drivers/built-in.o: In function `iwl_irq_handle_error':
iwl-trans-rx-pcie.c:(.text+0x100ee9): undefined reference to `iwl_dump_csr'
iwl-trans-rx-pcie.c:(.text+0x100ef5): undefined reference to `iwl_dump_fh'

Calling site is iwl-trans-rx-pcie.c, function iwl_irq_handle_error.

The functions are in iwl-trans.c, but hidden behind #ifdef
CONFIG_IWLWIFI_DEBUGFS so if that isn't defined, they don't get built.  The
call site already has an IWLWIFI_DEBUG ifdef, looks like iwl_irq_handle_error()
needs some tender loving restructuring.


--==_Exmh_1314818201_5176P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOXoiZcC3lWbTT17ARApwVAJ9zv+QZVHIkw5ChphnjXSsXkJrDzACg400b
YXuCfDOw4/DK2ibvUSUvWXc=
=G3Dw
-----END PGP SIGNATURE-----

--==_Exmh_1314818201_5176P--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
