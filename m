From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 10:12:15 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0128DD0@AMSPEX01CL01.citrite.net>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
 <20131007100132.GA28411@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:43467 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691Ab3JGKMT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 06:12:19 -0400
In-Reply-To: <20131007100132.GA28411@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 07 October 2013 11:02
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Xi Xiong; Matt Wilson;
> Annie Li; Wei Liu; Ian Campbell
> Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
> 
> On Fri, Oct 04, 2013 at 05:26:23PM +0100, Paul Durrant wrote:
> > Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an error
> into
> > xenvif_count_skb_slots() for skbs with a linear area spanning a page
> > boundary. The alignment of skb->data needs to be taken into account, not
> > just the head length. This patch fixes the issue by dry-running the code
> > from xenvif_gop_skb() (and adjusting the comment above the function to
> note
> > that).
> >
> 
> If I'm not mistaken the change in commit 4f0581d2 is correct because we
> changed the way that the ring is packed. Now you seem to fall back to
> the original scheme (or something in between without reverting later
> other changes in that commit).
> 

It's not possible to use a single grant copy to copy to even a 2-byte linear area that spans a page boundary so you have to take into account the alignment of skb->data. How the ring is packed is not relevant.

> Do you have instruction to reproduce the bug? Can you paste some
> detailed oops message?
> 

I don't have the message to hand, but it's this BUG_ON that I hit:

	BUG_ON(npo.copy_prod > ARRAY_SIZE(vif->grant_copy_op));

I.e. we blow the grant copy op array.

  Paul
