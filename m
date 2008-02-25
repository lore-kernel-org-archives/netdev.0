From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] ethtool netlink interface
Date: Mon, 25 Feb 2008 12:30:07 -0500
Message-ID: <47C2FB1F.5090009@garzik.org>
References: <20080225130456.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40284 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753516AbYBYRaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 12:30:10 -0500
In-Reply-To: <20080225130456.GD20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> Hello,
> 
> Before I continue to finish this work I'd like to get a few comments
> on my implementation attempt.
> 
> The following patch implements the ETHTOOL_SSET and ETHTOOL_GSET
> command via netlink. The individual commands are implemented as
> separate functions and hooked into a table holding a validate,
> set and fill function for each command. Additionaly an entry must
> be made in the attribute policy to validate attributes when received.
> 
> Each ethtool command bundle is stored as a nested attribute in
> the regular link netlink message, therefore, unlike the ioctl
> interface, multiple ethtool commands can be issued in the same
> message allowing for links to be fully configured with a single
> message.
> 
> There is one big disadvantage: Due to the nature of ioctl it is
> basically not possible to share any code between the ioctl and
> neltink implementation therefore it implies duplicating code
> unless we want to do the same hack as fib fronted by constructing
> netlink messages inside the kernel.

No objections, and it certainly makes sense that you would need a 
separate "thunking" layer to unwrap ethtool-nl msgs rather than handling 
an ioctl.

However, I would think it inconsistent to only do SSET/GSET.  If others 
are OK with this patch, are you open to implementing the full set of 
ethtool operations?

	Jeff



