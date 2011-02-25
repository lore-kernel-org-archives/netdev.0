From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] Re: [PATCH v2] xen network backend driver
Date: Fri, 25 Feb 2011 15:35:53 +0000
Message-ID: <1298648153.5034.549.camel@zakaz.uk.xensource.com>
References: <1297160635.9149.21.camel@zakaz.uk.xensource.com>
	 <20110215213512.GA5587@dumpdata.com>
	 <1298553792.5034.391.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10919 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484Ab1BYPgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 10:36:00 -0500
In-Reply-To: <1298553792.5034.391.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-24 at 13:23 +0000, Ian Campbell wrote:
> 
> > > +
> > > +     if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op,
> 1))
> > > +             BUG();
> > 
> > How about something less severe? Say return the error code?
> 
> Yes, I folded this into the following check of op.status. 

I revisited this and HYPERVISOR_grant_table_op has multicall like
semantics and a failure of the hypercall itself is a serious bug in the
calling kernel, akin to a page fault on kernel memory or similar so I
think a BUG() is the appropriate response.

Failures of the type which a guest may cause are the GNTST_* error codes
found in the op.status field an are handled appropriately gracefully.

Ian.

