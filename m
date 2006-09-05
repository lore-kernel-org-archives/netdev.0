From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 problem on powerpc
Date: Mon, 4 Sep 2006 20:41:48 -0700
Message-ID: <20060904204148.6f9749b3@localhost.localdomain>
References: <1157347462.22705.16.camel@localhost.localdomain>
	<1157354470.22705.26.camel@localhost.localdomain>
	<1157355748.22705.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26533 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965127AbWIEDlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2006 23:41:55 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1157355748.22705.32.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 04 Sep 2006 17:42:27 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> This fixes sky2 driver on big endian machines. I choose not to use the
> hardware byteswap facility as it would have required to have a different
> definition of the various ring data structures and it looks ugly :) On
> powerpc, there is pretty much no overhead at doing byteswap.
> 
> The patch has a couple of places where I reversed 2 assignments, they
> are harmless, it was before I figured out that the chip will
> (apparently) not access a descriptor before it's been told to do so via
> MMIO, and thus the order of the writes to the descriptors is irrelevant
> (I was also adding wmb's though I removed them).

I'll put a minimized version of this in the next patch set.
There is no need to re order assignments.

> 
> There is a couple of places where we were doing a BE and not LE
> conversion of a descriptor field (typically in the VLAN code). I'm not
> sure what's up there but BE "felt" wrong. I have turned them into LE
> conversions but then I haven't tested VLAN, and I might just
> misudnerstand what's happening there so I'll let you decide what to do
> about those.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

It may not need any swapping, it is hard to tell what the hardware
will do without experimentation.
