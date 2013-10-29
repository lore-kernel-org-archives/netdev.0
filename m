From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] 3c515: Fix warning when building
Date: Tue, 29 Oct 2013 19:31:57 +0000
Message-ID: <1383075117.1534.23.camel@bwh-desktop.uk.level5networks.com>
References: <1382738386-29888-1-git-send-email-ricec2@rpi.edu>
	 <20131029.000316.767189982282205506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <ricec2@rpi.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18241 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab3J2TcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:32:01 -0400
In-Reply-To: <20131029.000316.767189982282205506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-29 at 00:03 -0400, David Miller wrote:
> From: Colin Rice <ricec2@rpi.edu>
> Date: Fri, 25 Oct 2013 21:59:46 +0000
> 
> > -		outl((int) (skb->data), ioaddr + Wn7_MasterAddr);
> > +		outl((size_t) (skb->data), ioaddr + Wn7_MasterAddr);
> 
> outl() takes an "int" not a "size_t".   You're avoiding the warning,
> but on 64-bit, for example, you're silently allowing the compiler
> to accept chopping off the top 32-bits of the 64-bit pointer address
> off.
> 
> The warning is valid, this code won't work in certain environments,
> and killing the warning is just papering over the problem such that
> it will never get addressed properly.
> 
> I'm not applying patches like this, sorry.

The driver is writing a virtual address as the DMA address.  The
hardware is an ISA device and will presumably ignore the top 8 bits,
thus doing the virt-to-bus conversion for us.  Very efficient - so long
as this runs on a PC with no more than 16 MB RAM.

For other chips with a DMA descriptor ring, the driver uses
isa_virt_to_bus() which is less efficient but no more correct.

Maybe the driver should just be deleted, as it doesn't look like it's
actually usable any more.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
