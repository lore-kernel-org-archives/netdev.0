From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Tue, 04 May 2010 16:18:15 -0700 (PDT)
Message-ID: <20100504.161815.71114704.davem@davemloft.net>
References: <20100503.155820.158442623.davem@davemloft.net>
	<10955.1272927779@death.nxdomain.ibm.com>
	<17907.1272935182@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55557
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932066Ab0EDXSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 19:18:11 -0400
In-Reply-To: <17907.1272935182@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 03 May 2010 18:06:22 -0700

> 	Tested and it looks to work as advertised.  I see only one minor
> nit, there's a pr_debug that missed being renamed to the new function
> name; here's the whole patch with that fixed.

I don't think you need the ugly arp hook.

Instead, it's much cleaner to provide a way for packet type taps to
see the packet before bridge et al. decapsulation.  In fact this makes
a lot of sense, wanting to see the device as __netif_receive_skb() saw
it, with no changes whatsoever.

In fact ptype_all runs before bridging, ING, and MACVLAN decap the
thing, so we could have a 'ptype_base_predecap[]' that we run over
right after those.
