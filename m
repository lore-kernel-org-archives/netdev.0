From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/3] netlink: fix NETLINK_RECV_NO_ENOBUFS in netlink_set_err()
Date: Thu, 18 Mar 2010 14:02:27 +0100
Message-ID: <4BA22463.6050601@trash.net>
References: <20100316232247.4185.19426.stgit@decadence> <20100316232957.4185.46217.stgit@decadence> <4BA0F4C0.8050901@trash.net> <4BA10095.2030905@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab0CRNC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 09:02:29 -0400
In-Reply-To: <4BA10095.2030905@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Currently, ENOBUFS errors are reported to the socket via
>>> netlink_set_err() even if NETLINK_RECV_NO_ENOBUFS is set. However,
>>> that should not happen. This fixes this problem and it changes the
>>> prototype of netlink_set_err() to return the number of sockets whose
>>> error has been set. This allows to know if any error has been set.
>>> This return value is used in the next patch in these bugfix series.
>> But that only happens if we have a message allocate error, which is
>> a different situation than rcvqueue overrun, which I thought the
>> original patch was supposed to handle (disable netlink congestion
>> control).
> 
> Yes, allocation is a different situation but we still report ENOBUFS to
> user-space. I think that NETLINK_RECV_NO_ENOBUFS is there to a) disable
> ENOBUFS reports to user-space and b) disable Netlink congestion.
> 
>> Is there any problem with these errors?
> 
> Specifically in ctnetlink, if we fail to allocate a message in ctnetlink
> and NETLINK_RECV_NO_ENOBUFS is set, we still lose an event and that
> should not happen.

I assume you mean "not set"? Otherwise I fail to follow :)

