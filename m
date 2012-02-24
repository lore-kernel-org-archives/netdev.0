From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netlink: netlink_dump_start may take data pointer
 for callbacks
Date: Fri, 24 Feb 2012 17:47:26 -0500 (EST)
Message-ID: <20120224.174726.1107636579816083287.davem@davemloft.net>
References: <1330121648-2956-1-git-send-email-pablo@netfilter.org>
	<1330121648-2956-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330121648-2956-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 24 Feb 2012 23:14:07 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This patch modifies the netlink_dump_start function to take one
> generic pointer to data. This pointer can be used inside the
> dump() and done() callbacks via cb->data.
> 
> Netfilter is going to use this patch to provide filtered dumps
> to user-space. This is specifically interesting in ctnetlink that
> may handle lots of conntrack entries. We can save precious
> cycles by skipping the conversion to TLV format of conntrack
> entries that are not interesting for user-space.
> 
> More specifically, ctnetlink will include one operation to allow
> to filter the dumping of conntrack entries by ctmark values.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

This isn't really your fault but netlink_dump_start() has an
enormous number of arguments.

Several of them are zero or NULL in all except one special situation.

An entire argument is a lot of overhead for one situation to impose on
all the others.

I have no objection to the data callback scheme, it's just that
the argument list of this interface is getting out of control.

Usually, in situations like this, we have some control structure
that holds all the control state and we pass that in instead.

	struct netlink_dump_control c = { .dump = dump, .done = done, ... };

	netlink_dump_start(..., &c);

It could be perhaps used here to get things back under control.
