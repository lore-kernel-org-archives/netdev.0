From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 0/2] addrlabel: don't use rtnl locking
Date: Tue, 29 Aug 2017 13:29:40 +0200
Message-ID: <20170829112942.4791-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56344 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752881AbdH2L3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 07:29:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrlabel doesn't appear to require rtnl lock as the addrlabel
table uses a spinlock to serialize add/delete operations.

Also, entries are reference counted so it should be safe
to call the rtnl ops without the rtnl mutex.
