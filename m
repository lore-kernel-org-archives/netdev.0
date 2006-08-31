From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH] Fix dm9000 release_resource
Date: Thu, 31 Aug 2006 10:39:40 +0100
Message-ID: <20060831093940.GA3623@home.fluff.org>
References: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-84-9-203-25.bulldogdsl.com ([84.9.203.25]:18178 "EHLO
	aeryn.fluff.org.uk") by vger.kernel.org with ESMTP id S1750699AbWHaJkA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 05:40:00 -0400
To: Dirk Opfer <Dirk@Opfer-Online.de>
Content-Disposition: inline
In-Reply-To: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 09:04:45AM +0200, Dirk Opfer wrote:
> dm9000_release_board calls release_resource with the platform resource
> instead of the requested resource:
> 
> db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> db->addr_req = request_mem_region(db->addr_res->start, i, pdev->name);
> 
> dm9000_release_board:
> 
>     if (db->addr_res != NULL) {
>         release_resource(db->addr_res);
>         kfree(db->addr_req);
> 
> With this behavior the kernel will crash on the second removal. The
> attached patch fix this problem.
> 
> 
> Signed-off-by: Dirk Opfer <Dirk@Opfer-Online.de>
Acked-by: Ben Dooks <ben-linux@fluff.org>
