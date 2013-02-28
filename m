From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v3 0/4] sctp: fix association hangs due to reassembly/ordering logic
Date: Thu, 28 Feb 2013 07:37:26 -0700
Message-ID: <1362062250-26749-1-git-send-email-lee.roberts@hp.com>
References: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Cc: linux-sctp@vger.kernel.org, lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:39221 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab3B1Oge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 09:36:34 -0500
In-Reply-To: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

This series of patches resolves several SCTP association hangs observed during
SCTP stress testing.  Observable symptoms include communications hangs with
data being held in the association reassembly and/or lobby (ordering) queues.
Close examination of reassembly/ordering queues may show either duplicated
or missing packets.

In version #2, corrected build failure in initial version of patch series
due to wrong calling sequence for sctp_ulpq_partial_delivery() being inserted
in sctp_ulpq_renege().

In version #3, adjusted patch documentation to be less repetitive.

Lee A. Roberts (4):
  sctp: fix association hangs due to off-by-one errors in
    sctp_tsnmap_grow()
  sctp: fix association hangs due to reneging packets below the
    cumulative TSN ACK point
  sctp: fix association hangs due to errors when reneging events from
    the ordering queue
  sctp: fix association hangs due to partial delivery errors

 net/sctp/tsnmap.c   |   13 ++++----
 net/sctp/ulpqueue.c |   87 +++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 78 insertions(+), 22 deletions(-)

-- 
1.7.9.5
