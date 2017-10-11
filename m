From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/2] ipv6: addrconf: make two more doit functions not use rtnl mutex
Date: Wed, 11 Oct 2017 10:27:59 +0200
Message-ID: <20171011082801.12715-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38988 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756661AbdJKI1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 04:27:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 RTM_GETNETCONF and RTM_GETADDR don't seem to require strict
serialization via rtnl mutex, so switch both to DOIT_UNLOCKED and increment
device reference counts instead.

Alternative would be to use rcu which would need some minor
code re-arrangements (we can't use GFP_ATOMIC for buffer allocation in that
case).

 addrconf.c |   38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)
