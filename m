From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next V7 3/4] xen-netback: coalesce slots
 in TX path and fix regressions
Date: Tue, 30 Apr 2013 16:44:53 +0100
Message-ID: <20130430154453.GA8728@zion.uk.xensource.com>
References: <1366633243-17775-1-git-send-email-wei.liu2@citrix.com>
 <1366633243-17775-4-git-send-email-wei.liu2@citrix.com>
 <517FDC6F02000078000D21B8@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34580 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759911Ab3D3Po7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 11:44:59 -0400
Content-Disposition: inline
In-Reply-To: <517FDC6F02000078000D21B8@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 01:59:59PM +0100, Jan Beulich wrote:
> >>> On 22.04.13 at 14:20, Wei Liu <wei.liu2@citrix.com> wrote:
> > @@ -898,47 +928,78 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
> >  
> >  static int netbk_count_requests(struct xenvif *vif,
> >  				struct xen_netif_tx_request *first,
> > +				RING_IDX first_idx,
> >  				struct xen_netif_tx_request *txp,
> >  				int work_to_do)
> >  {
> >  	RING_IDX cons = vif->tx.req_cons;
> 
> It looks bogus and confusing to me to pass first_idx into this
> function when this really is the same as cons.
> 

So the idea came from David Vrabel and went through two iterations.
Looking at the code he might be mimicking other error handling path up
in the caller, i.e. xen_netbk_tx_build_gops.

It's safe to remove first_idx I think. Just tested replacing first_idx
with cons, everything worked as before.


Wei.

> Jan
