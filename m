From: Kevin Winchester <kjwinchester@gmail.com>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Sat, 17 Nov 2007 21:23:42 -0400
Message-ID: <473F941E.6040809@gmail.com>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org> <20071115164441.67a8e2df.akpm@linux-foundation.org> <473E794A.4060107@kernel.org> <200711170848.35726.kjwinchester@gmail.com> <473F7EDB.60701@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com
To: Andrew Morgan <morgan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from simmts6.bellnexxia.net ([206.47.199.164]:62696 "EHLO
	simmts6-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754392AbXKRBXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 20:23:44 -0500
In-Reply-To: <473F7EDB.60701@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morgan wrote:
> Kevin,
> 
> Can you try this quick hack?
> 
> diff --git a/kernel/capability.c b/kernel/capability.c
> index e57d1aa..4088610 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -109,7 +109,7 @@ out:
>                         kdata[i].permitted = pP.cap[i];
>                         kdata[i].inheritable = pI.cap[i];
>                 }
> -               while (i < _LINUX_CAPABILITY_U32S) {
> +               while (0 && (i < _LINUX_CAPABILITY_U32S)) {
>                         if (pE.cap[i] || pP.cap[i] || pP.cap[i]) {
>                                 /* Cannot represent w/ legacy structure */
>                                 return -ERANGE;
> 


Oh, and the reason your patch turned up incorrect in my mailer and on
lkml seems to be the PGP signature.  I didn't have your public key, so
my mail client just left the full PGP-signed text in, which includes
escaping of '-' characters.  LKML must also ignore the signature.  Once
I added your public key, the patch shows up correctly in my client at least.

(I guess everyone else probably knew this already...but at least I
learned something new today)

- --
Kevin Winchester
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFHP5QdKPGFQbiQ3tQRAqimAJwOSGDSM2wXeLbm+sBKehGf/haNpACfX7Cb
IALnPxwlgShR6Xb+XQclBro=
=xFUp
-----END PGP SIGNATURE-----
