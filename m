From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3 2/9] xen-netback: Change TX path from grant
 copy to mapping
Date: Fri, 10 Jan 2014 13:16:25 +0000
Message-ID: <20140110131625.GJ29180@zion.uk.xensource.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
 <1389139818-24458-3-git-send-email-zoltan.kiss@citrix.com>
 <20140109153015.GF12164@zion.uk.xensource.com>
 <52CFDAEC.5080708@citrix.com>
 <20140110114534.GE29180@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140110114534.GE29180@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 10, 2014 at 11:45:34AM +0000, Wei Liu wrote:
> On Fri, Jan 10, 2014 at 11:35:08AM +0000, Zoltan Kiss wrote:
> [...]
> > 
> > >>@@ -920,6 +852,18 @@ static int xenvif_tx_check_gop(struct xenvif *vif,
> > >>  	err = gop->status;
> > >>  	if (unlikely(err))
> > >>  		xenvif_idx_release(vif, pending_idx, XEN_NETIF_RSP_ERROR);
> > >>+	else {
> > >>+		if (vif->grant_tx_handle[pending_idx] !=
> > >>+			NETBACK_INVALID_HANDLE) {
> > >>+			netdev_err(vif->dev,
> > >>+				"Stale mapped handle! pending_idx %x handle %x\n",
> > >>+				pending_idx, vif->grant_tx_handle[pending_idx]);
> > >>+			BUG();
> > >>+		}
> > >>+		set_phys_to_machine(idx_to_pfn(vif, pending_idx),
> > >>+			FOREIGN_FRAME(gop->dev_bus_addr >> PAGE_SHIFT));
> > >
> > >What happens when you don't have this?
> > Your frags will be filled with garbage. I don't understand exactly
> > what this function does, someone might want to enlighten us? I've
> > took it's usage from classic kernel.
> > Also, it might be worthwhile to check the return value and BUG if
> > it's false, but I don't know what exactly that return value means.
> > 
> 
> This is actually part of gnttab_map_refs. As you're using hypercall
> directly this becomes very fragile.
> 

To make it clear, set_phys_to_machine is done within m2p_add_override.

Wei.
