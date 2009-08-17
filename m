From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC net-next PATCH 0/4] qlge: Performance changes for qlge.
Date: Mon, 17 Aug 2009 14:08:45 -0700
Message-ID: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39434 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885AbZHQVO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

Looking for feedback on changes for qlge.  The goal is to:

1) Do TX completions in send path (with cleaner timer).

2) Change RSS queue count to match MSIx vector count instead
   of CPU count.  Some platforms didn't offer enough vectors
   for our previous approach.

3) Change large RX buffer logic to use either multiple pages
   or chunks of pages based on MTU and system page size.

   Examples:

   64k Pages with 1500 MTU.  The RX buffers size would be
   2048 bytes and there would be 32 per page.

   4k pages with 9000 MTU.  The RX buffer size would be 16k,
   or 4 pages per buffer.

Regards,
Ron Mercer
