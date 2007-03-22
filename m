From: David Miller <davem@davemloft.net>
Subject: Re: [ANN] Unified dynamic storage for different socket types
 instead of separate hash tables.
Date: Thu, 22 Mar 2007 12:21:20 -0700 (PDT)
Message-ID: <20070322.122120.115923509.davem@davemloft.net>
References: <20070322185944.GA3802@2ka.mipt.ru>
	<20070322.120346.41643926.davem@davemloft.net>
	<20070322191449.GA25274@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49682
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933247AbXCVTVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:21:21 -0400
In-Reply-To: <20070322191449.GA25274@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Mar 2007 22:14:49 +0300

> And to be absolutely clear - existing interface does not support it too
> - we iterate over every single hash entry, and then over every single
> item in the chain (if it exists). I can create the same for the tree -
> it is not complex at all, but it is not the most optimal solution, and 
> since I remove several entries, I think it is not that bad to remove a 
> bit less and optimize 'iterate over all object' case a bit.

This results in your trie having two new run-time costs:

1) More expensive trie insert/delete compared to hash
   insert/delete

2) An extra list insert/delete to give list of all sockets

So connection setup/teardown will be more expensive and
therefore our connection rates will be lower.

Evgeniy, your ideas are beautiful in theory, but all the details
kill all of your non-trivial work and make it useless in the end.
