From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Wed, 17 Mar 2010 16:26:56 +0100
Message-ID: <4BA0F4C0.8050901@trash.net>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60241 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab0CQP06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 11:26:58 -0400
In-Reply-To: <20100316232957.4185.46217.stgit@decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Currently, ENOBUFS errors are reported to the socket via
> netlink_set_err() even if NETLINK_RECV_NO_ENOBUFS is set. However,
> that should not happen. This fixes this problem and it changes the
> prototype of netlink_set_err() to return the number of sockets whose
> error has been set. This allows to know if any error has been set.
> This return value is used in the next patch in these bugfix series.

But that only happens if we have a message allocate error, which is
a different situation than rcvqueue overrun, which I thought the
original patch was supposed to handle (disable netlink congestion
control).

Is there any problem with these errors?
