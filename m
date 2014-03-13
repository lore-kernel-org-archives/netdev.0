From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v7 4/9] xen-netback: Introduce TX
 grant mapping
Date: Thu, 13 Mar 2014 11:13:22 +0000
Message-ID: <20140313111322.GB16807@zion.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
 <1394142511-14827-5-git-send-email-zoltan.kiss@citrix.com>
 <1394706812.25873.28.camel@kazak.uk.xensource.com>
 <53218EDA.8040904@citrix.com>
 <1394708555.25873.43.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>, <jonathan.davies@citrix.com>,
	<wei.liu2@citrix.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394708555.25873.43.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 11:02:35AM +0000, Ian Campbell wrote:
> On Thu, 2014-03-13 at 10:56 +0000, David Vrabel wrote:
> > On 13/03/14 10:33, Ian Campbell wrote:
> > > On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
> > >> @@ -135,13 +146,31 @@ struct xenvif {
> > >>  	pending_ring_idx_t pending_cons;
> > >>  	u16 pending_ring[MAX_PENDING_REQS];
> > >>  	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> > >> +	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
> > >>  
> > >>  	/* Coalescing tx requests before copying makes number of grant
> > >>  	 * copy ops greater or equal to number of slots required. In
> > >>  	 * worst case a tx request consumes 2 gnttab_copy.
> > >>  	 */
> > >>  	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
> > >> -
> > >> +	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
> > >> +	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
> > > 
> > > I wonder if we should break some of these arrays into separate
> > > allocations? Wasn't there a problem with sizeof(struct xenvif) at one
> > > point?
> > 
> > alloc_netdev() falls back to vmalloc() if the kmalloc failed so there's
> > no need to split these structures.
> 
> Is vmalloc space in abundant supply? For some reason I thought it was
> limited (maybe that's a 32-bit only limitation?)

32-bit has a limitation of 128MB by default. 64-bit has much larger
address space.

Wei.
