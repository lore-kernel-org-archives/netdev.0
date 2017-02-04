From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 0/4] Fix on-stack USB buffers
Date: Sat, 4 Feb 2017 16:54:51 +0000
Message-ID: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="AHVSF3we4xtO5oi5"
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53582 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750890AbdBDQyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:54:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--AHVSF3we4xtO5oi5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Allocating USB buffers on the stack is not portable, and no longer
works on x86_64 (with VMAP_STACK enabled as per default).  This
series fixes all the instances I could find where USB networking
drivers do that.

Ben.

Ben Hutchings (4):
  pegasus: Use heap buffers for all register access
  rtl8150: Use heap buffers for all register access
  catc: Combine failure cleanup code in catc_probe()
  catc: Use heap buffer for memory size test

 drivers/net/usb/catc.c    | 56 ++++++++++++++++++++++++++++-------------------
 drivers/net/usb/pegasus.c | 29 ++++++++++++++++++++----
 drivers/net/usb/rtl8150.c | 34 ++++++++++++++++++++++------
 3 files changed, 86 insertions(+), 33 deletions(-)


--AHVSF3we4xtO5oi5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJYHW+e/yOyVhhEJAQoJqBAAp8CxT7GDIGt97GT6a95VkrXhYJJXcS8F
AhYTcLLhde2IkLiJCBrm/ybod9nfdmvVAnV7g2lrX3CAv/hOfguV4siP8Op34WY1
BU3gh2Cn2bxGfowZsWEH2bCfBoH/08/ejWjg14kyaEQXERBXNn/tPOkkgkkBDSgV
wv/ppGBjtfCwZv2q2uCco8wyoWT80B3iGiuEX0mCie5gAQVgDTHHx6vwLz13LO9z
ZNZZvrI/Q9cABCmGPlXXh0X5hvO8mFhIXmPMGFHv/2CbBhtvRjt/aPwQh1BUdnZ+
9tnzvFnw7UuOEoPP21b7B+zNJuLhshzX2kCgZdrN/W1MSs2rBTryVvCjxQ7Gg4Hh
EJzWl3A50wUKtijJeH10KpBw6sflZUCSTmOkj1Pt7HwrnzCMBT3e88Yiki46tvHN
/HWgRfMDhtFKHJGsiA+bRwh73e2z/MFT9Z7u7HkgqceaAHYekPweusJre7sSIOrA
5HoSHmYG3L6b0lbXvCpPij4Mm0ZubJFIyFZoAN98lCXIfEDeyaB+JG3INdYG2sUY
kTfaudPq1OH3JsyO0lP89sCG3kPeLmw35LSFF2JKvx9LgtZXTUB52KQKol/et41C
opzPDJJPtSYrABPe/k/YfSeCfawKJI2+hFnEu3D4hF5o2gp2slvrbuT2SJaBNLLa
i7cHcR/SepA=
=Rku6
-----END PGP SIGNATURE-----

--AHVSF3we4xtO5oi5--
