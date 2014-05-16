From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 16 May 2014 14:11:45 +0100
Message-ID: <20140516131145.GK18551@zion.uk.xensource.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44859 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbaEPNLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:11:47 -0400
Content-Disposition: inline
In-Reply-To: <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 06:04:34AM -0700, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 12:08 +0100, Wei Liu wrote:
> > Some workload, such as Redis can generate SKBs which make use of
> > compound pages. Netfront doesn't quite like that because it doesn't want
> > to send packet that occupies exessive slots to the backend as backend
> > might deem it malicious. On the flip side these packets are actually
> > legit, the size check at the beginning of xennet_start_xmit ensures that
> > packet size is below 64K.
> > 
> > So we linearize SKB if it occupies too many slots. If the linearization
> > fails then the SKB is dropped.
> > 
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > Cc: David Vrabel <david.vrabel@citrix.com>
> > Cc: Konrad Wilk <konrad.wilk@oracle.com>
> > Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > Cc: Stefan Bader <stefan.bader@canonical.com>
> > Cc: Zoltan Kiss <zoltan.kiss@citrix.com>
> > ---
> >  drivers/net/xen-netfront.c |   17 ++++++++++++++---
> >  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> This is likely to fail on typical host.
> 

It's not that common to trigger this, I only saw a few reports. In fact
Stefan's report is the first one that comes with a method to reproduce
it.

I tested with redis-benchmark on a guest with 256MB RAM and only saw a
few "failed to linearize", never saw a single one with 1GB guest.

> What about adding a smart helper trying to aggregate consecutive
> smallest fragments into a single frag ?
> 

Ideally this is a better apporach, but I'm afraid I won't be able to
look into this until early / mid June.

Wei.

> This would be needed for bnx2x for example as well.
> 
