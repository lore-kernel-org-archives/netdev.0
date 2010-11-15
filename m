From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Remaining problems in firewire-net
Date: Mon, 15 Nov 2010 09:01:03 +0100
Message-ID: <20101115090103.0df0b5ef@stein>
References: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
	<1289795401.11881.62.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:51409 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757692Ab0KOIBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 03:01:19 -0500
In-Reply-To: <1289795401.11881.62.camel@maxim-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 15 Maxim Levitsky wrote:
> That is because 1394 spec specifies that first of all the ISO channel
> must be allocated from the IRM node. The firewire stack currently just
> uses hardcoded numbers in two places the ISO is used 
> (firewire-net, and firedtv)
> However it has all functions implemented for this.

This is a bug (missing feature) in firedtv but not in firewire-net. The
broadcast channel is allocated and reallocated by the bus manager, not
by an IP-over-1394 user.  But you found that out already, below.

Channel allocation and DMA context allocation and control are unrelated
issues, on the other hand.  One is a higher-level cooperative protocol
for bus-wide resource management (in which the nodes' roles are defined
in various different ways by protocols such as AV/C's CMP or by IIDC).
The other is about hardware control locally in the OHCI bus bridge
hardware.

[...]
> In case of firewire-net, it is simpler, because it uses the broadcast
> channel, so it only has to find who is the IRM and read its
> BROADCAST_CHANNEL.
> 
> However, I think I need to write a function to query the IRM its
> broadcast channel, don't think it has one.

Overkill.  Just leave it as is:
  1.) We know which number the broadcast channel has.
  2.) We optimistically assume that a 1394a compliant IRM or bus
      manager exists and allocated that channel.

Why introduce entirely unnecessary fragility?

> Speaking of IRM discovery, the spec says it should be a node with
> contender bit and largest node id. However, the code in
> core-topology.c, build_tree seems to take the node that sent the
> selfID packet last.

This is because of a monotony rule of how self ID packets arrive during
self identification phase.
-- 
Stefan Richter
-=====-==-=- =-== -====
http://arcgraph.de/sr/
