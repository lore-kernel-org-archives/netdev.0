From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next] ethtool: Set cmd field in ETHTOOL_GLINKSETTINGS
 response to wrong nwords
Date: Mon, 14 Mar 2016 01:05:38 +0000
Message-ID: <20160314010537.GD21187@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="vGgW1X5XWziG23Ko"
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42503 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932513AbcCNBFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 21:05:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vGgW1X5XWziG23Ko
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

When the ETHTOOL_GLINKSETTINGS implementation finds that userland is
using the wrong number of words of link mode bitmaps (or is trying to
find out the right numbers) it sets the cmd field to 0 in the response
structure.

This is inconsistent with the implementation of every other ethtool
command, so let's remove that inconsistency before it gets into a
stable release.

Fixes: 3f1ac7a700d03 ("net: ethtool: add new ETHTOOL_xLINKSETTINGS API")
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
David, please can you include this in changes for 4.6?

Ben.

 net/core/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2966cd0d7c93..f426c5ad6149 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -655,7 +655,7 @@ static int ethtool_get_link_ksettings(struct net_device *dev,
 	    != link_ksettings.base.link_mode_masks_nwords) {
 		/* wrong link mode nbits requested */
 		memset(&link_ksettings, 0, sizeof(link_ksettings));
-		/* keep cmd field reset to 0 */
+		link_ksettings.base.cmd = ETHTOOL_GLINKSETTINGS;
 		/* send back number of words required as negative val */
 		compiletime_assert(__ETHTOOL_LINK_MODE_MASK_NU32 <= S8_MAX,
 				   "need too many bits for link modes!");

--vGgW1X5XWziG23Ko
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVuYOYee/yOyVhhEJAQqORxAAkRpYVvVB3SUNR2NhfaBuIvHQ67+6pS3k
1xNyyX8e36Ah41yZXZA1WIPJmmmI9Sg/7zdBfFkkEISsbiyZsb9trr5M/UtrQ/xf
fSyn9+4RH8EZdWO5km62uvZ1+3LCtyK01Mr0p4SvPmNKcK0qVGkjqSh8+I3mgkDP
gSaF4BziO/xMc/TIxSIdaHVC2+9jiyM8Paiwl1H6rEqZk6MGz88DQlMTmQ+/uBJF
F4+RgZMfxTjchGHfKxUVvtsR6jrlKINQwV5yznsPn+00qKOxiihE0YVcq30dp3Ic
TTJnzeKdnkoqmYX0jOzylWbmR89YrX/GOhQNFaRKOnI+vsFbyQLXTm+6/tWqC6Gq
MbU2yxE3/UG2Rg3QI0JRzwCpTUcFyNarIriP34sYX0S7s9JtG2uWwMM0m2CPc2ND
Wa8WFRoWbuJ351rFCKffvbXKGv/88WNJ17xQgfjyaS1+Qfp7/pmuA4N4X0gGOrhu
fhlS2kmjDmmOL63PUe6UboCNQlXhUt9DlSChtoB8GfKDRyiOua5B5qMJWVjaH7bI
AqSnsCis2IxZ6A6Gqc/63nM+/9VejtSfbxW9UcYwi2HUy5ehd7DnxAqfhdT8mq8X
79Yy55jlk61POzDGOcJzfI+EVHUp5QHk9MgELDAW5R8bhpAhVy8XIJL3EM9dQE7B
tAAM/8gVRGc=
=neyA
-----END PGP SIGNATURE-----

--vGgW1X5XWziG23Ko--
