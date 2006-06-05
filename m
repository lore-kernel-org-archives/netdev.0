From: David Miller <davem@davemloft.net>
Subject: Re: [patch 06/17] neighbour.c, pneigh_get_next() skips published
 entry
Date: Mon, 05 Jun 2006 16:30:36 -0700 (PDT)
Message-ID: <20060605.163036.102574536.davem@davemloft.net>
References: <200606020328.k523S8hh028820@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jari.Takkala@Q9.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38274
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750821AbWFEXaf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:30:35 -0400
To: akpm@osdl.org
In-Reply-To: <200606020328.k523S8hh028820@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Thu, 01 Jun 2006 20:32:26 -0700

> From: "Jari Takkala" <Jari.Takkala@Q9.com>
> 
> Fix a problem where output from /proc/net/arp skips a record when the full
> output does not fit into the users read() buffer.
> 
> To reproduce: publish a large number of ARP entries (more than 10 required
> on my system).  Run 'dd if=/proc/net/arp of=arp-1024.out bs=1024'.  View
> the output, one entry will be missing.
> 
> Signed-off-by: Jari Takkala <jari.takkala@q9.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

This patch doesn't make any sense, I've been over it a few
times.

The seqfile layer should take care of that user buffering
issue transparently as long as we implement the interface
callbacks properly.

Even if something needs to be fixed in the pneigh dumper,
special casing *pos==1 doesn't look right.  Also, if pneigh
has this problem, how come the neigh seqfile iterators don't
have the same problem or do they?
