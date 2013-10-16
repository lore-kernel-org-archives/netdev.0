From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v4 2/5] xen-netback: add support
 for IPv6 checksum offload from guest
Date: Wed, 16 Oct 2013 17:11:59 +0100
Message-ID: <1381939919.30409.4.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-3-git-send-email-paul.durrant@citrix.com>
	 <20131014104235.GB11739@zion.uk.xensource.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD0138B8D@AMSPEX01CL01.citrite.net>
	 <20131014105527.GD11739@zion.uk.xensource.com>
	 <525BE148.1010508@citrix.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD0138D3C@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18031 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753873Ab3JPQMC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:12:02 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0138D3C@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-14 at 13:34 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: David Vrabel
> > Sent: 14 October 2013 13:19
> > To: Wei Liu
> > Cc: Paul Durrant; netdev@vger.kernel.org; Ian Campbell; David Vrabel; xen-
> > devel@lists.xen.org
> > Subject: Re: [Xen-devel] [PATCH net-next v4 2/5] xen-netback: add support
> > for IPv6 checksum offload from guest
> > 
> > On 14/10/13 11:55, Wei Liu wrote:
> > > On Mon, Oct 14, 2013 at 11:49:20AM +0100, Paul Durrant wrote:
> > >>> -----Original Message-----
> > >>> From: Wei Liu [mailto:wei.liu2@citrix.com]
> > >>> Sent: 14 October 2013 11:43
> > >>> To: Paul Durrant
> > >>> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David
> > Vrabel;
> > >>> Ian Campbell
> > >>> Subject: Re: [PATCH net-next v4 2/5] xen-netback: add support for IPv6
> > >>> checksum offload from guest
> > >>>
> > >>> On Fri, Oct 11, 2013 at 04:06:19PM +0100, Paul Durrant wrote:
> > >>> [...]
> > >>>> -/*
> > >>>> - * This is the amount of packet we copy rather than map, so that the
> > >>>> - * guest can't fiddle with the contents of the headers while we do
> > >>>> - * packet processing on them (netfilter, routing, etc).
> > >>>> +/* This is a miniumum size for the linear area to avoid lots of
> > >>>> + * calls to __pskb_pull_tail() as we set up checksum offsets.
> > >>>>   */
> > >>>
> > >>> You seem to forget to explain why 128 is chosen. :-)
> > >>
> > >> Is that not sufficient explanation? What sort of thing are you looking for?
> > >>
> > >
> > >>From the second version of this patch, we had a conversation.
> > >
> > >> Where does 128 come from?
> > >>
> > >
> > > "It's just an arbitrary power of 2 that was chosen because it seems to
> > > cover most likely v6 headers and all v4 headers."
> > >
> > > So something like: "We choose 128 which is likely to cover most V6
> > > headers and all V4 headers" would be sufficeint.
> > 
> > Is "most IPv6 headers" actually good enough?  Don't we need to ensure
> > netback copies all IP headers?
> > 
> 
> It will do if checksum offload is in use, but perhaps the pull as far
> as the transport header needs to be done anyway? I'm unsure of the
> expectations of other code.

I've always been under the impression that transport headers needed
pulling up too, for the benefit of netfilter perhaps?

AIUI the frags should be pure "payload". I may be wrong about that
though...

Ian.
