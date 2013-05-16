From: Tom Parkin <tparkin@katalix.com>
Subject: [RFC] l2tp: avoid checksum offload for fragmented packets
Date: Thu, 16 May 2013 18:04:19 +0100
Message-ID: <1368723860-22749-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40301 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368Ab3EPRE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 13:04:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP encapsulated L2TP data is currently subject to checksum errors if hardware
checksum offload is used, and the packet is fragmented.

This patch works around this issue by falling back to software checksumming if
the packet looks like it might fragment.

The problem with this approach (and the "RFC" part) is that we don't know how
big the IP header will be for the packet.  If we guess at the worst-case
scenario of 60b we can be sure to avoid checksum errors, but we may also be
using expensive software checksums in some cases where we don't really need
to.

Any suggestions on a better approach to solving this problem?  Should we be
using socket corking similar to the UDP code so that we can examine whether
the IP layer fragmented the packet after calling ip_append_data?

Tom Parkin (1):
  l2tp: avoid checksum offload for fragmented packets

 net/l2tp/l2tp_core.c |   53 ++++++++++++++++++++++++++++++--------------------
 1 file changed, 32 insertions(+), 21 deletions(-)

-- 
1.7.9.5
