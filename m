From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] usb-net/pegasus: fix pegasus carrier detection
Date: Tue, 24 Apr 2007 12:49:12 -0400
Message-ID: <462E3508.1030703@garzik.org>
References: <1177424406.13684.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Petko Manolov <petkan@nucleusys.com>, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39713 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240AbXDXQtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 12:49:18 -0400
In-Reply-To: <1177424406.13684.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> Broken by 4a1728a28a193aa388900714bbb1f375e08a6d8e which switched the
> return semantics of read_mii_word() but didn't fix usage of
> read_mii_word() to conform to the new semantics.
> 
> Setting carrier to off based on the NO_CARRIER flag is also incorrect as
> that flag only triggers on TX failure and therefore isn't correct when
> no frames are being transmitted.  Since there is already a 2*HZ MII
> carrier check going on, defer to that.
> 
> Add a TRUST_LINK_STATUS feature flag for adapters where the LINK_STATUS
> flag is actually correct, and use that rather than the NO_CARRIER flag.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>
> 
> diff --git a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
> index d48c024..6d12961 100644
> --- a/drivers/usb/net/pegasus.c
> +++ b/drivers/usb/net/pegasus.c

applied

For drivers/usb/* you should at least CC GregKH.

Long term, Greg seemed OK with moving the net drivers from 
drivers/usb/net to drivers/usb/net, in line with the current policy of 
placing net drivers in drivers/net/*, bus agnostic.  After that move, 
sending to netdev and me (as you did here) would be the preferred avenue.

	Jeff


