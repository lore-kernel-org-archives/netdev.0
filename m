From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net V2] xen-netback: don't move event pointer in TX
 credit timeout callback
Date: Thu, 15 May 2014 14:33:23 +0100
Message-ID: <20140515133323.GF1117@zion.uk.xensource.com>
References: <1400155158-13527-1-git-send-email-wei.liu2@citrix.com>
 <5374BB64.1080407@jajcus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, Paul Durrant <paul.durrant@citrix.com>
To: Jacek Konieczny <jajcus@jajcus.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29322 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750916AbaEONhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 09:37:07 -0400
Content-Disposition: inline
In-Reply-To: <5374BB64.1080407@jajcus.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 03:04:36PM +0200, Jacek Konieczny wrote:
> On 05/15/14 13:59, Wei Liu wrote:
> > ... otherwise the frontend will try to send TX event all the time, even
> > if no progress can be made. The pointer should only be advanced by the
> > routine that actually processes the ring (that is, xenvif_poll).
> > 
> > Reported-by: Jacek Konieczny <jajcus@jajcus.net>
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > Acked-by: Ian Campbell <ian.campbell@citrix.com>
> > Cc: Paul Durrant <paul.durrant@citrix.com>
> > ---
> >  drivers/net/xen-netback/netback.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index 7666540..8e2cbeb 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -658,7 +658,7 @@ void xenvif_check_rx_xenvif(struct xenvif *vif)
> >  {
> >  	int more_to_do;
> >  
> > -	RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, more_to_do);
> > +	more_to_do = RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
> > 
> 
> Unfortunately, this seems not enough to fix the problem I have reported
> here:
> http://lists.xenproject.org/archives/html/xen-devel/2014-05/msg01183.html
> 
> The dom0 network still stalls when using rate limiting on a VIF
> interface after applying this patch to my 3.14.3 kernel (100% CPU#1
> usage in the 'soft interrupts').
> 

Hmm... I will look into it further.

Wei.

> Greets,
> 	Jacek
