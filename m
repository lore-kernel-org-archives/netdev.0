From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: 3x59x-fix-pci-resource-management.patch
Date: Fri, 7 Aug 2009 12:01:36 +0200
Message-ID: <20090807100136.GB12932@skl-net.de>
References: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from systemlinux.org ([83.151.29.59]:55755 "EHLO m18s25.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbZHGKCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 06:02:40 -0400
Content-Disposition: inline
In-Reply-To: <20090806154223.b9b9759e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2009 at 03:42:23PM -0700, Andrew Morton wrote:
>  	/* PCI-only startup logic */
>  	if (pdev) {
> -		/* EISA resources already marked, so only PCI needs to do this here */
> -		/* Ignore return value, because Cardbus drivers already allocate for us */
> -		if (request_region(dev->base_addr, vci->io_size, print_name) != NULL)
> -			vp->must_free_region = 1;
> -

I don't know what cardbus does, but __request_region() returns NULL on
memory allocation failure for struct resource too. So this did not work
in all cases anyway. If cardbus allocates for us, we should handle it in
some way, if not I'm fine with the patch as it is.
