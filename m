From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes
 down
Date: Thu, 17 Oct 2013 22:52:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.03.1310172245440.2016@ssi.bg>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com> <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59666 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756787Ab3JQTw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 15:52:58 -0400
In-Reply-To: <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 17 Oct 2013, Kristian Evensen wrote:

> From: Kristian Evensen <kristian.evensen@gmail.com>
> 
> When a link is set as down using for example "ip link set dev X down", routes
> are deleted, but RTM_DELROUTE messages are not sent to RTNLGRP_IPV4_ROUTE. This
> patch makes trie_flush_list() send a RTM_DELROUTE for each route that is
> removed, and makes rtnelink route deletion behavior consistent across commands.
> The parameter lists for trie_flush_list() and trie_flush_leaf() are expanded to
> include required information otherwise unavailable in trie_flush_list().
> 
> One use case that is simplified by this patch is IPv4 WAN connection monitoring.
> Instead of listening for and handling both RTM_*ROUTE and RTM_*LINK-messages, it
> is sufficient to handle RTM_*ROUTE.

	IIRC, such notifications were not implemented
to avoid storms to routing daemons. Not sure if this is
still true.

Regards

--
Julian Anastasov <ja@ssi.bg>
