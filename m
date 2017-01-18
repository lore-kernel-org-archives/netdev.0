From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 0/2] net: Fix oops on state free after lwt module unload
Date: Wed, 18 Jan 2017 15:32:01 +0000
Message-ID: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:51464 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751642AbdARPdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:33:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes an oops in lwtstate_free and a memory leak that
would otherwise be exposed by ensuring that references are taken on
modules that need to stay around to clean up lwt state. To faciliate
this all ops that implement destroy_state and that can be configured
to build as a module are changed specify the owner module in the
ops. The intersection of those two sets is just ila at the moment.

Robert Shearman (2):
  lwtunnel: Fix oops on state free after encap module unload
  ila: Fix memory leak of lwt dst cache on module unload

 include/net/lwtunnel.h |  2 ++
 net/core/lwtunnel.c    | 11 +++++++++--
 net/ipv6/ila/ila_lwt.c |  1 +
 3 files changed, 12 insertions(+), 2 deletions(-)

-- 
2.1.4
