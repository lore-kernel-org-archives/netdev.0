From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 0/2] ipv4: fix problems from the RTNH_F_LINKDOWN introduction
Date: Fri, 30 Oct 2015 10:23:32 +0200
Message-ID: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Andy Gospodarek <gospo@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49556 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030224AbbJ3IX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 04:23:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix two problems from the change that introduced RTNH_F_LINKDOWN
flag. The first patch deals with the removal of local route on
DOWN event. The second patch makes sure the RTNH_F_LINKDOWN
flag is properly updated on UP event because the DOWN event
sets it in all cases.

v2->v3:
- use bool for force var

v1->v2:
- forgot to add ifconfig dummy0 down in the test case
- split to 2 patches

Julian Anastasov (2):
  ipv4: fix to not remove local route on link down
  ipv4: update RTNH_F_LINKDOWN flag on UP event

 include/net/ip_fib.h     |  2 +-
 net/ipv4/fib_frontend.c  | 13 +++++++------
 net/ipv4/fib_semantics.c | 18 +++++++++++++++---
 3 files changed, 23 insertions(+), 10 deletions(-)

-- 
1.9.3
