From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.19+: (and quite probably earlier) VIA Rhine hanging under high
 network load, yet again: redux
Date: Mon, 6 Apr 2015 01:15:10 +0200
Message-ID: <20150405231510.GA15719@electric-eye.fr.zoreil.com>
References: <874mov7otu.fsf@spindle.srvr.nix>
 <20150404210518.GA7698@electric-eye.fr.zoreil.com>
 <877ftqxpea.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux-Netdev <netdev@vger.kernel.org>
To: Nix <nix@esperi.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49117 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbbDEXPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2015 19:15:24 -0400
Content-Disposition: inline
In-Reply-To: <877ftqxpea.fsf@spindle.srvr.nix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nix <nix@esperi.org.uk> :
[...]
> Gross or not, it seems to work: I've loaded it enough to crash it half a
> dozen times, and not a crash. However, the rx_dropped stats on the link
> aren't going up, so maybe I've just been lucky.

Rx descriptors are now recycled as soon as they are processed whereas the
driver used to perform a complete processing batch before recycling any
descriptor. It could make a huge difference.

The pre-patch rx batch recycling did not include any barrier between
rp->rx_ring[entry].addr and rp->rx_ring[entry].rx_status updates to
enforce the ordering. The patch could help here as well.

You don't need to focus on rx_dropped: it's just a distraction :o)

Whatever the outcome I'll have to clean my mess though.

-- 
Ueimor
