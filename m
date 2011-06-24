From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [PATCH] sctp: Reducing rwnd by sizeof(struct sk_buff) for each
 CHUNK is too aggressive
Date: Fri, 24 Jun 2011 11:53:16 -0400
Message-ID: <20110624155316.GD9222@canuck.infradead.org>
References: <20110624101535.GB9222@canuck.infradead.org>
 <4E0495C3.30102@hp.com>
 <20110624144251.GC9222@canuck.infradead.org>
 <4E04AB67.1040407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:59962 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358Ab1FXPxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 11:53:19 -0400
Content-Disposition: inline
In-Reply-To: <4E04AB67.1040407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2011 at 11:21:11AM -0400, Vladislav Yasevich wrote:
> First, let me state that I mis-understood what the patch is attempting to do.
> Looking again, I understand this a little better, but still have reservations.

This explains a lot :)

> If we treat the window as strictly available data, then we may end up sending a lot more traffic
> then the window can take thus causing us to enter 0 window probe and potential retransmission
> issues that will trigger congestion control.  
> We'd like to avoid that so we put some overhead into our computations.  It may not be ideal
> since we do this on a per-chunk basis.  It could probably be done on per-packet basis instead.
> This way, we'll essentially over-estimate but under-subscribe our current view of the peers
> window.  So in one shot, we are not going to over-fill it and will get an updated view next
> time the SACK arrives.

I will update my patch to include a per packet overhead and also fix the retransmission
rwnd reopening to do the same.
