From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] rtnetlink: Link address family API
Date: Wed, 17 Nov 2010 11:30:35 -0800 (PST)
Message-ID: <20101117.113035.229752488.davem@davemloft.net>
References: <20101116143014.GA26669@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935246Ab0KQTaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 14:30:10 -0500
In-Reply-To: <20101116143014.GA26669@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@infradead.org>
Date: Tue, 16 Nov 2010 09:30:14 -0500

> Each net_device contains address family specific data such as
> per device settings and statistics. We already expose this data
> via procfs/sysfs and partially netlink.
> 
> The netlink method requires the requester to send one RTM_GETLINK
> request for each address family it wishes to receive data of
> and then merge this data itself.
> 
> This patch implements a new API which combines all address family
> specific link data in a new netlink attribute IFLA_AF_SPEC.
> IFLA_AF_SPEC contains a sequence of nested attributes, one for each
> address family which in turn defines the structure of its own
> attribute. Example:
> 
>    [IFLA_AF_SPEC] = {
>        [AF_INET] = {
>            [IFLA_INET_CONF] = ...,
>        },
>        [AF_INET6] = {
>            [IFLA_INET6_FLAGS] = ...,
>            [IFLA_INET6_CONF] = ...,
>        }
>    }
> 
> The API also allows for address families to implement a function
> which parses the IFLA_AF_SPEC attribute sent by userspace to
> implement address family specific link options.
> 
> Signed-off-by: Thomas Graf <tgraf@infradead.org>

Applied, but note that as-implemented it has the "partial update"
problem.  When we can't get the af-specific ops for a "parse"
operation, we just skip that AF yet we let the modifications of
the other AF's succeed and make it appear to the user that
everything got updated and all the attributes were consumed.

I don't know what we can do about this with how things work
right now.
