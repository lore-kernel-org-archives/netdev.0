From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/3] l2tp: make datapath sequence number handling RFC-compliant
Date: Tue,  2 Jul 2013 11:00:26 +0100
Message-ID: <1372759229-15178-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42618 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732Ab3GBKJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 06:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP data sequence numbers, if enabled, ensure in-order delivery. A
receiver may reorder data packets, or simply drop out-of-sequence
packets. If reordering is not enabled, the current implementation does
not handle data packet loss correctly, which can result in a stalled
L2TP session datapath as soon as the first packet is lost. Most L2TP
users either disable sequence numbers or enable data packet reordering
when sequence numbers are used to circumvent the issue. This patch
series fixes the problem, and makes the L2TP sequence number handling
RFC-compliant.

James Chapman (3):
  l2tp: do data sequence number handling in a separate func
  l2tp: make datapath sequence number support RFC-compliant
  l2tp: make datapath resilient to packet loss when sequence numbers
    enabled

 net/l2tp/l2tp_core.c |  116 +++++++++++++++++++++++++++++++++++++++----------
 net/l2tp/l2tp_core.h |    5 ++
 2 files changed, 97 insertions(+), 24 deletions(-)
