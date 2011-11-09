From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Wed, 9 Nov 2011 23:58:36 +0000
Message-ID: <1320883116.2781.35.camel@bwh-desktop>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
	 <1320678704.3020.33.camel@bwh-desktop>
	 <20111107154857.GC1833899@jupiter.n2.diac24.net>
	 <1320701749.3020.70.camel@bwh-desktop>
	 <20111107230710.GF1833899@jupiter.n2.diac24.net>
	 <1320711393.3020.89.camel@bwh-desktop>
	 <20111109153419.GJ1833899@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17451 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756802Ab1KIX6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 18:58:42 -0500
In-Reply-To: <20111109153419.GJ1833899@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-09 at 16:34 +0100, David Lamparter wrote:
> On Tue, Nov 08, 2011 at 12:16:33AM +0000, Ben Hutchings wrote:
> > > Hmm. I think we need to cleanly separate MTU and MFS. MTU is used for
> > > upper layer stuff like setting TCP MSS, IP fragment size, etc.
> > >
> > > MFS is the actual ethernet thing, and it's quite independent from the
> > > MTU. Imagine the following example case:
> >
> > I was proposing to make a distinction between the 'untagged' MTU
> > (dev->mtu) that would continue to be used by layer 3 and the physical
> > MTU that would take into account the needs of any related VLAN devices.
> 
> Ah. I think we're saying the same thing with different words.
> 
> > > How about instead of propagating the MFS up, we provide an user knob to
> > > adjust the MFS (on physical devices)?
> >
> > I suppose that may be necessary - unfortunately.
> 
> Hm. Basically, the current ndo_change_mtu call is severely misnamed, it
> actually changes the MFS. MTU isn't even relevant for the driver.

Well, the Ethernet standards effectively specify an MTU of 1500
regardless of VLAN tags rather than specfying a single maximum frame
size or properly acknowledging jumbos.  And so there is hardware that
implements limits in terms of payload length, not frame length.

> With that premise, it boils down to creating new "MFS" attributes for
> userspace, and cleanly splitting L2/L3 values inside the kernel.
> ndo_change_mtu would become ndo_change_mfs; there'd be a MFS_CHANGED
> notifier call; "mtu" becomes an IP-level thing.
> 
> While MFS constrains MTU, I'd prefer to avoid "automatic" functions like
> raising MFS to make the MTU fit. (Or, worse, lowering MTU if MFS gets
> changed. I'd return error instead and have the user fix his config.)
[...]

For backward compatibility, setting the MTU on a physical device must
also raise its MFS if necessary.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
