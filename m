From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [regression] [analyzed] fragmentation broken for tunnel devices
Date: Wed, 1 May 2013 09:46:45 +0300
Message-ID: <20130501094645.715bb462@vostro>
References: <20130315133820.006a42f6@vostro>
	<20130315150321.621d705e@vostro>
	<20130320101318.4196d93a@vostro>
	<20130320.134640.1857052324535652751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f66.google.com ([74.125.83.66]:62559 "EHLO
	mail-ee0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206Ab3EAGpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 02:45:34 -0400
Received: by mail-ee0-f66.google.com with SMTP id l10so388315eei.5
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 23:45:33 -0700 (PDT)
In-Reply-To: <20130320.134640.1857052324535652751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Mar 2013 13:46:40 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Timo Teras <timo.teras@iki.fi>
> Date: Wed, 20 Mar 2013 10:13:18 +0200
> 
> Thanks for investigating this issue.
> 
> > 3) Reimplement fragmentation in tunnel devices. This means some
> > duplication of code. But now that there's GRO support in tunnels,
> > this would seem the most performant option.
> 
> I think this is the best option, especially in the long term.

I've been thinking more. It seems there's going to be tricky cases with
this approach too. Looks like ICMP and other non-TCP/UDP packets are
not really sent as GSO/GRO packets. So for those we end up fragmenting
multiple times and end up sending double the amount of packets than
needed.

This would also mean that if we are ever to support new protocols, e.g.
MPLS, we'd get a whole new can of forms when needing fragmentation.

I'm wondering now if it'd be easier to just do the additional
nexthop consultation for forward routes where destination is a tunnel
device.

- Timo
