From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] rtnetlink: prepare for further rtnl lock pushdown/removal
Date: Thu, 21 Sep 2017 18:58:55 +0200
Message-ID: <20170921165902.10746-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39098 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751669AbdIUQ6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:58:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch adds a rudimentary vrf test case.

Remaining patches split large rtnl_fill_ifinfo into smaller chunks
to better see which parts

1. require rtnl
2. do not require it at all
3. rely on rtnl locking now but could be converted

add ASSERT_RTNL annotations/checks in a few spots as reminder for future
rtnl removal/pushdown patches.

 net/core/rtnetlink.c                     |  161 ++++++++++++++++++++++---------
 tools/testing/selftests/net/rtnetlink.sh |   42 ++++++++
 2 files changed, 161 insertions(+), 42 deletions(-)
