From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/2] net: core: rcuify rtnl af_ops
Date: Mon, 16 Oct 2017 15:44:34 +0200
Message-ID: <20171016134436.25282-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35776 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752095AbdJPNoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 09:44:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of the rtnl af_ops callbacks sleep, so they can be called while
holding rcu read lock.

Switch handling of af_ops to rcu.

This would allow to later call af_ops functions without holding
the rtnl mutex anymore.

 core/rtnetlink.c |  134 ++++++++++++++++++++++++++++++++++++-------------------
 ipv4/devinet.c   |    4 -
 2 files changed, 90 insertions(+), 48 deletions(-)
