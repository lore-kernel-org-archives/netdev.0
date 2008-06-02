From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 02 Jun 2008 20:47:38 +0200
Message-ID: <87abi365dh.fsf@macbook.be.48ers.dk>
References: <20080515170728.GA3176@PTXN0038.genpitfi01.og.ge.com>
	<1211200476-21297-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael.Hennerich@analog.com, Enrik.Berkhan@ge.com,
	hennerich@blackfin.uclinux.org, ian.saturley@smsc.com,
	uclinux-dist-devel@blackfin.uclinux.org, catalin.marinas@arm.com,
	netdev@vger.kernel.org, Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	Bill Gatliff <bgat@billgatliff.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:34553 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbYFBSsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 14:48:09 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1195930mue.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 11:48:06 -0700 (PDT)
In-Reply-To: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com> (Steve Glendinning's message of "Mon\, 19 May 2008 13\:34\:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Steve" == Steve Glendinning <steve.glendinning@smsc.com> writes:

Hi,

 Steve> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
 Steve> index 9f6cc8a..8f12a8e 100644
 Steve> --- a/drivers/net/Kconfig
 Steve> +++ b/drivers/net/Kconfig
 Steve> @@ -967,6 +967,19 @@ config SMC911X
 Steve>  	  called smc911x.  If you want to compile it as a module, say M 
 Steve>  	  here and read <file:Documentation/kbuild/modules.txt>
 
 Steve> +config SMSC911X
 Steve> +	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
 Steve> +	depends on NET_ETHERNET
 Steve> +	select CRC32
 Steve> +	select MII
 Steve> +	---help---
 Steve> +	  Say Y here if you want support for SMSC LAN911x and LAN921x families
 Steve> +	  of ethernet controllers.
 Steve> +
 Steve> +	  To compile this driver as a module, choose M here and read
 Steve> +	  <file:Documentation/networking/net-modules.txt>. The module
 Steve> +	  will be called smsc911x.
 Steve> +

What is the point of 2 drivers for the same hardware? Either fix the
existing driver or remove the old one and reuse the Kconfig symbols
for the new one so the existing defconfig continues to work.

Like I said last year, I would really prefer the first option:

http://thread.gmane.org/gmane.linux.network/66703/focus=67812

You also don't seem to have added the big endian test I mentioned
further in the thread.

 Steve> +static void smsc911x_mdio_write(struct net_device *dev, int phy_id,
 Steve> +				int location, int val)
 Steve> +{
 Steve> +	struct smsc911x_data *pdata = netdev_priv(dev);
 Steve> +	unsigned long flags;
 Steve> +
 Steve> +	spin_lock_irqsave(&pdata->phy_lock, flags);
 Steve> +	smsc911x_phy_write(pdata, location, val);
 Steve> +	spin_unlock_irqrestore(&pdata->phy_lock, flags);
 Steve> +}
 Steve> +
 Steve> +/* Autodetects and initialises external phy for SMSC9115 and SMSC9117 flavors.
 Steve> + * If something goes wrong, returns -ENODEV to revert back to internal phy.
 Steve> + * Performed at initialisation only, so interrupts are enabled */
 Steve> +static int smsc911x_phy_initialise_external(struct smsc911x_data *pdata)

Any reason why you don't use phylib?

-- 
Bye, Peter Korsgaard
