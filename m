From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (8/8) loopback device simplification
Date: Thu, 4 Sep 2003 12:14:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030904121421.51b2f993.shemminger@osdl.org>
References: <20030903164921.7d923008.shemminger@osdl.org>
	<3F568AC0.5090601@pobox.com>
	<20030903204105.0f01f131.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030903204105.0f01f131.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003 20:41:05 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Wed, 03 Sep 2003 20:43:44 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Would be nice to move dev_base and dev_base_lock somewhere, maybe 
> > drivers/net/net_init.c (which really should be renamed libnet.c) or 
> > perhaps somewhere in net/*
> 
> Once all of the conversions are done, we can happily move
> this someone.  My personal preference would be net/core/dev.c,
> as I believe we can limit all of the modifications to there
> eventually and thus not have to export those two symbols to
> the entire kernel any more.
> 
> The fact that we export the list and it's locking makes it
> really hard to change things.

my current idea is to switch dev_base_lock over to RCU and
change dev_base to a list macro.

#define for_each_netdev(_d)   list_for_each_entry_rcu(_d, &netdev_base, dev_list)
...
