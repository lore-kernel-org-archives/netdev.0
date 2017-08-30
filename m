From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/2] tcp: re-add header prediction
Date: Wed, 30 Aug 2017 19:24:56 +0200
Message-ID: <20170830172458.18544-1-fw@strlen.de>
Cc: edumazet@google.com
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:35756 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750972AbdH3RYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:24:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric reported a performance regression caused by header prediction
removal.

We now call tcp_ack() much more frequently, for some workloads
this brings in enough cache line misses to become noticeable.

We could possibly still kill HP provided we find a different
way to suppress unneeded tcp_ack, but given we're late in
the cycle it seems preferable to revert.
