From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/10] Fix leaking of kernel heap addresses in net/
Date: Fri, 12 Nov 2010 12:37:38 -0800 (PST)
Message-ID: <20101112.123738.179940542.davem@davemloft.net>
References: <1289546610.17691.1770.camel@edumazet-laptop>
	<20101112083315.096dfaa3@nehalam>
	<20101112201850.GA5625@core2.telecom.by>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932417Ab0KLUhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:37:14 -0500
In-Reply-To: <20101112201850.GA5625@core2.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 12 Nov 2010 22:18:50 +0200

> On Fri, Nov 12, 2010 at 08:33:15AM -0800, Stephen Hemminger wrote:
>> Also, the whole idea needs to be under a config option, so only
>> the paranoid idiots turn it on.
> 
> Would be fun if something will break because ffff8800bcd498c0
> will become something else. :-)

Actually, this is not even a joke.

Take a look at how we track what sockets a user wants dumped via
the inet_diag netlink facility, the socket pointer is used as
the identification cookie.

I'm sure we'll now get some more security theatre about how we
have to undo that too.

More and more I see this whole idea as extremely rediculious.

If I can write to or read kernel memory, I can look up the
sockets, inodes, and whatever else we're currently exposing
the addresses of.  Even without a symbol table, which is
readily available, I can easily find the ksymtab and find the
inode and socket hash table addresses there.

This whole exercise is closing the barn door after the horses have
already escaped, and it's causing all kinds of inconveniences
that we really have no need for.
