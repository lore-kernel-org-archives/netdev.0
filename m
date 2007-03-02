From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Fri, 2 Mar 2007 08:27:23 -0800
Message-ID: <20070302082723.7105b0c1@oldman>
References: <45E5570E.7050301@free.fr>
	<200703011230.50596.dada1@cosmosbay.com>
	<45E6F744.8070106@linux-foundation.org>
	<200703021538.41284.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	John find <linux.kernel@free.fr>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33854 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992583AbXCBQ2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:28:00 -0500
In-Reply-To: <200703021538.41284.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Mar 2007 15:38:41 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> We currently use a special structure (struct skb_timeval) and plain 'struct 
> timeval' to store packet timestamps in sk_buffs and struct sock.
> 
> This has some drawbacks :
> - Fixed resolution of micro second.
> - Waste of space on 64bit platforms where sizeof(struct timeval)=16
> 
> I suggest using ktime_t that is a nice abstraction of high resolution time 
> services, currently capable of nanosecond resolution.
> 
> As sizeof(ktime_t) is 8 bytes, using ktime_t in 'struct sock' permits a 8 byte 
> shrink of this structure on 64bit architectures. Some other structures also 
> benefit from this size reduction (struct ipq in ipv4/ip_fragment.c, struct 
> frag_queue in ipv6/reassembly.c, ...)

This is even better. Also comparing ktime_t's is easier if some code needs
to do that.
