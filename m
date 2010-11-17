From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [RFC PATCH v1 1/2] net: implement mechanism for HW based QOS
Date: Wed, 17 Nov 2010 04:18:28 -0500
Message-ID: <20101117091828.GA14773@canuck.infradead.org>
References: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, davem@davemloft.net
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:51821 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934588Ab0KQJS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 04:18:29 -0500
Content-Disposition: inline
In-Reply-To: <20101117051544.19800.97654.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 09:15:45PM -0800, John Fastabend wrote:
> This patch provides a mechanism for lower layer devices to
> steer traffic using skb->priority to tx queues. This allows
> for hardware based QOS schemes to use the default qdisc without
> incurring the penalties related to global state and the qdisc
> lock. While reliably receiving skbs on the correct tx ring
> to avoid head of line blocking resulting from shuffling in
> the LLD. Finally, all the goodness from txq caching and xps/rps
> can still be leveraged.

Nice.

> If this approach seems reasonable I'll go ahead and finish
> this up. The priority to tc mapping should probably be exposed
> to userspace either through sysfs or rtnetlink. Any thoughts?

Please use netlink for this and add a new IFLA_ attribute. I
suggest you put nested attributes into it so you can extend it
later on and/or obsolete attributes:

[IFLA_TC] = {
  [IFLA_TC_MAX_TCS]
  [IFLA_TC_NUM_TCS]
  [IFLA_TC_TXQCOUNT]
  [IFLA_TC_TXQOFFSET]
  [IFLA_TC_MAP]
}

Or whatever is reasonable to export to userspace.
