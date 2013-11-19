From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Tue, 19 Nov 2013 12:54:14 +0100
Message-ID: <20131119115414.GZ31491@secunet.com>
References: <20131112085714.GU31491@secunet.com>
 <20131114.022356.1095983243221745109.davem@davemloft.net>
 <20131118100843.GY31491@secunet.com>
 <20131118.162115.407611651189468804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47974 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096Ab3KSLyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 06:54:17 -0500
Content-Disposition: inline
In-Reply-To: <20131118.162115.407611651189468804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 04:21:15PM -0500, David Miller wrote:
> 
> I think the main issue is that after this patch, the problem is really
> still there.
> 
> Let's say some device holds onto the neigh for a long time, then during
> this time an administrative replacement will still get that -EEXIST
> failure.

Well, I think we had this problem even before we stopped to do
cyclic garbage collecting. This patch would just restore the
behaviour we had before this change.

> 
> My conclusion is that the management of the state is the problem.
> Specifically, if we invalidate an entry then we should remove it's
> visisbility.  This means the table should operate by unhashing the
> entry unconditionally during such operations.
> 
> If some stray references exist, that's fine, the entity holding the
> reference will perform the final neigh cleanup at release time.
> 
> Does this make sense to you?

Yes, makes sense :-)

I'm not sure how invasive this will be, so maybe we should do
one patch to restore the old behaviour (for net) and one on
top of this to improve the situation as you described
(for net-next).
