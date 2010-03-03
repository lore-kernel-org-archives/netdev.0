From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] rstp: Fix compiler type-punning error in rstp daemon
Date: Wed, 3 Mar 2010 08:53:31 -0500
Message-ID: <20100303135331.GA7211@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33847 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab0CCNxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 08:53:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Was trying to build the rstp daemon today and got a type-punning error
in bridge_track.c.  This patch fixes it up.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 bridge_track.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/bridge_track.c b/bridge_track.c
index be555de..fa59732 100644
--- a/bridge_track.c
+++ b/bridge_track.c
@@ -599,7 +599,7 @@ void bridge_bpdu_rcv(int if_index, const unsigned char *data, int len)
 		//    TST(ntohs(*(uint16_t*)bpdu.body.message_age)
 		//        < ntohs(*(uint16_t*)bpdu.body.max_age), );
 		TST(memcmp(bpdu->body.bridge_id, &ifc->master->bridge_id, 8) != 0
-		    || (ntohs(*(uint16_t *) bpdu->body.port_id) & 0xfff) !=
+		    || (ntohs((uint16_t) *bpdu->body.port_id) & 0xfff) !=
 		    ifc->port_index,);
 		break;
 	case BPDU_TOPO_CHANGE_TYPE:
