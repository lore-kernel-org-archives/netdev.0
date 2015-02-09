From: Jouni Malinen <jouni@codeaurora.org>
Subject: Re: [PATCH v2 1/3] bridge: Base the BR_PROXYARP decision on the
 target port flag
Date: Mon, 9 Feb 2015 21:54:01 +0200
Message-ID: <20150209195401.GA18065@jouni.qca.qualcomm.com>
References: <1423130063-18323-1-git-send-email-jouni@codeaurora.org>
 <20150207.215922.1914777712701024499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kyeyoonp@codeaurora.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53953 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759087AbbBIUDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 15:03:34 -0500
Content-Disposition: inline
In-Reply-To: <20150207.215922.1914777712701024499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 07, 2015 at 09:59:22PM -0800, David Miller wrote:
> From: Jouni Malinen <jouni@codeaurora.org>
> > When doing proxy ARP, instead of checking the bridge port flag for
> > BR_PROXYARP on the bridge port on which the frame was received, check
> > the bridge port flag of the bridge port to which the target device
> > belongs.
> 
> This is a semantic change, what if the administrator wanted the
> current behavior?
> 
> I'm not applying this.  If you want the new behavior, it will have
> to be at a minimum turned on via a sysctl that defaults to OFF.

Agreed, this does change the semantics of the commit 958501163ddd
("bridge: Add support for IEEE 802.11 Proxy ARP"). However, I see this
as a bug fix rather than new behavior. In other words, this set of three
patches came up from extended testing coverage and issues found during
implementation of automated protocol tests. Taken into account that this
BR_PROXYARP functionality was added recently and I'm not aware of a use
case that would use the current design, I was hoping to avoid the added
complexity of configuration parameters for something that I do not
expect to be needed.

This IEEE 802.11 Proxy ARP functionality is still work in progress in
the sense that the IPv6 patch has not yet been contributed (RFC version
would be ready, but I'm waiting for the IPv4 side to get fully
completed).


If a configuration parameter is required for this, what would the
preferred way of adding it in net/bridge? It looks like only
br_netfilter.c is currently using sysctl. Would netlink with another
BRPORT_ATTR_FLAG similarly to BR_PROXYARP be a suitable alternative?

-- 
Jouni Malinen                                            PGP id EFC895FA
