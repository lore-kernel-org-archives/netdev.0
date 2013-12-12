From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: allow local delivery when port is
 disabled
Date: Thu, 12 Dec 2013 15:05:23 -0800
Message-ID: <20131212150523.3c2abeca@nehalam.linuxnetplumber.net>
References: <20131212134159.5bc985a9@nehalam.linuxnetplumber.net>
	<20131212.172637.1846400994523481783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:32856 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584Ab3LLXF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:05:26 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so1373438pbc.10
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 15:05:26 -0800 (PST)
In-Reply-To: <20131212.172637.1846400994523481783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Dec 2013 17:26:37 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 12 Dec 2013 13:41:59 -0800
> 
> > When an Ethernet device is enslaved to a bridge, and the bridge STP
> > detects loss of carrier (or operational state down), then normally
> > packet reception is blocked.
> > 
> > This breaks control applications like WPA which maybe expecting to
> > receive packets to negotiate to bring link up. The bridge needs to
> > block forwarding packets from these disabled ports, but there is no
> > hard requirement to not allow local packet delivery.
> > 
> > In this special case, packets are not forwarded (local delivery only),
> > and only packet directed at the address of the Ethernet device are
> > accepted (no promiscuous or other ports in bridge).
> > 
> > The existing code already allowed link-local-address packets in
> > which is what STP uses to communicate with other bridges.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> 
> I think this change needs to be more careful about the setting of
> *pskb.  It should not be assigned if we return RX_HANDLER_CONSUMED.

It was already in the existing code path for link local.
