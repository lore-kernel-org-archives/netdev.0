From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 0/2] flow_dissector: Flow dissector fixes
Date: Fri,  1 Sep 2017 14:04:10 -0700
Message-ID: <20170901210412.2915-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        alex.popov@linux.com, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36309 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752392AbdIAVEk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 17:04:40 -0400
Received: by mail-pf0-f172.google.com with SMTP id r187so3572376pfr.3
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 14:04:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes some basic issues with __skb_flow_dissect function.

Items addressed:
  - Cleanup control flow in the function; in particular eliminate a
    bunch of goto's and implement a simplified control flow model
  - Add limits for number of encapsulations and headers that can be
    dissected

v2:
  - Simplify the logic for limits on flow dissection. Just set the
    limit based on the number of headers the flow dissector can
    processes. The accounted headers includes encapsulation headers,
    extension headers, or other shim headers.

Tested:

Ran normal traffic, GUE, and VXLAN traffic.

*** BLURB HERE ***

Tom Herbert (2):
  flow_dissector: Cleanup control flow
  flow_dissector: Add limit for number of headers to dissect

 include/net/flow_dissector.h |   8 ++
 net/core/flow_dissector.c    | 242 +++++++++++++++++++++++++++++--------------
 2 files changed, 172 insertions(+), 78 deletions(-)

-- 
2.11.0
