From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH RFC 0/6] copy aside frags with destructors (was [PATCH
 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
Date: Tue, 8 May 2012 11:54:11 +0100
Message-ID: <1336474451.14542.63.camel@zakaz.uk.xensource.com>
References: <cover.1336397823.git.mst@redhat.com>
	 <20120508094114.GA14694@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:53248 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab2EHKyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 06:54:13 -0400
In-Reply-To: <20120508094114.GA14694@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-08 at 10:41 +0100, Michael S. Tsirkin wrote:
> On Mon, May 07, 2012 at 04:53:46PM +0300, Michael S. Tsirkin wrote:
> > > > > But I fear we're about to toss Ian into yet another rabbit hole. :-)
> > > > > 
> > > > > Let's try to converge on something quickly as I think integration of
> > > > > his work has been delayed enough as-is.
> 
> ...
> 
> > Here's a first stub at a fix. Basically to be able to modify frags on
> > the fly we must make sure the skb isn't cloned, so the moment someone
> > clones the skb we need to trigger the frag copy logic.  And this is
> > exactly what happens with SKBTX_DEV_ZEROCOPY so it seems to make sense
> > to reuse that logic.
> > 
> > The below patchset replaces patch 7
> > ([PATCH 7/9] net: add skb_orphan_frags to copy aside frags with destructors)
> > in Ian's patchset and needs to be applied there.
> > 
> > 
> > Compiled only but I'd like to hear what people think all the same
> > because it does add a couple of branches on fast path.  On the other
> > hand this makes it generic so the same logic will be reusable for packet
> > sockets (which IIRC are currently buggy in the same way as sunrpc) and
> > for adding zero copy support to tun.
> > 
> > Please comment,
> > Thanks!
> 
> Ian, just to stress, need your ack that this does what you wanted.

Sure, yesterday was a public holiday and today looks likely to be crazy
busy. I'll try and have a look later in the week.

Ian.
