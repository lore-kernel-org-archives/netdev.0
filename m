From: Dave Jones <davej@codemonkey.org.uk>
Subject: af_packet: tone down the Tx-ring unsupported spew.
Date: Mon, 4 Apr 2016 15:11:50 -0400
Message-ID: <20160404191150.GA7224@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:41576 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbcDDTLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 15:11:54 -0400
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.86_2)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1an9ui-0006lh-HG
	for netdev@vger.kernel.org; Mon, 04 Apr 2016 20:11:53 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trinity and other fuzzers can hit this WARN on far too easily,
resulting in a tainted kernel that hinders automated fuzzing.

Replace it with a rate-limited printk.

Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1ecfa710ca98..f12c17f355d9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -4151,7 +4151,7 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 
 	/* Opening a Tx-ring is NOT supported in TPACKET_V3 */
 	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
-		WARN(1, "Tx-ring is not supported.\n");
+		net_warn_ratelimited("Tx-ring is not supported.\n");
 		goto out;
 	}
 
