From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netback:	fix
 xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 11:53:05 +0100
Message-ID: <20131007105305.GB28411@zion.uk.xensource.com>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
 <525283D4.7010504@citrix.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0129E7A@AMSPEX01CL01.citrite.net>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0129EE1@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Annie Li <annie.li@oracle.com>, Matt Wilson <msw@amazon.com>,
	Xi Xiong <xixiong@amazon.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30448 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab3JGKxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 06:53:30 -0400
Content-Disposition: inline
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD0129EE1@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 11:37:31AM +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: xen-devel-bounces@lists.xen.org [mailto:xen-devel-
> > bounces@lists.xen.org] On Behalf Of Paul Durrant
> > Sent: 07 October 2013 11:24
> > To: David Vrabel
> > Cc: Wei Liu; Ian Campbell; netdev@vger.kernel.org; xen-devel@lists.xen.org;
> > Annie Li; Matt Wilson; Xi Xiong
> > Subject: Re: [Xen-devel] [PATCH net-next] xen-netback: fix
> > xenvif_count_skb_slots()
> > 
> > > -----Original Message-----
> > > From: David Vrabel
> > > Sent: 07 October 2013 10:50
> > > To: Paul Durrant
> > > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; Ian
> > Campbell;
> > > Annie Li; Matt Wilson; Xi Xiong
> > > Subject: Re: [Xen-devel] [PATCH net-next] xen-netback: fix
> > > xenvif_count_skb_slots()
> > >
> > > On 04/10/13 17:26, Paul Durrant wrote:
> > > > Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an
> > error
> > > into
> > > > xenvif_count_skb_slots() for skbs with a linear area spanning a page
> > > > boundary. The alignment of skb->data needs to be taken into account,
> > not
> > > > just the head length. This patch fixes the issue by dry-running the code
> > > > from xenvif_gop_skb() (and adjusting the comment above the function
> > to
> > > note
> > > > that).
> > >
> > > If 4f0581d2582 is causing the skb->data to be fully packed into a
> > > minimal number of slots then the simple
> > > DIV_ROUND_UP(skb_headlen(skb))
> > > is correct.
> > >
> > > I think this change will miscount in the number of slots,
> > > over-estimating the count which I think will eventually cause netback to
> > > think the ring has no space when it has some.
> > >
> > > Is the problem here not the miscounting of slots but running out of
> > > space in the grant table op array because we know use more copy ops?
> > >
> > 
> > Essentially yes. Netback is built on the assumption of no more than two grant
> > copies per ring slot.
> > 
> 
> To be clear; I believe that, with the packing change, a third grant copy may be used for the initial slot and that is why we blow the array.
> 

OK, thanks for the explanation. I'm fine with reverting the problematic
changeset as that part of code is quite fragile now. Looking at the git
history we've tripped over this many times, sigh.

Wei.
