From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: phy power problems on 88e805X chips
Date: Thu, 10 Aug 2006 08:32:43 -0400
Message-ID: <44DB276B.9010505@pobox.com>
References: <20060809141450.2e104dfe@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45534 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161225AbWHJMcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 08:32:45 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060809141450.2e104dfe@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On the 88E805X chipsets (used in laptops), the PHY was not getting powered
> out of shutdown properly. The variable reg1 was getting reused incorrectly.
> This is probably the cause of the bug.
> 	http://bugzilla.kernel.org/show_bug.cgi?id=6471
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- netdev-2.6.orig/drivers/net/sky2.c	2006-08-09 14:13:36.000000000 -0700
> +++ netdev-2.6/drivers/net/sky2.c	2006-08-09 14:14:07.000000000 -0700
> @@ -233,6 +233,8 @@
>  			if (hw->ports > 1)
>  				reg1 |= PCI_Y2_PHY2_COMA;
>  		}
> +		sky2_pci_write32(hw, PCI_DEV_REG1, reg1);
> +		udelay(100);
>  
>  		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {

applied to #upstream-fixes, though I note that the obvious PCI posting 
bug remains.

You cannot be assured that the udelay(100) is truly effective without a 
flushing readl().

	Jeff


