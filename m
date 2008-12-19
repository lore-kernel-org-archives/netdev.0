From: Steve.Glendinning@smsc.com
Subject: Re: smsc911x unloading crash
Date: Fri, 19 Dec 2008 12:13:31 +0000
Message-ID: <OFB5E57180.CCA30733-ON80257524.00382ADA-80257524.004340AF@smsc.com>
References: <20081218.225515.12838744.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: dfoley@telus.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2519 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752680AbYLSMPF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Dec 2008 07:15:05 -0500
In-Reply-To: <20081218.225515.12838744.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi dfoley,

> I am testing out the new smsc911x driver that is in the linux-next tree.
> I get a crash when unloading the module. I've got this patch to 
> fix it. I noticed that the dev_set_drvdata is clobbering the data when
> the driver's ..._remove function calls dev = platform_get_drvdata(pdev);
> I've back ported this to run on 2.6.27, so this patch may or
> may not be needed. Sorry if it's a matter of not having the latest 
version.

This is indeed a bug, thanks for finding it.  Some other drivers use the
device driver_data for storing their mii_bus, but we already store our
net_device there so we shouldn't be setting this here.

> dfoley, even if your patch is correct your email client has severely
> corrupted the patch (changing tab characters into spaces, etc.) so if
> this patch is still needed you'll need to resubmit with your email
> client fixed to not corrupt the patch with formatting changes.

The [broken] patch actually fixes two different bugs, can you split this
into two patches?

The second bug is a typo - It's supposed to look the same as the code
in smsc911x_drv_probe 35 lines later, but it's missing the assignment.

Both Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
