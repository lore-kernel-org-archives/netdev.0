From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH] ehea: Add kdump support
Date: Mon, 26 Nov 2007 11:45:02 +0100
Message-ID: <OF94123F44.9DB75CE9-ONC125739F.00398E63-C125739F.003B2AFE@de.ibm.com>
References: <200711091433.51259.osstklei@de.ibm.com> <1196064988.19855.15.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	Michael Neuling <mikey@neuling.org>,
	netdev <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	tklein@linux.ibm.com
To: michael@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:25954 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbXKZKpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 05:45:06 -0500
In-Reply-To: <1196064988.19855.15.camel@concordia>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Ellerman wrote on 26.11.2007 09:16:28:
> Solutions that might be better:
>
>  a) if there are a finite number of handles and we can predict their
>     values, just delete them all in the kdump kernel before the driver
>     loads.

Guessing the values does not work, because of the handle structure
defined by the hypervisor.

>  b) if there are a small & finite number of handles, save their values
>     in a device tree property and have the kdump kernel read them and
>     delete them before the driver loads.

5*16*nr_ports+1+1=   >82. a ML16 has 4 adapters with up to 16 ports, so the
number
is not small anymore....
The device tree functions are currently not exported.

If you crashdump to a new kernel, will it get the device tree
representation
of the crashed kernel or of the initial one of open firmware?

>  c) if neither of those work, provide a minimal routine that _only_
>     deletes the handles in the crashed kernel.

I would hope this has the highest chance to actually work.
For this we would have to add a proper notifier chain.
Do you agree?

>  d) <something else>

Firmware change? But that's not something you will get very soon.

Christoph R.

