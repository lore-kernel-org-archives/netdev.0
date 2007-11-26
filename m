From: Luke Browning <lukebr@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Add kdump support
Date: Mon, 26 Nov 2007 13:41:37 -0200
Message-ID: <1196091697.7513.30.camel@luke-laptop.br.ibm.com>
References: <200711091433.51259.osstklei@de.ibm.com>
	 <1196064988.19855.15.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>,
	Michael Neuling <mikey@neuling.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:55291 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbXKZPlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 10:41:20 -0500
In-Reply-To: <1196064988.19855.15.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-26 at 19:16 +1100, Michael Ellerman wrote:

> 
> Hi Thomas,
> 
> I'm sorry, but this patch is all wrong IMHO.
> 
> For kdump we have to assume that the kernel is fundamentally broken,
> we've panicked, so something bad has happened - every line of kernel
> code that is run decreases the chance that we'll successfully make it
> into the kdump kernel.

I agree with Michael.

> Solutions that might be better:
> 
>  a) if there are a finite number of handles and we can predict their 
>     values, just delete them all in the kdump kernel before the driver
>     loads.

This is a good solution if handles are predefined.

>  b) if there are a small & finite number of handles, save their values 
>     in a device tree property and have the kdump kernel read them and 
>     delete them before the driver loads.

Also good but is more complicated.  

>  c) if neither of those work, provide a minimal routine that _only_
>     deletes the handles in the crashed kernel.
>  d) <something else>

Can the driver or configuration method for the driver query PHYP to
determine if there are any pre-existing mappings... 

Regards, Luke

