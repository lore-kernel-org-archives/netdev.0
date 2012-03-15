From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux-3.0.18+r8169+ipv4/tcp forwarding = tso/gso weirdness and performance degration
Date: Thu, 15 Mar 2012 20:11:18 +0100
Message-ID: <20120315191118.GA19809@electric-eye.fr.zoreil.com>
References: <20120314190156.622c8cd5@vostro> <1331745314.6022.27.camel@edumazet-glaptop> <20120314192945.65867e9f@vostro> <1331753354.2564.7.camel@bwh-desktop.uk.solarflarecom.com> <20120314215142.655ae607@vostro> <1331755965.6022.55.camel@edumazet-glaptop> <20120314223343.23dc9df3@vostro> <20120314205319.GA28394@electric-eye.fr.zoreil.com> <20120315080635.1f76512b@vostro> <20120315171148.0050714d@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53033 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932420Ab2COTM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 15:12:57 -0400
Content-Disposition: inline
In-Reply-To: <20120315171148.0050714d@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Teras <timo.teras@iki.fi> :
[...]
> The other broken box is connected to a HP ProCurve 4202vl-48G, and the
> switch is reporting drops due to FCS Rx errors.
[...]
> So I have two broken pieces of hardware, or there is a driver bug.

I'll take blame for any bug in the driver. However many ethernet controllers
are and the PCI 8169 is no exception.

> I'll try upgrading my kernel to 3.0.x series on the sender box and see
> if it's fixing anything. Suggestions for further testing would be
> appreciated.

Please check you are using nothing but SLAB.

If you have not done so, you may then disable Tx checksumming.

If it does not change anything, you may consider using the r8169 from
David Miller's -next branch (backported ? no, no, the real thing). If it
still does not change anything and you are interested in new experiences,
please confirm you are above 18 and we may use Ben Grear's bad rx packets
capture (available in -next) and the port mirroring feature of your switch
to see what the corrupted tx frames look like. Before that, I would
welcome a short description of the router boxes (lspci, proc, etc) and
overall traffic / irq.

-- 
Ueimor
