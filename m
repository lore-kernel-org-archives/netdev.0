From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v3] xen-netfront: Add support for
 IPv6 offloads
Date: Tue, 7 Jan 2014 15:12:34 +0000
Message-ID: <1389107554.12612.43.camel@kazak.uk.xensource.com>
References: <1385484112-12975-1-git-send-email-paul.durrant@citrix.com>
	 <52C31691.9040302@oracle.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD01E2C05@AMSPEX01CL01.citrite.net>
	 <52CC1500.8050104@oracle.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD01E4F72@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, Annie Li <annie.li@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19338 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbaAGPMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:12:46 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD01E4F72@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 15:05 +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: Boris Ostrovsky [mailto:boris.ostrovsky@oracle.com]
> > Sent: 07 January 2014 14:54
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; Ian Campbell;
> > Annie Li; David Vrabel
> > Subject: Re: [Xen-devel] [PATCH net-next v3] xen-netfront: Add support for
> > IPv6 offloads
> > 
> > On 01/07/2014 05:25 AM, Paul Durrant wrote:
> > >> -----Original Message-----
> > >> From: Boris Ostrovsky [mailto:boris.ostrovsky@oracle.com]
> > >> Sent: 31 December 2013 19:10
> > >> To: Paul Durrant
> > >> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Konrad Rzeszutek
> > >> Wilk; David Vrabel; Ian Campbell; Wei Liu; Annie Li
> > >> Subject: Re: [PATCH net-next v3] xen-netfront: Add support for IPv6
> > offloads
> > >>
> > >> On 11/26/2013 11:41 AM, Paul Durrant wrote:
> > >>> This patch adds support for IPv6 checksum offload and GSO when those
> > >>> features are available in the backend.
> > >> Sorry for late review. Mostly style comments.
> > >>
> > > Thanks for the review.
> > >
> > > The checksum related code essentially needs to be a duplicate of that in
> > netback and it seems wasteful to have the code in both places. Could this
> > code be moved perhaps to net/core/dev.c? It's not specific to
> > netback/netfront usage.
> > 
> > Will any of these routines be called for anything other than Xen
> > networking?
> > 
> 
> I guess similar logic must be duplicated in other drivers - I can't
> believe that netback and netfront are the only ones to want to know
> where the TCP/UDP checksum field is located.

Me neither. Given that we already have two consumers (albeit both *xen*)
and that the functionality is generic in nature it seems to make sense
to me to have it in a generic place.

> > I don't know about net/core/dev.c but given the large amount of
> > duplicate code between netfront and netback I think factoring out should
> > be done at least for these two. Into xen-netcore.c or some such.
> > 
> 
> That's probably a pragmatic first step; I'll do that and post a patch series as v4.

I think this makes sense for code which has two consumers (both *xen*)
but which is actually Xen specific. Obviously if the network maintainers
don't think the checksum functionality is plausibly generically useful
then we could put it here instead.

Ian.
