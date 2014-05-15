From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v3] xen-netback: Fix grant ref resolution in RX path
Date: Thu, 15 May 2014 09:29:16 +0100
Message-ID: <1400142556.30687.1.camel@kazak.uk.xensource.com>
References: <1400069316-14316-1-git-send-email-zoltan.kiss@citrix.com>
	 <1400085628.26934.16.camel@kazak.uk.xensource.com>
	 <5373BD20.8030800@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:31212 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaEOI3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 04:29:19 -0400
In-Reply-To: <5373BD20.8030800@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 19:59 +0100, Zoltan Kiss wrote:
> All the comments are acked and applied, expect this:
> 
> On 14/05/14 17:40, Ian Campbell wrote:
> > On Wed, 2014-05-14 at 13:08 +0100, Zoltan Kiss wrote:
> 
> >
> >> +		/* This variable also signals whether foreign_gref has a real
> >> +		 * value or not.
> >> +		 */
> >> +		struct xenvif *foreign_vif = NULL;
> >> +
> >> +		if ((skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) &&
> >> +			(ubuf->callback == &xenvif_zerocopy_callback)) {
> >> +			const struct ubuf_info *const startpoint = ubuf;
> >> +
> >> +			/* Ideally ubuf points to the chain element which
> >> +			 * belongs to this frag. Or if frags were removed from
> >> +			 * the beginning, then shortly before it.
> >> +			 */
> >> +			ubuf = xenvif_find_gref(skb, i, ubuf);
> >> +
> >> +			/* Try again from the beginning of the list, if we
> >> +			 * haven't tried from there. This only makes sense in
> >> +			 * the unlikely event of reordering the original frags.
> >> +			 * For injected local pages it's an unnecessary second
> >> +			 * run.
> >
> > A second run is unfortunate. Can we also pass startpoint to
> > xenvif_find_gref as an end value and have it only search that far?
> That would help, but it would just increase the complexity here, and I 
> think this is absolutely a non fast-path case. But the first search is, 
> passing a new parameter and doing another comparison can consume a few 
> cycles.
> We don't know about any scenarios where frag reordering or injection of 
> local frags can actually happen, this is just about closing out 
> theoretical possibilities. Let's optimize it when it actually needed!

OK.

Perhaps consider adding a stat to count the occurrences of this path?
(not necessarily right now)

Ian.
