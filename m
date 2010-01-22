From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN vs bridging receive precedence
Date: Fri, 22 Jan 2010 17:11:42 +0000
Message-ID: <1264180303.2784.19.camel@achroite.uk.solarflarecom.com>
References: <20100122031153.GA26565@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37547 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754662Ab0AVRLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 12:11:46 -0500
In-Reply-To: <20100122031153.GA26565@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-22 at 16:11 +1300, Herbert Xu wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> >
> > It is not clear which behaviour is 'correct'.  However it appears that
> > the XenCenter network management software currently depends on the
> > accelerated behaviour.
> 
> My question would be why would you have both VLAN and bridging
> on the same physical interface in the first place?
> 
> These two configurations are well-defined and work as expected:
> 
> 1) Bridging after VLAN: The bridge only includes the VLAN device,
> ethX.Y, not the physical ethX.
> 2) VLAN after bridging: The VLAN should be linked to the bridge
> device, i.e., brX.Y, and not the physical ethX.
> 
> So what exactly is the admin trying to achieve here?

The administrator might just be trying to bridge a VLAN to a guest.

XenCenter attaches a bridge interface ('Network') to each NIC.  The
administrator can define additional Networks which are associated with
VLANs on specific NICs; for each of these it attaches a VLAN interface
to the physical interface and a bridge interface to the VLAN interface.

Ideally people wouldn't mix tagged and untagged traffic, and then
XenCenter could refuse to bridge both a physical interface and a VLAN
attached to it.  In practice, people do mix them, and I think we need to
work out what the proper semantics are.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

