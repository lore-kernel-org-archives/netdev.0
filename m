From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH] l2tp: avoid checksum offload for fragmented packets
Date: Mon,  3 Jun 2013 08:49:21 +0100
Message-ID: <1370245762-5126-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41174 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab3FCHta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 03:49:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP encapsulated L2TP data is currently subject to checksum errors if hardware
checksum offload is used and the packet is fragmented through the L2TP tunnel.

This patch works around this issue by falling back to software checksumming if
the packet will fragment.

This patch is based on the previous RFC patch, with the following ammendments:

	* Ben LaHaise's comments on header length calculation and IPv6
	  checksumming have been integrated

	* l2tp_xmit_ipv6_csum has been updated in a similar manner to the new
	  l2tp_xmit_ipv4_csum

Tom Parkin (1):
  l2tp: avoid checksum offload for fragmented packets

 net/l2tp/l2tp_core.c |   65 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 46 insertions(+), 19 deletions(-)

-- 
1.7.9.5
