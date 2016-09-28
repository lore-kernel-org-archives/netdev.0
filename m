From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 12/12] hack: rocker: no ip frag match
Date: Wed, 28 Sep 2016 14:43:02 +0200
Message-ID: <1475066582-1971-13-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33820 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932395AbcI1Mn0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:26 -0400
Received: by mail-lf0-f43.google.com with SMTP id y6so50005803lff.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:25 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

*** hack; for informational purposes only; not for upstream merge ***

Open vSwitch expects to match on the fragmentation state, however, the
of-dpa world of rocker does not implement such a field in its flow key. As
a work-around ignore it to allow testing (in the absence of fragments).

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 3b441359a3a7..2f20f1ded5bf 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2931,9 +2931,6 @@ static int ofdpa_port_sw_flow_match(struct ofdpa_port *ofdpa_port,
 		return -ENOTSUPP;
 
 	if (flow->attrs | BIT_ULL(OVS_KEY_ATTR_IPV4)) {
-		if (mask->ip.frag)
-			/* There is no IP frag match in OF-DPA */
-			return -ENOTSUPP;
 		if (mask->ipv4.addr.src != cpu_to_be32(0) ||
 		    mask->ipv4.addr.dst != cpu_to_be32(0))
 			/* Rocker doesn't implement these matches */
-- 
2.7.0.rc3.207.g0ac5344
