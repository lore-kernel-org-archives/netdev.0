From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 12/16] netback: multi-page ring
 support
Date: Tue, 31 Jan 2012 11:09:05 +0000
Message-ID: <1328008145.5553.74.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
	 <4F26D4E5020000780006FF41@nat28.tlf.novell.com>
	 <1327943436.5553.39.camel@leeds.uk.xensource.com>
	 <4F27BC1002000078000700D3@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:57838 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398Ab2AaLJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 06:09:27 -0500
In-Reply-To: <4F27BC1002000078000700D3@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 09:01 +0000, Jan Beulich wrote:
> >>> On 30.01.12 at 18:10, Wei Liu <wei.liu2@citrix.com> wrote:
> > On Mon, 2012-01-30 at 16:35 +0000, Jan Beulich wrote:
> >> >>> On 30.01.12 at 15:45, Wei Liu <wei.liu2@citrix.com> wrote:
> >> > -int xenvif_map_frontend_rings(struct xenvif *vif,
> >> > -			      grant_ref_t tx_ring_ref,
> >> > -			      grant_ref_t rx_ring_ref)
> >> > +int xenvif_map_frontend_rings(struct xen_comms *comms,
> >> > +			      int domid,
> >> > +			      unsigned long ring_ref[],
> >> > +			      unsigned int  ring_ref_count)
> >> >  {
> >> > -	void *addr;
> >> > -	struct xen_netif_tx_sring *txs;
> >> > -	struct xen_netif_rx_sring *rxs;
> >> > -
> >> > -	int err = -ENOMEM;
> >> > +	struct gnttab_map_grant_ref op[NETBK_MAX_RING_PAGES];
> >> > +	unsigned int i;
> >> > +	int err = 0;
> >> >  
> >> > -	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
> >> > -				     tx_ring_ref, &addr);
> >> 
> >> Any reason why you don't just extend this function (in a prerequisite
> >> patch) rather than open coding a common utility function (twice) here,
> >> so that other backends (blkback!) can benefit later as well.
> >> 
> >> Jan
> >> 
> > 
> > I'm mainly focusing on netback stuffs, so the code is slightly coupled
> > with netback -- NETBK_MAX_RING_PAGES.
> > 
> > To extend xenbus_map_ring_valloc and make more generic, it requires
> > setting a global maximum page number limits on rings, I think it will
> > require further investigation and code refactor -- which I have no time
> > to attend to at the moment. :-/
> 
> Why? You can simply pass in the number of pages, there's no need
> for a global maximum.
> 

I mean the gnttab_map_gran_ref array, it is statically allocated at the
moment. Of course we can make it dynamically allocated, but why bother
taking the risk of allocation failure.


Wei.

> Jan
> 
