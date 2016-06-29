From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 0/7] net: ethernet: bgmac: Add platform device support
Date: Wed, 29 Jun 2016 11:52:26 -0700
Message-ID: <577418EA.5090306@gmail.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>, zajec5@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/28/2016 12:34 PM, Jon Mason wrote:
> I'm sending out this RFC to see if this is the direction the maintainers
> would like to go to add support for other, non-bcma iProc SoC's to the
> bgmac driver.  Specifically, we are interested in adding support for the
> NSP, Cygnus, and NS2 families (with more possible down the road).
> 
> To support non-bcma enabled SoCs, we need to add the standard device
> tree "platform device" support.  Unfortunately, this driver is very
> tighly coupled with the bcma bus and much unwinding is needed.  I tried
> to break this up into a number of patches to make it more obvious what
> was being done to add platform device support.  I was able to verify
> that the bcma code still works using a 53012K board (NS SoC), and that
> the platform code works using a 58625K board (NSP SoC).
> 
> It is worth noting that the phy logic present in the driver needs to be
> moved to drivers/phy.  However, I was not able to fully decouple that
> code from the bgmac driver.  I was able to move it into a separate C
> file, with only 2 function calls needed to create and destroy the mii
> bus.  Someone with more knowledge of this and HW to test it needs to do
> it properly.  This would natually dovetail into creating an interface
> which the NSP bgmac can use for the external MDIO Phy to properly
> connect (instead of using the fixed phy).

This looks very good to me, and I just tested this with a BCM58625 w/
b53-srab on top of that, and everything works nicely:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
