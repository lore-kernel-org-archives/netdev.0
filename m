From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Wed, 05 Nov 2008 02:26:19 -0800 (PST)
Message-ID: <20081105.022619.151487044.davem@davemloft.net>
References: <20081105095428.GA4584@x200.localdomain>
	<20081105.015552.33573006.davem@davemloft.net>
	<49116F66.4030305@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754479AbYKEK0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 05:26:44 -0500
In-Reply-To: <49116F66.4030305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 05 Nov 2008 11:03:18 +0100

> David Miller wrote:
> > About the rmmod thing, we can do something similar to how
> > we handle nesting of irq_regs().  Ie. there are things that
> > push and pop the stack of ->error_desc.  rmmod operations
> > could be one of those things
> 
> Alternatively we could simply strdup the error message (or copy it
> to a reserved area to avoid running into memory allocation errors).
> That avoids having to mess with foreign task structs when
> unloading modules.

Since the error message is "const char *" I don't see why
you'd need to strdup() it ever, just the pointer is fine.

Well, I guess we could run into problems with module unloading
and the strings being from that module hmmm...
