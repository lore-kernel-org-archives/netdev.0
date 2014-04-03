From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Thu, 3 Apr 2014 16:50:37 +0100
Message-ID: <20140403155037.GR7528@n2100.arm.linux.org.uk>
References: <1396358832-15828-1-git-send-email-zhangfei.gao@linaro.org> <1396358832-15828-4-git-send-email-zhangfei.gao@linaro.org> <9532591.5yuCbpL4pV@wuerfel> <20140403152746.GQ7528@n2100.arm.linux.org.uk> <063D6719AE5E284EB5DD2968C1650D6D0F6EF663@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:49656 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752425AbaDCPvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 11:51:07 -0400
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6EF663@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 03:42:00PM +0000, David Laight wrote:
> From: Russell King - ARM Linux
> > DMA coherent memory is write combining, so multiple writes will be
> > coalesced.  This also means that barriers may be required to ensure the
> > descriptors are pushed out in a timely manner if something like writel()
> > is not used in the transmit-triggering path.
> 
> You also have to ensure that the write that changes the 'owner'
> bit is the one that happens last.
> 
> If (for example) a descriptor has two words, one containing the
> buffer address and the other containing the length and flags,
> then you have to absolutely ensure that the hardware will not
> read the new 'flags' with the old 'buffer address'.
> Any write to tell the hardware to look at the tx ring won't
> help you - the hardware might be reading the descriptor anyway.
> 
> Even if the accesses are uncached, you need the appropriate
> barrier (or volatiles) to stop gcc reordering the writes.
> (I think accesses to volatiles can't be reordered - check.)

Exactly... I wish Freescale were as thoughtful as you are on this point. :)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
