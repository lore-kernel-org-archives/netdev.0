From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix MTU calculation for non-ESP SAs
Date: Mon, 18 Jun 2007 18:09:11 +0200
Message-ID: <4676AE27.8020504@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030303070603080003090907"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Marco Berizzi <pupilla@hotmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36552 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606AbXFRQJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 12:09:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030303070603080003090907
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------030303070603080003090907
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix MTU calculation for non-ESP SAs

My IPsec MTU optimization patch introduced a regression in MTU calculation
for non-ESP SAs, the SA's header_len needs to be subtracted from the MTU if
the transform doesn't provide a ->get_mtu() function.

Reported-and-tested-by: Marco Berizzi <pupilla@hotmail.com>

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b31d763b8a6b9a6eba5b5805f81ae605ebeab475
tree 6beec3612b419286bf9d7c7b98551ee30172da01
parent 188e1f81ba31af1b65a2f3611df4c670b092bbac
author Patrick McHardy <kaber@trash.net> Mon, 18 Jun 2007 17:57:09 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 18 Jun 2007 17:57:09 +0200

 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 85f3f43..dfacb9c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1729,7 +1729,7 @@ int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 	    x->type && x->type->get_mtu)
 		res = x->type->get_mtu(x, mtu);
 	else
-		res = mtu;
+		res = mtu - x->props.header_len;
 	spin_unlock_bh(&x->lock);
 	return res;
 }

--------------030303070603080003090907--
