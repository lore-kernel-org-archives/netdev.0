From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tun: allow setting ethernet addresss while running
Date: Wed, 12 Dec 2012 08:38:54 -0800
Message-ID: <20121212083854.2f98f186@nehalam.linuxnetplumber.net>
References: <1355188560-8388-1-git-send-email-shemminger@vyatta.com>
	<alpine.LNX.2.01.1212120427370.16297@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jasowang@redhat.com
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40123 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753578Ab2LLQkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 11:40:15 -0500
In-Reply-To: <alpine.LNX.2.01.1212120427370.16297@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 04:27:54 +0100 (CET)
Jan Engelhardt <jengelh@inai.de> wrote:

> On Tuesday 2012-12-11 02:16, Stephen Hemminger wrote:
> 
> >This is a pure software device, and ok with live address change.
> >--- a/drivers/net/tun.c
> >+++ b/drivers/net/tun.c
> >@@ -849,6 +849,7 @@ static void tun_net_init(struct net_device *dev)
> > 		/* Ethernet TAP Device */
> > 		ether_setup(dev);
> > 		dev->priv_flags &= ~IFF_TX_SKB_SHARING;
> >+		dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
> > 
> > 		eth_hw_addr_random(dev);
> 
> Would this possibly apply to L2TP devices as well?

L2TP does not allow changing mac address at all right now.
Only drivers that use eth_mac_addr, can take advantage of the flag.


Looking around here are the other places that could use it.
 vxlan, xen-netfront?, gre, gre6, virtio_net?, hyperv?

Also the following look buggy.
  c2 allows changing mac address but never tells hardware?
  isdn/hysdn_net.c allows setting mac address but then resets it
      card value in net_open
  xpnet allows setting address but it looks like it fixed by hardware
  ipddp allows ethernet address but protocol is not ethernet
