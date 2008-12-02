From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix /proc/net/ip_mr_cache display
Date: Tue, 02 Dec 2008 15:03:30 -0800 (PST)
Message-ID: <20081202.150330.157587697.davem@davemloft.net>
References: <493415B4.7020600@bull.net>
	<20081201093341.537bf03d@extreme>
	<20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Benjamin.Thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbYLBXD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 18:03:29 -0500
In-Reply-To: <20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Benjamin Thery " <Benjamin.Thery@bull.net>
Date: Mon, 01 Dec 2008 21:17:02 +0100

> The right way to fix it, IMHO, is to print 0 (zero) in the columns
> that have no meaning for the unresolved entries. That way we don't
> break the ABI: the userspace expects to get at least 6 numbers for
> each entries, it gets 6 numbers. It's easy to figure what zeros
> represent and this prevent people from wasting time trying to figure
> what to do with these "random" numbers on the unresolved entries, no?

Probably, this is correct.

However, we could run into problems if userland parsers expect
6 entries and then expect an immediate newline.  We'd break that.

The only thing that really works for extending files like this
is if they are already exporting a "key: value" interface, then
you can add new lines safely.

Doing this horizontal expansion as you are proposing here is,
on the other hand, very risky and dangerous.

I really don't think it's worth it.

Fix the garbage values, or flush them to zero if we can't
represent them properly.  But don't add new stuff horizontally
to "fill in the gaps", as I don't think it can be done %100
safely.
