From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Thu, 2 Dec 2010 12:33:01 +0800
Message-ID: <20101202042820.M98672@cooldavid.org>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr> <20101201.200935.71110482.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48560 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756804Ab0LBEdL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Dec 2010 23:33:11 -0500
In-Reply-To: <20101201.200935.71110482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Dec 2010 20:09:35 -0800 (PST), David Miller wrote
> From: Jan Engelhardt <jengelh@medozas.de>
> Date: Thu, 2 Dec 2010 04:39:34 +0100 (CET)
> 
> > Why does the JME driver care so much about this that it needs to print 
> > this for every packet? It does not look like it has any offloading 
> > features.
> 
> Well I'm glad it let us know about the bad checksum which would otherwise
> have been unnoticed.
> 
> Please try to pinpoint why the checksum is bad, because it seems that
> tcpdump agrees with the driver.  Perhaps it's some side effect of how
> vpnc uses TUN/TAP, or something like that.
> 
> Seeing the bad checksum even in tcpdump, and then seeing proper replies
> going back, that is very suspicious and should be looked into.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Indeed... It is suspicious to reply proper response against the packet
with bad checksum.

Jan: Would you try to turn off the rx-checksum offloading with ethtool
and see how it goes?

I suspect that there might be some the HW-Checksum behavior error.
ex: Replaced the UDP checksum field while it's all zero(no need to checksum)

Guo-Fu Tseng

