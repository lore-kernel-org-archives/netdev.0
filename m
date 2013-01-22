From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] rxclass: Show full 64 bits of user-data in
 rxclass_print_nfc_spec_ext()
Date: Tue, 22 Jan 2013 20:33:55 +0000
Message-ID: <1358886835.2892.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30841 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab3AVUd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 15:33:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously only the lower 32 bits would be shown.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I just noticed this bug when applying Yan Burman's patch.  Untested
since sfc doesn't support this field.

Ben.

 rxclass.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index 1564b62..cd686a3 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -49,7 +49,7 @@ static void rxclass_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
 		tci = ntohs(fsp->h_ext.vlan_tci);
 		tcim = ntohs(~fsp->m_ext.vlan_tci);
 		data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
-		data = (u64)ntohl(fsp->h_ext.data[1]);
+		data |= (u64)ntohl(fsp->h_ext.data[1]);
 		datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
 		datam |= (u64)ntohl(~fsp->m_ext.data[1]);
 
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
