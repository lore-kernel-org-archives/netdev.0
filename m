From: "Lee A. Roberts" <lee.roberts@hp.com>
Subject: [PATCH 0/4] sctp: fix association hangs due to reassembly/ordering logic
Date: Tue, 26 Feb 2013 07:36:12 -0700
Message-ID: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
Cc: lee.roberts@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:46564 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297Ab3BZOf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 09:35:26 -0500
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 057F338019
	for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 14:35:25 +0000 (UTC)
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
