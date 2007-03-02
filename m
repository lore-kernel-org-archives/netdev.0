From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Thu, 01 Mar 2007 17:33:10 -0800 (PST)
Message-ID: <20070301.173310.74748069.davem@davemloft.net>
References: <200703011933.l21JX5hw018666@fire-2.osdl.org>
	<20070301143417.00b49e81.akpm@linux-foundation.org>
	<20070301143727.4ba00d04@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn,
	khc@pm.waw.pl
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56787
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1422683AbXCBBdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 20:33:13 -0500
In-Reply-To: <20070301143727.4ba00d04@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 1 Mar 2007 14:37:27 -0800

> Not necessary, since any network device must already allocated by
> alloc_netdev() and it initializes the whole struct to 0 (NULL).

It is in this case, unfortunately, HDLC protocols can be registers
several times before the device is brought up and protocol changes
become disallowed.

So you can attach one, then a second one, and the second one has
to explicitly initialize the pointers potentially set by the
first one.

On the other hand, you could say that it's the protocol
->detach() method's responsibility to NULL out these things
instead of leaving references to function pointers of
a module that's about the be unloaded.

