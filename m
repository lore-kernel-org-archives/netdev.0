From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v4] xen-netback: fix fragment detection in checksum
 setup
Date: Tue, 3 Dec 2013 14:34:56 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD019E311@AMSPEX01CL01.citrite.net>
References: <1386005715-27566-1-git-send-email-paul.durrant@citrix.com>
 <20131203140243.GF14293@zion.uk.xensource.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD019E1E0@AMSPEX01CL01.citrite.net>
 <20131203142838.GH14293@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25736 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630Ab3LCOe6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 09:34:58 -0500
In-Reply-To: <20131203142838.GH14293@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 03 December 2013 14:29
> To: Paul Durrant
> Cc: Wei Liu; xen-devel@lists.xen.org; netdev@vger.kernel.org; Zoltan Kiss;
> Ian Campbell; David Vrabel; David Miller
> Subject: Re: [PATCH net v4] xen-netback: fix fragment detection in checksum
> setup
> 
> On Tue, Dec 03, 2013 at 02:05:17PM +0000, Paul Durrant wrote:
> [...]
> > > >
> > > > -	header_size = skb->network_header + off + MAX_IPOPTLEN;
> > > > -	maybe_pull_tail(skb, header_size);
> > > > +	if (!maybe_pull_tail(skb, sizeof(struct iphdr), MAX_IP_HDR_LEN))
> > > > +		goto out;
> > > > +
> > >
> > > I think you need to correctly update err to reflect this failure.
> > > Using -EPROTO will wrongly blame frontend while it is backend that's
> > > failing to process the packet.
> > >
> >
> > But a failure should only occur if the packet is malformed, so that would be
> a frontend error wouldn't it?
> >
> 
> __pskb_pull_tail may fail due to malloc failure.
> 
> However the return value of __pskb_pull_tail cannot reflect the wether
> the failure is due to malformed packet or OOM. Not sure what's the best
> solution here. What's the malformed packet you were talking about?
> 

For example, the pull would fail if the packet had an either_type of IP but didn't contain an IP header, or perhaps an IPv6 packet that had an incomplete option header sequence. I would have thought such a packet was a more likely cause of failure than OOM, so -EPROTO seems a reasonable best guess.

  Paul
