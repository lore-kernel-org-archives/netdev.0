From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] ipv4: Properly purge netdev references on uncached
 routes.
Date: Tue, 31 Jul 2012 15:44:55 -0700
Message-ID: <20120731154455.2acf97a8@nehalam.linuxnetplumber.net>
References: <20120731.152033.1148018322961121079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47093 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752787Ab2GaWpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 18:45:24 -0400
In-Reply-To: <20120731.152033.1148018322961121079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jul 2012 15:20:33 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> When a device is unregistered, we have to purge all of the
> references to it that may exist in the entire system.
> 
> If a route is uncached, we currently have no way of accomplishing
> this.
> 
> So create a global list that is scanned when a network device goes
> down.  This mirrors the logic in net/core/dst.c's dst_ifdown().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

What about systems will full 1M route table?
I wonder if doing rbtree here would make the search faster?
