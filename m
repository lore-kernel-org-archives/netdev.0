From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Thu, 22 Mar 2007 22:14:49 +0300
Message-ID: <20070322191449.GA25274@2ka.mipt.ru>
References: <20070322180957.GA17793@2ka.mipt.ru> <20070322114304.1e516507@freekitty> <20070322185944.GA3802@2ka.mipt.ru> <20070322.120346.41643926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51464 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbXCVTPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 15:15:41 -0400
Content-Disposition: inline
In-Reply-To: <20070322.120346.41643926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 12:03:46PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 22 Mar 2007 21:59:44 +0300
> 
> > Yes, current code does not support statistics.
> > Existing stats run over whole hash table, I do not like such approach,
> > so I will introduce a per-protocol lists of all sockets, which can be
> > accessed from statistics code, but it is next step.
> 
> We are _NOT_ bloating up the socket structure even more because your
> data structure does not support a "iterate over all objects"
> operation.

And to be absolutely clear - existing interface does not support it too
- we iterate over every single hash entry, and then over every single
item in the chain (if it exists). I can create the same for the tree -
it is not complex at all, but it is not the most optimal solution, and 
since I remove several entries, I think it is not that bad to remove a 
bit less and optimize 'iterate over all object' case a bit.

-- 
	Evgeniy Polyakov
