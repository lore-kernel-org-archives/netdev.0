From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] fib_hash: improve route deletion scaling on
 interface drop with lots of interfaces
Date: Mon, 26 Oct 2009 17:24:14 -0700
Message-ID: <20091026172414.34f66f9f@nehalam>
References: <20091027000302.GA3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39655 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224AbZJ0AYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 20:24:16 -0400
In-Reply-To: <20091027000302.GA3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2009 20:03:02 -0400
Benjamin LaHaise <bcrl@lhnet.ca> wrote:

> Hi folks,
> 
> Below is a patch to improve the scaling of interface destruction in 
> fib_hash.  The general idea is to tie the fib_alias structure into a 
> list off of net_device and walk that list during a fib_flush() caused 
> by an interface drop.  This makes the resulting flush only have to walk 
> the number of routes attached to an interface rather than the number of 
> routes attached to all interfaces at the expense of a couple of additional 
> pointers in struct fib_alias.
> 
> This patch is against Linus' tree.  I'll post against net-next after a 
> bit more testing and feedback.  With 20,000 interfaces & routes, interface 
> deletion time improves from 53s to 40s.  Note that this is with other changes 
> applied to improve sysfs and procfs scaling, as otherwise those are the 
> bottleneck.  Next up in the network code is rt_cache_flush().  Comments?
> 
> 		-ben
> 

Any one doing large number of interfaces should be using FIB_TRIE?



-- 
