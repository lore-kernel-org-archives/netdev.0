From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/8 net-2.6.26] [NETNS]: namespace refcounting cleanup
Date: Tue, 15 Apr 2008 16:35:59 +0400
Message-ID: <1208262959.21529.32.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:37587 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755005AbYDOMhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:37:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network namespace has two referrence counters:
- count
- use_count.
The namespace is scheduled to destruction automatically when the count
becomes 0.

There are several SLAB objects with a pointer to a namespace on them.
These objects are cleaned up during namespace stop. Some of them
increment use_count, some don't. This set fixes this discrepancy,
i.e. now all such objects increment the use_count.

Though, the use_count itself is used in a very debug manner and checked
only during namespace stop. So, I have placed it under
NETNS_REFCNT_DEBUG definition exactly like this is done for socket
refcounting code to remove extra atomic from any possible fast paths.

Signed-off-by: Denis V. Lunev <den@openvz.org>

