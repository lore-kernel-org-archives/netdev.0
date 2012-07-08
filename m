From: David Miller <davem@davemloft.net>
Subject: Re: [net-next patch] bnx2x: Add run-time CNIC support
Date: Sun, 08 Jul 2012 05:15:50 -0700 (PDT)
Message-ID: <20120708.051550.2116528390715127326.davem@davemloft.net>
References: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
	<20120708.033122.2108511545126626834.davem@davemloft.net>
	<1341745239.27284.13.camel@lb-tlvb-meravs.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: meravs@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab2GHMPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 08:15:53 -0400
In-Reply-To: <1341745239.27284.13.camel@lb-tlvb-meravs.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Merav Sicron" <meravs@broadcom.com>
Date: Sun, 8 Jul 2012 14:00:39 +0300

> static int set_is_cnic_enabled(bool is_vf)
> {
>         if (is_vf)
>                 return 0;
> #if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
>         return 1;
> #else
>         return 0;
> #endif
> }

I still think this is beyond ugly.

This ifdef just wants to die completely.  It serves no real
purpose as every distribution vendor that turns on your driver
will turn CNIC on as well.

And you have to address the lost of const'ness of the netdevice ops.
If you absolutely must have runtime method choices, you must use
multiple instances of netdevice ops and assign the appropriate one.
