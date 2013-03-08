From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net/rds: zero last byte for strncpy
Date: Fri, 08 Mar 2013 11:19:32 +0800
Message-ID: <513958C4.1020404@asianux.com>
References: <512F1534.9020404@asianux.com>     <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>     <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com>    <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>    <51355936.3060307@asianux.com>   <1362453419.3768.380.camel@deadeye.wl.decadent.org.uk>   <51356735.4020405@asianux.com>  <1362454672.3768.383.camel@deadeye.wl.decadent.org.uk>  <51356FED.4070909@asianux.com> <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:25458 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759217Ab3CHDT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 22:19:58 -0500
In-Reply-To: <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  for NUL terminated string, need be always sure '\0' in the end.

additional info:
  strncpy will pads with zeroes to the end of the given buffer.
  should initialise every bit of memory that is going to be copied to userland


Signed-off-by: Chen Gang <gang.chen@asianux.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/rds/stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/rds/stats.c b/net/rds/stats.c
index 7be790d..73be187 100644
--- a/net/rds/stats.c
+++ b/net/rds/stats.c
@@ -87,6 +87,7 @@ void rds_stats_info_copy(struct rds_info_iterator *iter,
 	for (i = 0; i < nr; i++) {
 		BUG_ON(strlen(names[i]) >= sizeof(ctr.name));
 		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
+		ctr.name[sizeof(ctr.name) - 1] = '\0';
 		ctr.value = values[i];
 
 		rds_info_copy(iter, &ctr, sizeof(ctr));
-- 
1.7.7.6
