From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipx: header length validation needed
Date: Mon, 07 Aug 2006 16:24:33 -0700 (PDT)
Message-ID: <20060807.162433.26101101.davem@davemloft.net>
References: <20060807134636.30f8b779@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:55783
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751201AbWHGXYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 19:24:33 -0400
To: shemminger@osdl.org
In-Reply-To: <20060807134636.30f8b779@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 7 Aug 2006 13:46:36 -0700

> IPX is not checking for non-linear (and short packets) in it's
> receive routine.  This is serious because it may mean it ends up
> reading past end of skb.

This takes care of ipx_rcv() but the rest of the IPX protocol
handling still has the problem, so you'll need to meticuliously
follow the whole receive path and fix up all the spots that
parse subsequent parts of the IPX packet to fix this properly.

For example, take a look at ipxitf_pprop().
