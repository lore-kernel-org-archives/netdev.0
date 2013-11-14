From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 1/3] net_tstamp: Improve kernel-doc for struct
 hwtstamp_config
Date: Thu, 14 Nov 2013 02:38:55 +0000
Message-ID: <1384396735.29151.37.camel@bwh-desktop.uk.level5networks.com>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24744 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3KNCi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:38:58 -0500
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the name of the rx_filter field.

Remove text about 32/64-bit compatibility; this works just the same as
for most socket ioctls and as the structure is not allowed to grow
there is no need to remind anyone how to maintain it.

Add explanation about drivers changing the filter mode.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/uapi/linux/net_tstamp.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index ae5df122e42f..c9a7de2a6276 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -30,13 +30,13 @@ enum {
  *
  * @flags:	no flags defined right now, must be zero
  * @tx_type:	one of HWTSTAMP_TX_*
- * @rx_type:	one of one of HWTSTAMP_FILTER_*
+ * @rx_filter:	one of HWTSTAMP_FILTER_*
  *
  * %SIOCSHWTSTAMP expects a &struct ifreq with a ifr_data pointer to
- * this structure. dev_ifsioc() in the kernel takes care of the
- * translation between 32 bit userspace and 64 bit kernel. The
- * structure is intentionally chosen so that it has the same layout on
- * 32 and 64 bit systems, don't break this!
+ * this structure.  If the driver or hardware does not support the
+ * requested @rx_filter value, the driver may use a more general
+ * filter mode.  In this case @rx_filter will indicate the actual mode
+ * on return.
  */
 struct hwtstamp_config {
 	int flags;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
