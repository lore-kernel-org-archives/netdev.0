From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/sunhme.c patch
Date: Mon, 29 Oct 2007 20:12:31 -0700 (PDT)
Message-ID: <20071029.201231.67559606.davem@davemloft.net>
References: <47268EB0.5030703@wonderland.us.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: toms@wonderland.us.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45959
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752205AbXJ3DMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 23:12:34 -0400
In-Reply-To: <47268EB0.5030703@wonderland.us.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Southerland <toms@wonderland.us.com>
Date: Mon, 29 Oct 2007 19:53:52 -0600

> This patch provides a unique mac address for all interfaces
> for the Sun QFE card (non-sparc).  It takes the base mac from
> the first interface and increments the mac address for the
> other interfaces.
> 
> It still preserves the 'macaddr' parameter so if desired, it
> can still be used.
> 
> Before patching:
> 
> eth0      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
> eth1      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
> eth2      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
> eth3      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
> 
> After patching:
> 
> eth0      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BB
> eth1      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BC
> eth2      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BD
> eth3      Link encap:Ethernet  HWaddr 00:03:BA:17:4C:BE

Unfortunately, although I understand what you're trying to do,
this change is not correct.

We obtain properly the local-mac-address property stored in
the PCI ROM of each interface, and if you look at the code
we look the MACs up by interface index.

So we are (or should be) obtaining the per-interface MAC
address programmed into the onboard firmware.

Perhaps in get_hme_mac_nonsparc(), is_quattro_p() is evaluating
false and therefore we mistakedly always use index 0?

Could you please check this?  That's probably what the problem
is.
