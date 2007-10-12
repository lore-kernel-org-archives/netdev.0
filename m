From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/9] Consolidate IP fragment management
Date: Fri, 12 Oct 2007 16:55:10 +0400
Message-ID: <470F6EAE.60308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54336 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760395AbXJLM5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 08:57:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick recently pointed out, that there are three places that 
perform IP fragments management. In ipv4, ipv6 and in ip6 
conntracks. Looks like these places can be a bit consolidated.

The proposal is to create a common structure inet_frag_queue to 
put common fields like list heads, refcounts etc in, and include
it into the specific fragment queues. Then such objects like 
hash tables, lists, locks etc are moved to common place (struct 
inet_frags). At the end common code is moved to the 
net/ipv4/inet_fragment.c.

The inet_ prefix in file names, data structures and functions, and
the code place (net/ipv4) was proposed by Alexey, but the exact
names were selectd by me, so maybe there can be a better ones.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
