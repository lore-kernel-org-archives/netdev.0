From: Sergey Vlasov <vsu@altlinux.ru>
Subject: [PATCH 2.6 1/2] Fix documentation build failure
Date: Mon, 14 Feb 2005 23:00:17 +0300
Message-ID: <20050214200017.GA29201@sirius.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: netdev@oss.sgi.com
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello!

In linux-2.6.11-rc4-bk2 building of the documentation (make htmldocs)
fails on "DOCPROC Documentation/DocBook/kernel-api.sgml" because of
these errors:

Error(/home/vsu/src/linux-2.6.11-rc4-bk2/include/linux/skbuff.h:936): canno=
t understand prototype: '#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB '
Error(/home/vsu/src/linux-2.6.11-rc4-bk2/drivers/video/fbmem.c:1265): canno=
t understand prototype: 'const char *global_mode_option; '

This patch fixes htmldocs build failure on include/linux/skbuff.h; it
does not change any code.  I think this patch should be merged before
the 2.6.11 release.

Signed-off-by: Sergey Vlasov <vsu@altlinux.ru>


--- linux-2.6.11-rc4-bk2/include/linux/skbuff.h.doc-build	2005-02-14 20:12:=
37 +0300
+++ linux-2.6.11-rc4-bk2/include/linux/skbuff.h	2005-02-14 22:46:20 +0300
@@ -921,6 +921,7 @@ static inline void __skb_queue_purge(str
 		kfree_skb(skb);
 }
=20
+#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
 /**
  *	__dev_alloc_skb - allocate an skbuff for sending
  *	@length: length to allocate
@@ -933,7 +934,6 @@ static inline void __skb_queue_purge(str
  *
  *	%NULL is returned in there is no free memory.
  */
-#ifndef CONFIG_HAVE_ARCH_DEV_ALLOC_SKB
 static inline struct sk_buff *__dev_alloc_skb(unsigned int length,
 					      int gfp_mask)
 {


--=20
Sergey Vlasov

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCEQNRW82GfkQfsqIRAkzeAJ97rnrbnsS4vJ1qUXeEhAMErJodcQCfcyq1
pdxxXzgTsG3b/BLpkL4SwBs=
=RSnR
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
