From: Marcel Holtmann <marcel@holtmann.org>
Subject: Removing GENL_ID_GENERATE breaks userspace API
Date: Thu, 2 Mar 2017 17:50:38 +0100
Message-ID: <E04592A3-747F-4C80-8650-5F1AEE28F92B@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:43956 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752195AbdCBQur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 11:50:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

you have removed GENL_ID_GENERATE in 4.10, but that is actually breaking userspace API.

commit a07ea4d9941af5a0c6f0be2a71b51ac9c083c5e5
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Mon Oct 24 14:40:02 2016 +0200

    genetlink: no longer support using static family IDs

diff --git a/include/uapi/linux/genetlink.h b/include/uapi/linux/genetlink.h
index 5512c90af7e3..d9b2db4a29c6 100644
--- a/include/uapi/linux/genetlink.h
+++ b/include/uapi/linux/genetlink.h
@@ -26,7 +26,6 @@ struct genlmsghdr {
 /*
  * List of reserved static generic netlink identifiers:
  */
-#define GENL_ID_GENERATE       0
 #define GENL_ID_CTRL           NLMSG_MIN_TYPE

Since the GENL_ID_GENERATE is in include/uapi/ I would have expected that you leave this in. For us, you just broke userspace API with this change.

Regards

Marcel
