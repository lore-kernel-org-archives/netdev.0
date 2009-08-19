From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: Change RSS ring to MSIx vector mapping.
Date: Wed, 19 Aug 2009 16:53:08 -0700
Message-ID: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23652 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753336AbZHSX6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 19:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave and All,

Attached is a respin of the changes posted earlier this week.
The new RX buffer changes were removed from this series
and will be address them in a separate series when these changes
are accepted.

Changes are as follows:

1) Move TX completion processing from a worker thread to
   the send path.  This reduces overhead and causes better
   locality for freeing TX resources.  It also prevents
   the TX completion rings from using MSIx vectors hence
   allowing them all to be used for RSS rings.

2) Change RSS ring to MSIx vector mapping.  Some platforms
   are stingy with vectors.  This change causes all vectors
   to be used for RSS rings.  Previously there was a dedicated
   ring/vector for handling broadcast/multicast and
   various events from the chip and firmware.  This 'default'
   functionality is now performed by the zeroth RSS ring before
   waking NAPI for normal RX processing.
   This is a big patch but is mostly deletions.

3) Remove worker threads and ISR that were rendered unused
   by #2 above.  They were left in the code for patch #2
   to make it more readable.

Regards,
Ron Mercer


