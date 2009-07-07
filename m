From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Take GSO into account when capturing packets
Date: Mon, 06 Jul 2009 18:15:31 -0700 (PDT)
Message-ID: <20090706.181531.105788026.davem@davemloft.net>
References: <4A523CB0.8080005@polymtl.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tcpdump-workers@lists.tcpdump.org, wireshark-dev@wireshark.org
To: benjamin.poirier@polymtl.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752957AbZGGBPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:15:25 -0400
In-Reply-To: <4A523CB0.8080005@polymtl.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <benjamin.poirier@polymtl.ca>
Date: Mon, 06 Jul 2009 14:04:32 -0400

> move the point where the support routine for packet capture is called to
> better reflect what is transmitted on the wire when GSO is active.
> 
> At the moment, packet capture (a la tcpdump) on the transmission side happens
> before GSO takes place (if it does). Therefore, even if a packet gets
> segmented by GSO, the capture shows that one big packet was sent when in fact
> many small packets were sent on the wire. This behavior does not reflect the
> "reality" of what is transmitted and could lead to confusion, especially since
> a capture on the receiving side shows the segmented packets.
> 
> Signed-off-by: Benjamin Poirier <benjamin.poirier@polymtl.ca>

TSO does the same exact thing except that the networking card
chops up the packet before it hits the wire.

I really doubt there is anything seriously to gain by having
GSO behave one way and TSO another, and we should just keep
things as they are right now.

I'm not applying this, sorry.
