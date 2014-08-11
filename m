From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: move NAPI add/remove
 calls
Date: Mon, 11 Aug 2014 15:08:43 +0100
Message-ID: <20140811140843.GG3249@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-2-git-send-email-wei.liu2@citrix.com>
 <53E8B874.8070906@citrix.com>
 <53E8BBCB.50308@citrix.com>
 <53E8BE92.5070606@citrix.com>
 <53E8C1A8.4050302@citrix.com>
 <20140811134322.GE3249@zion.uk.xensource.com>
 <53E8CC58.10904@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16923 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904AbaHKOIy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 10:08:54 -0400
Content-Disposition: inline
In-Reply-To: <53E8CC58.10904@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2014 at 02:59:52PM +0100, David Vrabel wrote:
> On 11/08/14 14:43, Wei Liu wrote:
> > In short, there's no need to reorder disconnect logic and no need have a
> > dedicated loop for netif_napi_del.
> 
> Not for now.  But I would prefer it if it was re-ordered.  And similarly
> in xenvif_down(), irq_disable() should be before napi_disable().
> 

Something for another day then. In any case, even if napi_disable goes
before irq_disable, it's still safe if a tx interrupt takes place in
between. napi_schedule has no effect on a disabled instance.

Wei.

> David
