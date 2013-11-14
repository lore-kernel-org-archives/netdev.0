From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 0/3] net_tstamp: Add SIOCGHWTSTAMP ioctl
Date: Thu, 14 Nov 2013 02:37:15 +0000
Message-ID: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24704 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3KNChU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:37:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIOCSHWTSTAMP returns the real configuration to the application
using it, but there is currently no way for any other
application to find out the configuration non-destructively.

This series adds a new ioctl with the obvious name which just reads the
configuration, and an example implementation for the sfc driver.

This information could alternately be added to struct ethtool_ts_info
returned by the ethtool ETHTOOL_GET_TS_INFO command, although that
wouldn't be very symmetric.  There would also be a problem of how to
indicate whether this extra information is present, given that all
fields of hwtstamp_config can validly be 0.

Ben.

Ben Hutchings (3):
  net_tstamp: Improve kernel-doc for struct hwtstamp_config
  net_tstamp: Add SIOCGHWTSTAMP ioctl to match SIOCSHWTSTAMP
  sfc: Implement the SIOCGHWTSTAMP ioctl

 drivers/net/ethernet/sfc/efx.c  |  2 +-
 drivers/net/ethernet/sfc/ptp.c  | 14 +++++++++-----
 include/uapi/linux/net_tstamp.h | 16 ++++++++--------
 include/uapi/linux/sockios.h    |  3 ++-
 net/core/dev_ioctl.c            |  2 ++
 5 files changed, 22 insertions(+), 15 deletions(-)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
