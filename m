From: David Woodhouse <dwmw2@infradead.org>
Subject: Routing over multiple interfaces
Date: Mon, 01 Nov 2010 17:12:02 -0400
Message-ID: <1288645922.5977.41.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:40158 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab0KAVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:12:05 -0400
Received: from [12.157.84.42] (helo=[10.216.5.171])
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PD1ff-0005pJ-GI
	for netdev@vger.kernel.org; Mon, 01 Nov 2010 21:12:05 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have two ADSL lines, and the ISP routes the same set of addresses over
both of them -- so I can saturate my incoming bandwidth over both lines
with a single TCP connection. This is not MLPPP; just two separate PPP
connections.

TCP can cope with a little bit of packet re-ordering, which obviously
happens when packets come over both lines.

Everything works really well for downstream traffic -- but not so well
for upstream, because Linux doesn't use the full available upstream
bandwidth. I have the default route set up thus:

default  src 90.155.92.214 
	nexthop dev ppp0 weight 1
	nexthop dev ppp1 weight 1

But when I do a large upload, I find that the kernel is only ever using
a *single* link at a time, rather than both. How can I make it use
*both* links? It's fine to confine each flow to a single link if it
doesn't saturate that link... but once the queue is full, it should
overflow onto the other device.

I worked around this earlier today by splitting the large file I needed
to upload into two parts, shifting one of them to a *different* machine,
connecting that to the VPN too and then uploading the two parts
separately. But that isn't really a viable option in the general case.

-- 
dwmw2

