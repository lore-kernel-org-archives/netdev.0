From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v2 net-next 1/7] net: define receive timestamp filter for NTP
Date: Tue,  2 May 2017 12:10:57 +0200
Message-ID: <20170502101103.30444-2-mlichvar@redhat.com>
References: <20170502101103.30444-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751135AbdEBKLT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 06:11:19 -0400
In-Reply-To: <20170502101103.30444-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add HWTSTAMP_FILTER_NTP_ALL to the hwtstamp_rx_filters enum for
timestamping of NTP packets. There is currently only one driver
(phyter) that could support it directly.

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 include/uapi/linux/net_tstamp.h | 3 +++
 net/core/dev_ioctl.c            | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 464dcca..0749fb1 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -125,6 +125,9 @@ enum hwtstamp_rx_filters {
 	HWTSTAMP_FILTER_PTP_V2_SYNC,
 	/* PTP v2/802.AS1, any layer, Delay_req packet */
 	HWTSTAMP_FILTER_PTP_V2_DELAY_REQ,
+
+	/* NTP, UDP, all versions and packet modes */
+	HWTSTAMP_FILTER_NTP_ALL,
 };
 
 #endif /* _NET_TIMESTAMPING_H */
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index b94b1d2..8f036a7 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -227,6 +227,8 @@ static int net_hwtstamp_validate(struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		rx_filter_valid = 1;
 		break;
+	case HWTSTAMP_FILTER_NTP_ALL:
+		break;
 	}
 
 	if (!tx_type_valid || !rx_filter_valid)
-- 
2.9.3
