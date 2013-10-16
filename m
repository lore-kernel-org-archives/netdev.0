From: Vlad Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net 0/3] sctp: Use software checksum under certain
Date: Tue, 15 Oct 2013 22:01:28 -0400
Message-ID: <1381888891-31186-1-git-send-email-vyasevich@gmail.com>
Cc: linux-sctp@vger.kernel.org, fan.du@windriver.com,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:35753 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab3JPCBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 22:01:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some cards that support SCTP checksum offloading.  When using
these cards with IPSec or forcing IP fragmentation of SCTP traffic,
the checksum is computed incorrectly due to the fact that xfrm and IP/IPv6
fragmentation code do not know that this is SCTP traffic and do not
know that checksum has to be computed differently.

To fix this, we let SCTP detect these conditions and perform software
checksum calculation.

Fan Du (1):
  sctp: Use software crc32 checksum when xfrm transform will happen.

Vlad Yasevich (2):
  net: dst: provide accessor function to dst->xfrm
  sctp: Perform software checksum if packet has to be fragmented.

 include/net/dst.h | 12 ++++++++++++
 net/sctp/output.c |  3 ++-
 2 files changed, 14 insertions(+), 1 deletion(-)

-- 
1.8.3.1
