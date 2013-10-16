From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 1/5] xen-netback: add support for IPv6
 checksum offload to guest
Date: Wed, 16 Oct 2013 17:10:32 +0100
Message-ID: <1381939832.30409.3.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-2-git-send-email-paul.durrant@citrix.com>
	 <1381748013.24708.102.camel@kazak.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD0138C0B@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43846 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759231Ab3JPQKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:10:36 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0138C0B@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-14 at 12:10 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Ian Campbell
> > Sent: 14 October 2013 11:54
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel
> > Subject: Re: [PATCH net-next v4 1/5] xen-netback: add support for IPv6
> > checksum offload to guest
> > 
> > On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> > > Check xenstore flag feature-ipv6-csum-offload to determine if a
> > > guest is happy to accept IPv6 packets with only partial checksum.
> > > Also check analogous feature-ip-csum-offload to determine if a
> > > guest is happy to accept IPv4 packets with only partial checksum
> > > as a replacement for a negated feature-no-csum-offload value and
> > > add a comment to deprecate use of feature-no-csum-offload.
> > >
> > > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > > Cc: Wei Liu <wei.liu2@citrix.com>
> > > Cc: David Vrabel <david.vrabel@citrix.com>
> > > Cc: Ian Campbell <ian.campbell@citrix.com>
> > 
> > Shouldn't this come later in the series, i.e. after netback is actually
> > able to cope with ipv6 offloads?
> > 
> 
> I guess that's debatable. The patches don't have any dependency relation; offloads to and from the guest are quite independent.
> 
> > > diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-
> > netback/common.h
> > > index 5715318..b4a9a3c 100644
> > > --- a/drivers/net/xen-netback/common.h
> > > +++ b/drivers/net/xen-netback/common.h
> > > @@ -153,7 +153,8 @@ struct xenvif {
> > >  	u8 can_sg:1;
> > >  	u8 gso:1;
> > >  	u8 gso_prefix:1;
> > > -	u8 csum:1;
> > > +	u8 ip_csum:1;
> > > +	u8 ipv6_csum:1;
> > 
> > Why not ipv4_csum for consistency/unambiguity?
> > 
> 
> I followed general linux naming conventions e.g. ip_hdr and ipv6_hdr.

True. I would be more concerned about the netif.h name, but I think you
now intend to drop the v4 variant of that, so no worries.
