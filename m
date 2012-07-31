From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Properly purge netdev references on uncached
 routes.
Date: Tue, 31 Jul 2012 16:04:08 -0700 (PDT)
Message-ID: <20120731.160408.994710172149748635.davem@davemloft.net>
References: <20120731.152033.1148018322961121079.davem@davemloft.net>
	<20120731154455.2acf97a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab2GaXEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 19:04:11 -0400
In-Reply-To: <20120731154455.2acf97a8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 31 Jul 2012 15:44:55 -0700

> On Tue, 31 Jul 2012 15:20:33 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> 
>> When a device is unregistered, we have to purge all of the
>> references to it that may exist in the entire system.
>> 
>> If a route is uncached, we currently have no way of accomplishing
>> this.
>> 
>> So create a global list that is scanned when a network device goes
>> down.  This mirrors the logic in net/core/dst.c's dst_ifdown().
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> What about systems will full 1M route table?
> I wonder if doing rbtree here would make the search faster?

It only happens for routes like 255.255.255.255 and for those who
use tclassid on input.

Everything else is cached in the existing FIB trie entries.
