From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 08/14] netlink: implement memory mapped sendmsg()
Date: Thu, 18 Apr 2013 12:31:25 +0200
Message-ID: <20130418103125.GB25166@macbook.localnet>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
 <1366217229-22705-9-git-send-email-kaber@trash.net>
 <1366239463.2752.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35400 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966004Ab3DRKb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 06:31:28 -0400
Content-Disposition: inline
In-Reply-To: <1366239463.2752.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 11:57:43PM +0100, Ben Hutchings wrote:
> On Wed, 2013-04-17 at 18:47 +0200, Patrick McHardy wrote:
> > Add support for mmap'ed sendmsg() to netlink. Since the kernel validates
> > received messages before processing them, the code makes sure userspace
> > can't modify the message contents after invoking sendmsg(). To do that
> > only a single mapping of the TX ring is allowed to exist and the socket
> > must not be shared. If either of these two conditions does not hold, it
> > falls back to copying.
> [...]
> 
> Is this resistant against copy_to_process()?

I don't know, there's no copy_to_process() function is the tree I'm using.
