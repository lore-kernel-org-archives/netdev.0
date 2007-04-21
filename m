From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Eliminate some unnecessary gotos in tcp v4 hash
 handling
Date: Fri, 20 Apr 2007 17:16:14 -0700 (PDT)
Message-ID: <20070420.171614.46214862.davem@davemloft.net>
References: <200704051248.44989.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752969AbXDUAQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 20:16:11 -0400
In-Reply-To: <200704051248.44989.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Thu, 5 Apr 2007 12:48:44 +0200

> The compiler eliminates them anyways and this makes the code easier to read
> and shorter.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>

It depends upon who you ask :-)

For someone trying to verify "all code paths lead to foo and
therefore release resources and drop locks" it's always better
to use a goto to some common unwind handler at the end of
the function, regardless of what the compiler does with it.

When you're doing such an audit, return statements in the middle
of the function are red flags and make the audit more difficult.
:-)

But in these cases it's just straight returns and there are no
resources to release so I'll apply this patch, thanks!
