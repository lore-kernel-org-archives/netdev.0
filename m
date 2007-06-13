From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 23:41:01 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7DD6D@nekter>
References: <20070612.140240.00078635.davem@davemloft.net> <466F0C92.5080306@garzik.org> <466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net> <20070612214753.GB27363@metaxa.reflex>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <greearb@candelatech.com>, <jeff@garzik.org>,
	<netdev@vger.kernel.org>, <kaber@trash.net>, <hadi@cyberus.ca>,
	<peter.p.waskiewicz.jr@intel.com>, <auke-jan.h.kok@intel.com>
To: "Jason Lunz" <lunz@falooley.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:34998 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754194AbXFMDnu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 23:43:50 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070612214753.GB27363@metaxa.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jason Lunz
> Sent: Tuesday, June 12, 2007 2:48 PM
> To: David Miller
> Cc: greearb@candelatech.com; jeff@garzik.org; netdev@vger.kernel.org;
> kaber@trash.net; hadi@cyberus.ca; peter.p.waskiewicz.jr@intel.com;
> auke-jan.h.kok@intel.com
> Subject: Re: [PATCH] NET: Multiqueue network device support.
> 
> On Tue, Jun 12, 2007 at 02:26:58PM -0700, David Miller wrote:
> > The MAC is still very much centralized in most designs.
> >
> > So one way they'll do it is to support assigning N MAC addresses,
> > and you configure the input filters of the chip to push packets
> > for each MAC to the proper receive queue.
> >
> > So the MAC will accept any of those in the N MAC addresses as
> > it's own, then you use the filtering facilities to steer
> > frames to the correct RX queue.
> >
> > The TX and RX queues can be so isolated as to be able to be exported
> > to virtualization nodes.  You can give them full access to the DMA
> > queues and assosciated mailboxes.  So instead of all of this bogus
> > virtualized device overhead, you just give the guest access to the
> > real device.
> >
> > So you can use multiple queues either for better single node SMP
> > performance, or better virtualization performance.
> 
> Are you aware of any hardware designs that allow other ways to map
> packets onto rx queues?  I can think of several scenarios where it
> could
> be advantageous to map packets by IP 3- or 5-tuple to get cpu locality
> all the way up the stack on a flow-by-flow basis. But doing this would
> require some way to request this mapping from the hardware.

10GbE Xframe NICs do that, as well as rx steering by MAC address, VLAN,
MS RSS, generic hashing and bunch of other criteria (there is actually a
decent chapter on rx steering in the ASIC manual at www.neterion.com
support page).
The caveat is that in the current products the tuple table is limited to
256 entries only. Next ASIC bumps this number to 64k.

> 
> In the extreme case it would be cool if it were possible to push a
> bpf-like classifier down into the hardware to allow arbitrary kinds of
> flow distribution.
> 
> Jason
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
