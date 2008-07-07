From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Mon, 07 Jul 2008 15:57:23 -0700 (PDT)
Message-ID: <20080707.155723.48071035.davem@davemloft.net>
References: <20080706180842.36cc0b1c@extreme>
	<20080706.182243.65603166.davem@davemloft.net>
	<adafxqlxqi5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, arjan@infradead.org, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60852
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756997AbYGGW5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 18:57:23 -0400
In-Reply-To: <adafxqlxqi5.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 07 Jul 2008 15:45:38 -0700

>  > > For consistency each call through ethtool_ops should
>  > > be holding rtnl mutex. And since dev_watchdog is a timer routine,
>  > > it is not safe to acquire a mutex there.
>  > 
>  > I think "get driver info", which does nothing but copy strings out of
>  > the driver software state, is a safe exception to these strict locking
>  > rules.
> 
> it seems that's not universally the case, eg get_drvinfo() in
> drivers/net/cxgb3/cxgb3_main.c does
> 
> 	t3_get_fw_version(adapter, &fw_vers);
> 	t3_get_tp_version(adapter, &tp_vers);
> 
> and from reading further in the code it's not obvious that this is safe
> to do without serialization (it calls into t3_read_flash(), which does a
> typical "write address reg, read data reg" sequence to access flash,
> without any locking).

I doubt it uses the RTNL semaphore elsewhere to protect
against this path, which is the only protection these
calls currently have.

Please don't bring up scarecrows, this looks like simply
a bug which already exists.
