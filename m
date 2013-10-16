From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Wed, 16 Oct 2013 18:01:05 +0100
Message-ID: <1381942865.30409.27.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-6-git-send-email-paul.durrant@citrix.com>
	 <1381942156.30409.19.camel@kazak.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD013B24B@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47817 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996Ab3JPRBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 13:01:23 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD013B24B@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 17:52 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Ian Campbell
> > Sent: 16 October 2013 17:49
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel
> > Subject: Re: [PATCH net-next v4 5/5] xen-netback: enable IPv6 TCP GSO to
> > the guest
> > 
> > On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> > > This patch adds code to handle SKB_GSO_TCPV6 skbs and construct
> > appropriate
> > > extra or prefix segments to pass the large packet to the frontend. New
> > > xenstore flags, feature-gso-tcpv6 and feature-gso-tcpv6-prefix, are
> > sampled
> > > to determine if the frontend is capable of handling such packets.
> > 
> > IIRC the reason we have feature-gso-tcpv4 and feature-gso-tcpv4-prefix
> > is that the former did things in a way which Windows couldn't cope with.
> > I assuming that is true for v6 too. But could Linux cope with the prefix
> > version too for v6 and reduce the number of options? Or is the
> > non-prefix variant actually better, if the guest can manage, for some
> > reason?
> >
> 
> The non-prefix variant actually conveys type information and so will
> be better for frontends that don't have to re-parse the headers
> anyway.

Make sense, thanks.

> 
>   Paul
>  
> > I suppose in the end its all piggybacking off the v4 code paths so
> > supporting both isn't a hardship.
> > 
> 
