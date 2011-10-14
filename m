From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 19:18:45 -0400 (EDT)
Message-ID: <20111014.191845.232827637484150228.davem@davemloft.net>
References: <20111014.034224.1197576516015404466.davem@davemloft.net>
	<4E985A3F.5080103@hp.com>
	<4E98B3B4.20406@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab1JNXTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 19:19:03 -0400
In-Reply-To: <4E98B3B4.20406@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 14 Oct 2011 15:12:04 -0700

> From just a very quick look it looks like tcp_v[46]_rcv is called,
> finds that the socket is owned by the user, attempts to add to the
> backlog, but the path called by sk_add_backlog does not seem to make
> any attempts to compress things, so when the quantity of data is <<
> the truesize it starts tossing babies out with the bathwater.

This is why I don't believe the right fix is to add bandaids all
around the TCP layer.

The wastage has to be avoided at a higher level.
