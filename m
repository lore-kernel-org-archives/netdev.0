From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v3 2/2] xen-netback: Grant copy the header
 instead of map and memcpy
Date: Thu, 3 Apr 2014 10:11:14 +0100
Message-ID: <1396516274.4211.39.camel@kazak.uk.xensource.com>
References: <1396458298-30041-1-git-send-email-zoltan.kiss@citrix.com>
	 <1396458298-30041-2-git-send-email-zoltan.kiss@citrix.com>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD02BB0E1@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jonathan Davies" <Jonathan.Davies@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:6818 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbaDCJLR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2014 05:11:17 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD02BB0E1@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-03 at 09:07 +0100, Paul Durrant wrote:
> > -----Original Message-----
> > From: Zoltan Kiss
> > Sent: 02 April 2014 18:05
> > To: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org
> > Cc: Paul Durrant; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> > Jonathan Davies; Zoltan Kiss
> > Subject: [PATCH net-next v3 2/2] xen-netback: Grant copy the header
> > instead of map and memcpy
> > 
> > An old inefficiency of the TX path that we are grant mapping the first slot,
> > and then copy the header part to the linear area. Instead, doing a grant copy
> > for that header straight on is more reasonable. Especially because there are
> > ongoing efforts to make Xen avoiding TLB flush after unmap when the page
> > were
> > not touched in Dom0. In the original way the memcpy ruined that.
> > The key changes:
> > - the vif has a tx_copy_ops array again
> > - xenvif_tx_build_gops sets up the grant copy operations
> > - we don't have to figure out whether the header and first frag are on the
> > same
> >   grant mapped page or not
> > Note, we only grant copy PKT_PROT_LEN bytes from the first slot, the rest (if
> > any) will be on the first frag, which is grant mapped. If the first slot is
> > smaller than PKT_PROT_LEN, then we grant copy that, and later
> > __pskb_pull_tail
> > will pull more from the frags (if any)
> > 
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
> Looks good to me.
> 
> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

Me too:

Acked-by: Ian Campbell <ian.campbell@citrix.com>
