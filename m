From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN vs bridging receive precedence
Date: Fri, 22 Jan 2010 20:34:56 +0000
Message-ID: <1264192497.2784.31.camel@achroite.uk.solarflarecom.com>
References: <20100122031153.GA26565@gondor.apana.org.au>
	 <1264180303.2784.19.camel@achroite.uk.solarflarecom.com>
	 <20100122201331.GA2974@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51084 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933Ab0AVUfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 15:35:01 -0500
In-Reply-To: <20100122201331.GA2974@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-01-23 at 09:13 +1300, Herbert Xu wrote:
> On Fri, Jan 22, 2010 at 05:11:42PM +0000, Ben Hutchings wrote:
> .
> > The administrator might just be trying to bridge a VLAN to a guest.
> > 
> > XenCenter attaches a bridge interface ('Network') to each NIC.  The
> > administrator can define additional Networks which are associated with
> > VLANs on specific NICs; for each of these it attaches a VLAN interface
> > to the physical interface and a bridge interface to the VLAN interface.
> 
> But that should work perfectly.  The problem here is that the
> bridge is being attached to the physical interface, no?

As I said, it attaches a bridge interface to each NIC (physical
interface) to start with - whether or not the administrator chooses to
bridge the NIC to any guest interfaces.  So it doesn't work without VLAN
receive acceleration.

> > Ideally people wouldn't mix tagged and untagged traffic, and then
> > XenCenter could refuse to bridge both a physical interface and a VLAN
> > attached to it.  In practice, people do mix them, and I think we need to
> > work out what the proper semantics are.
> 
> Mixing should work as well, as long as you don't attach both
> bridging and VLAN to the physical interface.

And if you are going to mix them, on a virtualised server you may want
to bridge them both to guests, separately.  That seems to require either
that a VLAN interface and a bridge interface can be attached to the
physical interface, with the VLAN interface taking precedence on
receive; or that a virtual interface accepting only untagged traffic can
be attached to the physical interface.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

