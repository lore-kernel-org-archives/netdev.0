From: Michael Smith <msmith@cbnco.com>
Subject: [PATCH v2 0/2] Disable rp_filter for IPsec packets
Date: Thu,  7 Apr 2011 10:51:49 -0400
Message-ID: <1302187911-20688-1-git-send-email-msmith@cbnco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cbnco.com ([207.164.182.72]:47791 "EHLO smtp.cbnco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab1DGOp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 10:45:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.cbnco.com (Postfix) with ESMTP id A4FF3B754BE
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:24 -0400 (EDT)
Received: from smtp.cbnco.com ([127.0.0.1])
 by localhost (mail.cbnco.com [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 15219-07 for <netdev@vger.kernel.org>;
 Thu,  7 Apr 2011 10:45:24 -0400 (EDT)
Received: from sles10-64.jrz.cbn (dmzgw2.cbnco.com [207.164.182.65])
	by smtp.cbnco.com (Postfix) with ESMTPS id EA5BFB66EBF
	for <netdev@vger.kernel.org>; Thu,  7 Apr 2011 10:45:23 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reverse path filter interferes with IPsec subnet-to-subnet tunnels,
especially when the link to the IPsec peer is on an interface other than
the one hosting the default route.

IPsec provides a much stronger anti-spoofing policy than rp_filter, so
this patch disables the rp_filter for packets with a security path.

Patch is against net-next.

(old discussion here: http://patchwork.ozlabs.org/patch/86826/)

Michael Smith (2):
  fib_validate_source(): pass sk_buff instead of mark
  Disable rp_filter for IPsec packets

 include/net/ip_fib.h    |    6 +++---
 include/net/xfrm.h      |    9 +++++++++
 net/ipv4/fib_frontend.c |   16 +++++++++-------
 net/ipv4/route.c        |   16 ++++++++--------
 4 files changed, 29 insertions(+), 18 deletions(-)

