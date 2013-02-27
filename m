From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH v2 0/4] sctp: fix association hangs due to reassembly/ordering logic
Date: Wed, 27 Feb 2013 11:54:29 -0700
Message-ID: <1361991273-30578-1-git-send-email-lee.roberts@hp.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Cc: lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:30135 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760738Ab3B0Sxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 13:53:42 -0500
Received: from g5t0029.atlanta.hp.com (g5t0029.atlanta.hp.com [16.228.8.141])
	by g6t0187.atlanta.hp.com (Postfix) with ESMTP id 3CAC2281D4
	for <netdev@vger.kernel.org>; Wed, 27 Feb 2013 18:53:42 +0000 (UTC)
In-Reply-To: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Lee A. Roberts" <lee.roberts@hp.com>

This series of patches resolves several SCTP association hangs observed during
SCTP stress testing.  Observable symptoms include communications hangs with
data being held in the association reassembly and/or lobby (ordering) queues.
Close examination of reassembly/ordering queues may show either duplicated
or missing packets.

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
