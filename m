From: =?UTF-8?q?Pavel=20=C5=A0imerda?= <pavlix@pavlix.net>
Subject: [PATCH 3/7] ip-xfrm: support 'proto any' with 'sport' and 'dport'
Date: Mon, 13 Apr 2015 16:00:57 +0200
Message-ID: <1428933661-8193-3-git-send-email-pavlix@pavlix.net>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, psimerda@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fox.pavlix.net ([84.246.161.104]:47547 "EHLO fox.pavlix.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919AbbDMOKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 10:10:03 -0400
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Pavel =C5=A0imerda <psimerda@redhat.com>

When creating an IPsec SA that sets 'proto any' (IPPROTO_IP) and
specifies 'sport' and 'dport' at the same time in selector, the
following error is issued:

"sport" and "dport" are invalid with proto=3Dip

However using IPPROTO_IP with ports is completely legal and necessary
when one wants to share the SA on both TCP and UDP. One of the
applications requiring sharing SAs is 3GPP IMS AKA authentication.

See also:

 * https://bugzilla.redhat.com/show_bug.cgi?id=3D497355

Reported-by: Ji=C5=99=C3=AD Klime=C5=A1 <jklimes@redhat.com>
Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>
---
 ip/ipxfrm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 95f91a5..e685571 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1339,6 +1339,7 @@ static int xfrm_selector_upspec_parse(struct xfrm=
_selector *sel,
 		case IPPROTO_UDP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
+		case IPPROTO_IP: /* to allow shared SA for different protocols */
 			break;
 		default:
 			fprintf(stderr, "\"sport\" and \"dport\" are invalid with PROTO val=
ue \"%s\"\n", strxf_proto(sel->proto));
--=20
2.3.5
