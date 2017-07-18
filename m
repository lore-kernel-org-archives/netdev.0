From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Use sock_diag instead of procfs for new address families?
Date: Tue, 18 Jul 2017 17:18:06 +0100
Message-ID: <20170718161806.GA21151@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Cc: netdev@vger.kernel.org, Jorgen Hansen <jhansen@vmware.com>
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54756 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751393AbdGRQSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 12:18:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

I am implementing userspace access to socket information for AF_VSOCK.
A few hours into writing and testing a /proc/net/vsock seq_file I
noticed that ss(8) prefers NETLINK_SOCK_DIAG over procfs.

Before potentially wasting time implementing a legacy interface that
won't be accepted, I thought it might be good to ask :).

Which approach is preferred?
1. New address families must implement only sock_diag.
2. Both sock_diag and procfs must be implemented.
3. Implement whichever interface you prefer.

Thanks,
Stefan

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZbjS+AAoJEJykq7OBq3PICf4H/33jKPzHOSRorIntXf6yIs7I
bphaED6/0TrTvCC5zeRkEJ9eSKvwRFerxmAfxQZ5sx34pLrgZMSvgakiOYqDxTt1
Xl4EbvGjUnn8jd6388DZb9l8FSNuD3XWUtUDMc8/xLvIPugTQ9Pftf/CF8cLcKOK
Hyphf4Vr4ICSwGHIiTiclx43dVdUOTtEmdmitMIwgG52SChrbhCmb/K/s+cGaaDv
NgHz15r78QsTwGFeSexHg4N6FQZIM9G99aq2dgQxby3JUR5vDixOvSQ83nJjOfMS
zKm6moR9eyOMspzJISdVdiqhLeTliY/+PLql53as+F8CCiKAp56kzDE4HIoi/s0=
=k42u
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--
