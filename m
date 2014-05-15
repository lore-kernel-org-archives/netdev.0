From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net V2] xen-netback: don't move event pointer in TX
 credit timeout callback
Date: Thu, 15 May 2014 19:16:38 +0100
Message-ID: <20140515181638.GG10525@zion.uk.xensource.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
 <5374BB64.1080407@jajcus.net>
 <20140515141322.GI1117@zion.uk.xensource.com>
 <5374D38A.2070709@citrix.com>
 <20140515153051.GJ1117@zion.uk.xensource.com>
 <5374EC81.1070808@citrix.com>
 <20140515165358.GA10525@zion.uk.xensource.com>
 <5374F352.9050302@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, Jacek Konieczny <jajcus@jajcus.net>,
	<xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Paul Durrant <paul.durrant@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:40131 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbaEOSQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:16:43 -0400
Content-Disposition: inline
In-Reply-To: <5374F352.9050302@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 06:03:14PM +0100, Zoltan Kiss wrote:
> On 15/05/14 17:53, Wei Liu wrote:
> >On Thu, May 15, 2014 at 05:34:09PM +0100, Zoltan Kiss wrote:
> >[...]
> >>>>>
> >>>>>  		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
> >>>>>-		if (!more_to_do)
> >>>>>+		if (!more_to_do || rate_limited)
> >>>>How about calling timer_pending(&vif->credit_timeout) instead?
> >>>
> >>>timer_pending(&vif->credit_timeout) covers only one of two senarios of
> >>>"credit exceeded", see tx_credit_exceeded.
> >>The other scenario is when the packet size exceeds the credit. There is no
> >>packet here actually, we just want to know if this vif ran out of credit and
> >>waiting for the timer to fire.
> >>
> >>>
> >
> >Which place are you referring to? There's packet in the ring, right? So
> >you're saying in xenvif_poll "more_to_do" is true and "timer_pending" is
> >also true when we come to xenvif_poll again?
> The goal of this patch to deschedule NAPI if the vif ran out of credit.
> Either you can carry that information from build_gops via a bool, or you can
> check whether the timer is pending. That's what tx_credit_exceeded does as
> well, and then it checks if the actual packet fits in. But in xenvif_poll
> you don't want to know whether an actual packet fits in, you only need the
> information whether tx_credit_exceeded started the timer or not.
> If it is, you can be sure there is no more credit. If not, you can keep the
> instance running.
> >

OK, you convinced me. I will try to rework this patch with your
approach.

Wei.
