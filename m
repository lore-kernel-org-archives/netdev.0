From: David Miller <davem@davemloft.net>
Subject: Re: jme: UDP checksum error, and lots of them
Date: Wed, 01 Dec 2010 21:59:16 -0800 (PST)
Message-ID: <20101201.215916.104055114.davem@davemloft.net>
References: <alpine.LNX.2.01.1012020430190.4157@obet.zrqbmnf.qr>
	<20101201.200935.71110482.davem@davemloft.net>
	<20101202042820.M98672@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43297
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753614Ab0LBF6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 00:58:49 -0500
In-Reply-To: <20101202042820.M98672@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Date: Thu, 2 Dec 2010 12:33:01 +0800

> I suspect that there might be some the HW-Checksum behavior error.
> ex: Replaced the UDP checksum field while it's all zero(no need to checksum)

I checked the VPNC code and it receives UDP encapsulated traffic using
a normal UDP socket.  So any bad checksums should show up in the
statistics and in fact the packets should be dropped by the IPv4
stack before making it to the vpnc application.

Something isn't right here.  The only thing that makes sense is if
the tcpdump checksum validation is wrong for some reason.  Because
only then could we give a reason for the UDP frames to not be
dropped before vpnc can see them.

