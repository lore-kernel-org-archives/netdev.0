From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: Use NLMSG_DEFAULT_SIZE in combination with
 nlmsg_new()
Date: Thu, 28 Jun 2012 13:10:46 -0400
Message-ID: <20120628171046.GG31808@canuck.infradead.org>
References: <caecbaa2f181c17908fbd61264e1acb9c5cb1fe1.1340891841.git.tgraf@suug.ch>
 <1340895349.13187.105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Sergey Lapin <slapin@ossfans.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36107 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab2F1RKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 13:10:50 -0400
Content-Disposition: inline
In-Reply-To: <1340895349.13187.105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 28, 2012 at 04:55:49PM +0200, Eric Dumazet wrote:
> On Thu, 2012-06-28 at 15:57 +0200, Thomas Graf wrote:
> > Using NLMSG_GOODSIZE results in multiple pages being used as
> > nlmsg_new() will automatically add the size of the netlink
> > header to the payload thus exceeding the page limit.
> 
> On the other hand, this limits to 3776 bytes for each recvmsg() call.
> 
> Maybe this can add a regression if one of the file needed to store more
> than 3776 bytes in the answer ?
> 
> For GFP_KERNEL allocations, I am not sure we really need to limit to
> order-0 pages...

We are talking about providing 16 bytes less space for data by default.
If there really are protocols that break with this change then those
protocols need to be fixed anyway.

Especially because NLMSG_GOODSIZE (and NLMSG_DEFAULT_SIZE) is not a
static value but depending on the page size so if a protocol needs a
message size of anywhere close to 4K then it definitely needs to
provide a size of its own.

> Unless you can point a real bug, this patch is not for net tree, but
> net-next.

It's actually based on the net-next tree, I just didn't flag it
properly.
