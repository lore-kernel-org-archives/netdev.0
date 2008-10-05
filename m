From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: deadlock during net device unregistration
Date: Sun, 5 Oct 2008 15:38:49 +0800
Message-ID: <20081005073849.GA13323@gondor.apana.org.au>
References: <E1KmLCH-0003E2-Ch@gondolin.me.apana.org.au> <20081005065509.GA2538@ami.dom.local> <20081005065648.GA13113@gondor.apana.org.au> <20081005071238.GA2752@ami.dom.local> <20081005092823.1b7b88f8@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net,
	netdev@vger.kernel.org, dlezcano@fr.ibm.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57250 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751451AbYJEHjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 03:39:02 -0400
Content-Disposition: inline
In-Reply-To: <20081005092823.1b7b88f8@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 09:28:23AM +0200, Stephen Hemminger wrote:

> I think there were issues with unregister triggering hotplug udev
> events, but that may have been long ago when rtnl_lock was
> a semaphore not a mutex.

Well as it is we have no hotplug events in netdev_run_todo at
all.  They're all in unregister_netdevice which is where they
should be and that runs under the RTNL.

In fact it would be a bug if we had anything in netdev_run_todo
tied to sysfs because once we get here we've relinquished our
ownership of the device name so someone else is free to readd
a device with the same name.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
