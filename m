From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH RFC] r8169: straighten out overlength frame detection (v3)
Date: Mon, 11 Jan 2010 00:50:17 +0100
Message-ID: <20100110235017.GA8959@electric-eye.fr.zoreil.com>
References: <20100107010122.GA5872@electric-eye.fr.zoreil.com>
 <20100106.171514.104051841.davem@davemloft.net>
 <20100108234800.GA2908@electric-eye.fr.zoreil.com>
 <20100108.160252.189352309.davem@davemloft.net>
 <1263088638.2480.210.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 49.119.116-78.rev.gaoland.net ([78.116.119.49]:36695 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751009Ab0AJXxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 18:53:42 -0500
Content-Disposition: inline
In-Reply-To: <1263088638.2480.210.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 01:57:18AM +0000, Ben Hutchings wrote:
> On Fri, 2010-01-08 at 16:02 -0800, David Miller wrote:
> [...]
> > Whilst the above will end up gobbling up to (16K - BIG_PACKET_SZ)
> > worth of innocent frames, the DMA engine seems to keep things at least
> > self-consistent.
> > 
> > The only bug seems to be the omission of the LastFrag trigger at the
> > proper place.
> 
> No, the attacker controls the completion status by writing it in
> previous valid frames.  Please read the slides
> (<http://events.ccc.de/congress/2009/Fahrplan/attachments/1483_26c3_ipv4_fuckups.pdf> pages 80-87).

Yes.

The paper suggests that it should be possible to control opts1
either completely or enough to break things badly.

The first packet does not hurt too much. Things look different in
the descriptor of the subsequent packets. I am more or less able
to control bits 8-23 from 0-31 in opts1, enough to be unpleasant.

Iff the FirstFrag and LastFrag bits can not be set on these packets,
it should be enough to (1) do the fragmented_frame test sooner and
return the descriptor to the chipset. Otherwise we can (2) take a
complete reset on the first suspect packet (whose pattern is more
specific) to stop the challenger here.

FWIW, a netratelimited printk of the source mac address may help too.

I am biased in favor of (2) as:
- it will not inhibit multi-desc packets
- the challenger is supposed to be in the LAN and can already hurt
  quite a lot anyway

Comments ?

-- 
Ueimor
