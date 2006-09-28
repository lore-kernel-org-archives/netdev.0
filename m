From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 18:30:50 -0400
Message-ID: <451C4D1A.7010206@pobox.com>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>	<1159474625.3741.6.camel@rh4>	<Pine.LNX.4.64.0609281632200.28620@d.namei> <20060928.151649.71167157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, mchan@broadcom.com, shemminger@osdl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39821 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932527AbWI1Waz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 18:30:55 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060928.151649.71167157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Secondarily, looping over reading all of the registers of the chip
> might kill performance since the IO accesses compete with the
> normal packet sending/receiving operations.

This can be true of any ethtool sub-ioctl that beats the registers, if 
run in a tight loop.  PHYs are particularly nasty, because outside of 
hardware problems mentioned in the previous email, many phy read 
routines contain a metric ton of udelay() and mdelay()s.  Now, an 
unpriv'd user can cause the kernel to do tons of in-kernel busy-waits, 
in effect spinning the CPU at their mercy.

	Jeff


