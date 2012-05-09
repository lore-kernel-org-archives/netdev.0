From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: update the usage of CHECKSUM_UNNECESSARY
Date: Wed, 9 May 2012 09:03:09 +0300
Message-ID: <20120509060308.GA13522@redhat.com>
References: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
 <20120508174831.GA27406@redhat.com>
 <1336501258.2749.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	devel@open-fcoe.org, jeffrey.t.kirsher@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23635 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756099Ab2EIGDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 02:03:22 -0400
Content-Disposition: inline
In-Reply-To: <1336501258.2749.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 08, 2012 at 07:20:58PM +0100, Ben Hutchings wrote:
> On Tue, 2012-05-08 at 20:48 +0300, Michael S. Tsirkin wrote:
> > On Mon, Mar 19, 2012 at 02:12:41PM -0700, Yi Zou wrote:
> > > As suggested by Ben, this adds the clarification on the usage of
> > > CHECKSUM_UNNECESSARY on the outgoing patch. Also add the usage
> > > description of NETIF_F_FCOE_CRC and CHECKSUM_UNNECESSARY
> > > for the kernel FCoE protocol driver.
> > > 
> > > This is a follow-up to the following:
> > > http://patchwork.ozlabs.org/patch/147315/
> > > 
> > > Signed-off-by: Yi Zou <yi.zou@intel.com>
> > > Cc: Ben Hutchings <bhutchings@solarflare.com>
> > > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > Cc: www.Open-FCoE.org <devel@open-fcoe.org>
> > > ---
> > > 
> > >  include/linux/skbuff.h |    7 +++++++
> > >  1 files changed, 7 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > index 8dc8257..a2b9953 100644
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -94,6 +94,13 @@
> > >   *			  about CHECKSUM_UNNECESSARY. 8)
> > >   *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
> > >   *
> > > + *	UNNECESSARY: device will do per protocol specific csum. Protocol drivers
> > > + *	that do not want net to perform the checksum calculation should use
> > > + *	this flag in their outgoing skbs.
> > > + *	NETIF_F_FCOE_CRC  this indicates the device can do FCoE FC CRC
> > > + *			  offload. Correspondingly, the FCoE protocol driver
> > > + *			  stack should use CHECKSUM_UNNECESSARY.
> > > + *
> > >   *	Any questions? No questions, good. 		--ANK
> > >   */
> > >  
> > 
> > So just to make sure I understand, you never get
> > UNNECESSARY packets on tx unless you declared NETIF_F_FCOE_CRC?
> > 
> > Maybe the comment says this somehow but could not figure it out.
> 
> That's what should happen now.  In future CHECKSUM_UNNECESSARY could be
> used on output by other protocols which don't use TCP/IP-style
> checksums, but always dependent on the output device supporting the
> relevant offload feature.
> 
> Ben.

Isn't there another case: a device passes UNNECESSARY in on rx,
and the skb is forwarded to another device?
For example it is handled this way by tun, giving a nice
performance boost for VMs, see 10a8d94a95742bb15b4e617ee9884bb4381362be

> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
