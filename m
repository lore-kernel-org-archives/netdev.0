From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] net: smsc911x: add power management functions
Date: Tue, 5 May 2009 09:37:42 +0100
Message-ID: <OF7B58C3C5.29BA38D0-ON802575AD.002E7A8A-802575AD.002F637B@smsc.com>
References: <1241457122-28161-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Ian.Saturley@smsc.com
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4340 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754587AbZEEIh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 04:37:58 -0400
In-Reply-To: <1241457122-28161-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack <daniel@caiaq.de> wrote on 04/05/2009 18:12:02:

> This adds a power management implementation for smsc911x.c which assumes
> the chips remains powered during suspend. The device is put in its D1
> power saving mode.

[....]

> +static int smsc911x_resume(struct platform_device *pdev)
> +{
> +   struct net_device *dev = platform_get_drvdata(pdev);
> +   struct smsc911x_data *pdata = netdev_priv(dev);
> +   unsigned int to = 100;
> +
> +   /* Note 3.11 from the datasheet:
> +    *    "When the LAN9220 is in a power saving state, a write of any
> +    *     data to the BYTE_TEST register will wake-up the device."
> +    */
> +   smsc911x_reg_write(pdata, BYTE_TEST, 0);
> +
> +   /* poll the READY bit in PMT_CTRL. Any other access to the device is
> +    * forbidden while this bit isn't set. Try for 100ms and return -EIO
> +    * if it failed. */
> +   while (!(smsc911x_reg_read(pdata, PMT_CTRL) & PMT_CTRL_READY_) && 
to--)
> +      udelay(1000);
> +
> +   return (to == 0) ? -EIO : 0;
> +}

to-- should be --to, otherwise it'll end up as -1 when the loop times out
(and the error code return below won't work).  Roel Kluin recently fixed
many instances of this.

Other than that, the power saving logic looks fine.

Steve
