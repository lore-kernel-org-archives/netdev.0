From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 5/5 2.6.21] L2TP: Add PPPoL2TP in-kernel documentation
Date: Tue, 1 May 2007 02:31:12 -0400
Message-ID: <20070501023112.9fa486de.billfink@mindspring.com>
References: <200704300952.l3U9q13w031857@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:43380 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030782AbXEAGbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 02:31:17 -0400
In-Reply-To: <200704300952.l3U9q13w031857@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 30 Apr 2007, James Chapman wrote:

> Signed-off-by: James Chapman <jchapman@katalix.com>
> 
> Index: linux-2.6.21/Documentation/networking/l2tp.txt
> ===================================================================
> --- /dev/null
> +++ linux-2.6.21/Documentation/networking/l2tp.txt
> @@ -0,0 +1,167 @@
> +This brief document describes how to use the kernel's PPPoL2TP driver
> +to provide L2TP functionality. L2TP is a protocol that tunnels one or
> +more PPP sessions over a UDP tunnel. It is commonly used for VPNs
> +(L2TP/IPSec) and by ISPs to tunnel subscriber PPP sessions over an IP
> +network infrastructure.
> +
> +Design
> +======
> +
> +The PPPoL2TP driver, drivers/net/pppol2tp.c, provides a mechanism by
> +which PPP frames carried through an L2TP session are passed through
> +the kernel's PPP subsystem. The standard PPP daemon, pppd, handles all
> +PPP interaction with the peer. PPP network interfaces are created for
> +each local PPP endpoint.

...

> +There are a number of requirements on the userspace L2TP daemon in
> +order to use the pppol2tp driver.
> +
> +1. Use a UDP socket per tunnel.
> +
> +2. Create a single PPPoL2TP socket per tunnel. This is used only for
> +   for communicating with the driver but must remain open while the

"for for" above.

> +   tunnel is active. The driver marks the tunnel socket as an L2TP UDP
> +   encapsulation socket, which hooks up the UDP receive path via
> +   usp_encap_rcv() in net/ipv4/udp.c. PPP data frames are never passed

Typo.  "usp_encap_rcv()" -> "udp_encap_rcv()".

> +   in this special PPPoX socket.
> +
> +3. Create a PPPoL2TP socket per L2TP session. This is typically done
> +   by starting pppd with the pppol2tp plugin and appropriate
> +   arguments. A PPPoL2TP tunnel management socket (Step 2) must be
> +   created before the first PPPoL2TP session socket is created.

						-Bill
