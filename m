From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv2 0/8] vxlan: bug fixes
Date: Thu, 11 Oct 2012 07:59:03 -0700
Message-ID: <20121011075903.2c01ef41@nehalam.linuxnetplumber.net>
References: <20121010063545.453368147@vyatta.com>
	<20121010.224220.1261492043652933665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45563 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab2JKO7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 10:59:44 -0400
In-Reply-To: <20121010.224220.1261492043652933665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Oct 2012 22:42:20 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 09 Oct 2012 23:35:45 -0700
> 
> > Revision to earlier patch set for vxlan, includes a couple
> > more issues.
> 
> Applied, but that checksum issue is extremely unfortunate.
> 
> Why does postpull rcsum work for GRE but not VXLAN?

Not sure, plan to investigate getting rx checksum offload
working and possibly tx checksum (using checksum start).
Part of the problem with Tx checksum is too many drivers are
looking directly at skb_network_header() and skb_transport_header()
when they should be using skb_checksum_start().
