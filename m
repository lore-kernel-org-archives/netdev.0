From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATH] dev: reusing unregistered ifindex values in net_device
Date: Thu, 18 Nov 2010 08:14:52 -0800
Message-ID: <20101118081452.7a38deb7@nehalam>
References: <AANLkTinx6Ww4ZwRUTyYD_STPSRsSFck8O=W5yeJSbBs_@mail.gmail.com>
	<1290094628.2781.195.camel@edumazet-laptop>
	<20101118.080139.193717791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, voravit@kth.se, robert@herjulf.net
To: daniel.turull@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47298 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932153Ab0KRQOz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 11:14:55 -0500
In-Reply-To: <20101118.080139.193717791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Nov 2010 08:01:39 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 18 Nov 2010 16:37:08 +0100
> 
> > Two bugs 
> > 
> > 1) ifindex is not initialized : you'll be suprised of random values
> > 
> > 2) ifindex should not be reused. You'll be surprised so applications can
> > break. SNMP comes to mind.
> 
> Right, the current algorithm is intentionally trying to avoid new
> devices from using indexes that were used by another device in the
> past.

Also think of the case of adding 10,000 VLAN's. If the search started from
beginning on each insertion dev_new_index would go from O(N) to O(N^2) which
really hurts.
