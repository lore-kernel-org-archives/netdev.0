From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 11:14:22 +0000
Message-ID: <20140115111422.GJ5698@zion.uk.xensource.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
 <20140115100743.GG5698@zion.uk.xensource.com>
 <52D66ADF.9070401@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, Annie Li <Annie.li@oracle.com>,
	<netdev@vger.kernel.org>, <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>
To: Andrew Bennieston <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22864 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbaAOLOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 06:14:24 -0500
Content-Disposition: inline
In-Reply-To: <52D66ADF.9070401@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 11:02:55AM +0000, Andrew Bennieston wrote:
> On 15/01/14 10:07, Wei Liu wrote:
> >On Fri, Jan 10, 2014 at 06:48:38AM +0800, Annie Li wrote:
> >>Current netfront only grants pages for grant copy, not for grant transfer, so
> >>remove corresponding transfer code and add receiving copy code in
> >>xennet_release_rx_bufs.
> >>
> >
> >This path seldom gets call -- not that many people unload xen-netfront
> >driver. If Annie has tested this patch and it works as expected I think
> >it's fine.
> >
> In XenServer we have seen a number of cases where unplugging and
> replugging VIFs results in leakage of grant references, eventually
> leading to a case where you cannot plug a VIF (after ~ 400 such
> cycles)...
> 

OK, this makes sense.

> It's worth pointing out, as far as this patch is concerned, that
> gnttab_end_foreign_access() can fail, which is not taken into
> account here.
> 

How? gnttab_end_foreign_access doesn't return any error. The gref which
cannot be freed right away will be added to a deferred list and handle
later.

Wei.
