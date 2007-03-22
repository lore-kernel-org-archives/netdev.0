From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 22:20:08 +0300
Message-ID: <20070322192007.GA1181@2ka.mipt.ru>
References: <20070322185944.GA3802@2ka.mipt.ru> <20070322.120346.41643926.davem@davemloft.net> <20070322190939.GA18792@2ka.mipt.ru> <20070322.121441.39171370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49584 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933282AbXCVTUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:20:55 -0400
Content-Disposition: inline
In-Reply-To: <20070322.121441.39171370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 12:14:41PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 22 Mar 2007 22:09:40 +0300
> 
> > I specially have only one hash structure in the socket - skc_bind_node -
> > to be used for statistics and remove hash and skc_node (and for netlink
> > broadcasting too), so this code reduces socket structure by 12 bytes on
> > x86 (20 bytes on x86_64).
> 
> Yes, for your trie you've removed quite a bit, but now you're
> going to add 2 pointers right back right?

No, I will use the same hlist_node pointer (skc_bind_node) which was
there, and skc_node and skc_node are removed.

After all - we can traverse over the whole tree one-by one, it is even
possible to attach a bitmask to each level node (since it is an array)
of used/free entries and use it.

-- 
	Evgeniy Polyakov
