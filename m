From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
Date: Mon, 7 Oct 2013 10:17:52 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0129E07@AMSPEX01CL01.citrite.net>
References: <1380903983-27429-1-git-send-email-paul.durrant@citrix.com>
 <20131007000652.GA5970@u109add4315675089e695.ant.amazon.com>
 <20131007000741.GB5970@u109add4315675089e695.ant.amazon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Xi Xiong <xixiong@amazon.com>, Matt Wilson <msw@amazon.com>,
	Annie Li <annie.li@oracle.com>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Simon Graham <simon.graham@citrix.com>
To: Matt Wilson <msw@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45071 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253Ab3JGKSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 06:18:25 -0400
In-Reply-To: <20131007000741.GB5970@u109add4315675089e695.ant.amazon.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Matt Wilson [mailto:mswilson@gmail.com] On Behalf Of Matt Wilson
> Sent: 07 October 2013 01:08
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Xi Xiong; Matt Wilson;
> Annie Li; Wei Liu; Ian Campbell; Simon Graham
> Subject: Re: [PATCH net-next] xen-netback: fix xenvif_count_skb_slots()
> 
> On Sun, Oct 06, 2013 at 05:06:52PM -0700, Matt Wilson wrote:
> > On Fri, Oct 04, 2013 at 05:26:23PM +0100, Paul Durrant wrote:
> > > Commit 4f0581d25827d5e864bcf07b05d73d0d12a20a5c introduced an
> error into
> > > xenvif_count_skb_slots() for skbs with a linear area spanning a page
> > > boundary. The alignment of skb->data needs to be taken into account,
> not
> > > just the head length. This patch fixes the issue by dry-running the code
> > > from xenvif_gop_skb() (and adjusting the comment above the function
> to note
> > > that).
> > >
> > > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > > Cc: Xi Xiong <xixiong@amazon.com>
> > > Cc: Matt Wilson <msw@amazon.com>
> > > Cc: Annie Li <annie.li@oracle.com>
> > > Cc: Wei Liu <wei.liu2@citrix.com>
> > > Cc: Ian Campbell <Ian.Campbell@citrix.com>
> >
> > Paul, can you reconcile this change with the one made by Simon in cs
> > 8f985b4f7a5394c8f8725a5109451a541ddb9eea?
> 
> Correction: e26b203ede31fffd52571a5ba607a26c79dc5c0d
> 

The comment is possibly correct with modified ring packing but the problem is that by reducing that count netback now tries to handle more skbs than it has grant copy slots for. Maybe it would be more appropriate to simply revert 4f0581d25827d5e864bcf07b05d73d0d12a20a5c. I see no problem before that patch was applied.

  Paul
