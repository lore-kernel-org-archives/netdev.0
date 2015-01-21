From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO path
Date: Wed, 21 Jan 2015 15:01:59 +0000
Message-ID: <20150121150159.GS26493@n2100.arm.linux.org.uk>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:43848 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973AbbAUPCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 10:02:14 -0500
Content-Disposition: inline
In-Reply-To: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 09:54:08AM -0300, Ezequiel Garcia wrote:
> These two commits are fixes to the issue reported by Russell King on
> mv643xx_eth. Namely, the introduction of a regression by commit 69ad0dd7af22
> which removed the support for highmem skb fragments. The guilty commit
> introduced the assumption of fragment's payload being located in lowmem pages.

I do wonder whether 69ad0dd7af22 is the real culpret, or whether there is
some other change in the netdev layer that we're missing.  That commit is
in 3.16, but from what I remember, 3.17 works fine, it's 3.18 which fails.

> A similar pattern can be found in the original mvneta driver (in fact, the
> regression was introduced by copy-pasting the mvneta code).
> 
> These fixes are for the non-TSO egress path in mvneta and mv643xx_eth drivers.
> The TSO path needs a more intrusive change, as the TSO API needs to be fixed
> (e.g. to make it work in skb fragments, instead of pointers to data).
> 
> Russell, as I'm still unable to reproduce this, do you think you can
> give it a spin over there?

Sure - I think the only one I can test is mv643xx_eth, I don't think I
have any device which supports mv_neta.

The test scenario is for a NFS mount (the Marvell device as the NFS
client) over IPv6.

Initial testing looks good, I'll let it run for a while with various
builds on the NFS share (which iirc was one of the triggering
workloads).

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
