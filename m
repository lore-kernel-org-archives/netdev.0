From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V4 01/13] netback: page pool version 1
Date: Mon, 20 Feb 2012 16:26:03 +0000
Message-ID: <1329755163.2203.352.camel@leeds.uk.xensource.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-2-git-send-email-wei.liu2@citrix.com>
	 <1328203565.13262.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120217191902.GD20584@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:22717 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab2BTQ0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 11:26:52 -0500
In-Reply-To: <20120217191902.GD20584@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-17 at 19:19 +0000, Konrad Rzeszutek Wilk wrote:
> > 
> > Hmm, this kind of stuff should be discussed on lkml.
> > 
> > I doubt we want yet another memory allocator, with a global lock
> > (contended), and no NUMA properties.
> 
> That should be fixed. Are there any existing memory pools that could be used
> instead? I (And I think everybody) is all for using the existing APIs if  they
> can do the job. I was lookign a bit at the dmapool code, but that requires something
> we don't have  - the 'struct device'. We could manufacture a fake one, but that just
> stinks of hack.
> 

I've been thinking about this for a long time, so any recommendation is
welcomed.

It is not my intention to write yet another memory allocator. What I
need is a data structure to track pages owned by netback.

Let me state the requirements of this data structure:
     1. limits overall memory used by all vifs (this could also be met
        by the underlying allocator)
     2. provides function to tell whether a particular page is mapped
        from foreign domain -- is_in_pool() is a surrogate for that
     3. provides function to back-reference owner vif of the page

To achieve requirement 2, page pool manipulates page->mapping field. To
achieve requirement 3, page pool maintains idx <-> vif relationship
internally.

I think I can use mempool internally for page allocation. But I still
need a data structure to meet other requirements.

> It [pagepool] also should use the shrinker API I think.

This is doable, but let's make everybody happy with the page pool design
and implementation first.


Wei.
