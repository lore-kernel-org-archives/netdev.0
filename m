From: David Miller <davem@davemloft.net>
Subject: Re: inetpeer with create==0
Date: Wed, 02 Mar 2011 21:36:34 -0800 (PST)
Message-ID: <20110302.213634.189680857.davem@davemloft.net>
References: <20110302.204545.193730647.davem@davemloft.net>
	<AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39855
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155Ab1CCFf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 00:35:57 -0500
In-Reply-To: <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 3 Mar 2011 13:30:03 +0800

> I am just wondering why we need a trie(radix tree) here, we don't have
> to do LPM since the lengths of the keys are always fixed(ether 4 or
> 16). Maybe a hash table is enough and simpler, and it is RCU
> compatible.

Because trie eliminates all of the issues of having to size a hash
table, dynamically resize it, etc.

Trie gives well bounded performance dependent solely upon size of
the table, rather than access patterns, distribution of keys, and
how perfect hash function is.

We used to use a hash table for the page cache too, but now we use
a trie structure there as well, and that uses full long word sized
keys and the generic raidx-tree code.

Using hash tables is really foolish for potentially large data sets.
