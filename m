From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Tue, 20 May 2008 17:20:12 +0100
Message-ID: <20080520162011.GT28241@solarflare.com>
References: <4832E223.7020206@trash.net> <20080520144822.GR28241@solarflare.com> <4832E55E.2030009@trash.net> <4832F260.5000104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35552 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755451AbYETQU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 12:20:28 -0400
Content-Disposition: inline
In-Reply-To: <4832F260.5000104@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Patrick McHardy wrote:
> >Ben Hutchings wrote:
> >>Patrick McHardy wrote:
> >>>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >>>index b11e6e1..3be4559 100644
> >>>--- a/include/linux/netdevice.h
> >>>+++ b/include/linux/netdevice.h
> >>>@@ -514,10 +514,11 @@ struct net_device
> >>> #define NETIF_F_NETNS_LOCAL    8192    /* Does not change network 
> >>>namespaces */
> >>> #define NETIF_F_MULTI_QUEUE    16384    /* Has multiple TX/RX 
> >>>queues */
> >>> #define NETIF_F_LRO        32768    /* large receive offload */
> >>>+#define NETIF_F_VLAN_TSO    65536    /* Supports TSO for VLANs */
> >>>
> >>>     /* Segmentation offload features */
> >>>-#define NETIF_F_GSO_SHIFT    16
> >>>-#define NETIF_F_GSO_MASK    0xffff0000
> >>>+#define NETIF_F_GSO_SHIFT    20
> >>>+#define NETIF_F_GSO_MASK    0xfff00000
> >>
> >>I really don't think it's a good idea to move around existing flags.  
> >>How
> >>about stealing some of the unused high-order bits of NETIF_F_GSO_MASK
> >>instead?
> >
> >
> >Mhh it doesn't really belong there. Whats the problem with
> >moving these bits? They are only used internally (and use
> >up too much space anyway).
> I've been running with it shifted to 24 on 2.6.25 with no problems.   If 
> no one else objects, I'd prefer it shifted all the way
> to 24 to make room for more flags w/out additional changes in the 
> shiftage later...

I would certainly be happy to see NETIF_F_GSO_MASK narrowed.  It's just a
question of whether the low-order or high-order bits are removed.  My
instinct is not to change the existing assigned flags if it's not really
necessary.  They are exposed through /sys/class/net/ even if the flag
names aren't part of the user-land headers.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
