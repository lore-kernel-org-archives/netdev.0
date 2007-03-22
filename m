From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 22:40:25 +0300
Message-ID: <20070322194024.GA21378@2ka.mipt.ru>
References: <20070322191449.GA25274@2ka.mipt.ru> <20070322.122120.115923509.davem@davemloft.net> <20070322193051.GB1181@2ka.mipt.ru> <20070322.123604.70210071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:41042 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934200AbXCVTk5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:40:57 -0400
Content-Disposition: inline
In-Reply-To: <20070322.123604.70210071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 12:36:04PM -0700, David Miller (davem@davemloft.net) wrote:
> > > 2) An extra list insert/delete to give list of all sockets
> > 
> > That is too small price.
> 
> In your imagination.  Our connection rates went up significantly
> when I got rid of the linked list we had many years ago.
> 
> Every memory access matters.

Ok, I never liked linked lists actually. :)

This one can be completely eliminated (hmm, it does not even exist so
far) by having per-node bitmask of used/free entries - it will be 
even faster than existing access and will not require locks (due to RCU
protection).

So, this allows to remove additional hlist_node structure from socket
(and change netlink one to not use it in broadcasting, so for netlink
sockets it will be moved into private netlink structure).

-- 
	Evgeniy Polyakov
