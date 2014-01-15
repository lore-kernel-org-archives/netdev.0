From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 14:32:53 +0000
Message-ID: <20140115143253.GN5698@zion.uk.xensource.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
 <52D66F11.204@citrix.com>
 <20140115114208.GK5698@zion.uk.xensource.com>
 <52D67677.4050407@citrix.com>
 <52D69864.9030207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30991 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaAOOcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:32:55 -0500
Content-Disposition: inline
In-Reply-To: <52D69864.9030207@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 10:17:08PM +0800, annie li wrote:
[...]
> >Having gnttab_end_foreign_access() do a free just looks odd to me, the
> >free isn't paired with any alloc in the grant table code.
> >
> >It seems more logical to me that granting access takes an additional
> >page ref, and then ending access releases that ref.
> 
> I am thinking of two ways, and they can be implemented in new patches.
> 1. If gnttab_end_foreign_access_ref succeeds, then kfree_skb is
> called to free skb. Otherwise, using gnttab_end_foreign_access to
> release ref and pages.

This is probably not a very good idea as skb_free does a lot more things
than simply freeing pages. You're still leaking something (skb: state,
head etc.) with this approach.

> 2. Add a similar deferred way of gnttab_end_foreign_access in
> gnttab_end_foreign_access_ref.
> 
> Thanks
> Annie
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
