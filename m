From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] ethtool: Fix handling of zero weights for flow
 hash indirection
Date: Fri, 06 Aug 2010 14:38:03 +0100
Message-ID: <1281101883.2088.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17052 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761366Ab0HFNiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 09:38:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop to generate an indirection table from a list of weights never
advances by more than one weight at a time.  Thus, if there is a 0
in the list (except at the end) the corresponding RX ring will be
assigned 1 hash bucket rather than 0.  Change 'if' to 'while'.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Please include this in 2.6.35 if you haven't finalised it yet.

Ben.

 ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 0f7dec6..66b5c07 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2977,7 +2977,7 @@ static int do_srxfhindir(int fd, struct ifreq *ifr)
 
 		j = -1;
 		for (i = 0; i < indir->size; i++) {
-			if (i >= indir->size * partial / sum) {
+			while (i >= indir->size * partial / sum) {
 				j += 1;
 				weight = get_u32(rxfhindir_weight[j], 0);
 				partial += weight;
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

