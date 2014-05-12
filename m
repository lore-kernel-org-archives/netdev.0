From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 20:54:17 +0200
Message-ID: <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>
References: <536F8C0F.4090206@davidnewall.com>,<5370CB47.4010400@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>, "fw@strlen.de" <fw@strlen.de>
To: David Newall <davidn@davidnewall.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s30.dub0.hotmail.com ([157.55.2.105]:8971 "EHLO
	dub0-omc4-s30.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755925AbaELSyT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 14:54:19 -0400
In-Reply-To: <5370CB47.4010400@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I've got a patch which fixes the faulty checksums, and now ping works
> with RR or TS set. I'm not quite sure, though, that it fixes the right
> thing. I wonder if the problem is less that the checksum becomes wrong,
> and more that the route and timestamps ought not to be changed by the
> bridge interface.

Looks like your testcase:
- works in 2.6.36 and older
- crashes starting with 2.6.37 (-rc1), likely due to Bandan's commit 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP stack) [1]
- crash fix is in 2.6.38.4, likely due to Eric's commit f8e9881c2aef1e9 (bridge: reset IPCB in br_parse_ip_options) [2]
- doesn't work post-crashfix



[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=462fb2af9788a82a534f8184abfde31574e1cfa0
[2] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f8e9881c2aef1e982e5abc25c046820cd0b7cf64
 		 	   		  