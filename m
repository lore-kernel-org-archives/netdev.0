From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix oops in xfrm4_dst_destroy()
Date: Mon, 26 Feb 2007 12:10:49 -0800 (PST)
Message-ID: <20070226.121049.90121540.davem@davemloft.net>
References: <20070225204315.GB31715@strauss.suse.de>
	<45E228C5.3060108@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bwalle@suse.de, miika@iki.fi, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38076
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030640AbXBZUKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 15:10:50 -0500
In-Reply-To: <45E228C5.3060108@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 26 Feb 2007 01:24:37 +0100

> Bernhard Walle wrote:
> > With 2.6.21-rc1, I get an oops when running 'ifdown eth0' and an IPsec
> > connection is active. If I shut down the connection before running 'ifdown
> > eth0', then there's no problem.  The critical operation of this script is to
> > kill dhcpd.
> > 
> > The problem is probably caused by commit with git identifier
> > 4337226228e1cfc1d70ee975789c6bd070fb597c (Linus tree) "[IPSEC]: IPv4 over IPv6
> > IPsec tunnel".
> > 
> > This patch fixes that oops. I don't know the network code of the Linux kernel
> > in deep, so if that fix is wrong, please change it. But please fix the oops. :)
> 
> Looks good, when the xfrm_dst is freed in __xfrm4_bundle_create
> after a failed call to xfrm_dst_lookup the xfrm pointer is not
> set, and this is also expected by xfrm_dst_destroy.
> 
> Acked-by: Patrick McHardy <kaber@trash.net>

Patch applied, thanks everyone.
