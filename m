From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH] ehea: Add kdump support
Date: Tue, 27 Nov 2007 11:35:18 +1100
Message-ID: <11699.1196123718@neuling.org>
References: <200711091433.51259.osstklei@de.ibm.com> <1196064988.19855.15.camel@concordia> <OF94123F44.9DB75CE9-ONC125739F.00398E63-C125739F.003B2AFE@de.ibm.com>
Cc: michael@ellerman.id.au, Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <MEDER@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	tklein@linux.ibm.com
To: Christoph Raisch <RAISCH@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33427 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754469AbXK0Afm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 19:35:42 -0500
In-reply-to: <OF94123F44.9DB75CE9-ONC125739F.00398E63-C125739F.003B2AFE@de.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <OF94123F44.9DB75CE9-ONC125739F.00398E63-C125739F.003B2AFE@de.ibm.com> you wrote:
> Michael Ellerman wrote on 26.11.2007 09:16:28:
> > Solutions that might be better:
> >
> >  a) if there are a finite number of handles and we can predict their
> >     values, just delete them all in the kdump kernel before the driver
> >     loads.
> 
> Guessing the values does not work, because of the handle structure
> defined by the hypervisor.
> 
> >  b) if there are a small & finite number of handles, save their values
> >     in a device tree property and have the kdump kernel read them and
> >     delete them before the driver loads.
> 
> 5*16*nr_ports+1+1=   >82. a ML16 has 4 adapters with up to 16 ports, so the
> number is not small anymore....

I assume this machine with a huge number of adapters has a huge amount
of memory too! :-)

> The device tree functions are currently not exported.

We can add this.

> If you crashdump to a new kernel, will it get the device tree
> representation of the crashed kernel or of the initial one of open
> firmware?

The kexec tools userspace control this.  Normally it just takes the
current device tree plus some modifications (eg. initrd location
changes).

So provided the ehea driver export this info somewhere, it can be
grabbed by the kexec tools and stuffed in the device tree of the new
kernel.  

That being said, the proper place to have this would be original device
tree.

> 
> >  c) if neither of those work, provide a minimal routine that _only_
> >     deletes the handles in the crashed kernel.
> 
> I would hope this has the highest chance to actually work.
> For this we would have to add a proper notifier chain.
> Do you agree?
> 
> >  d) <something else>
> 
> Firmware change? But that's not something you will get very soon.
> 
> Christoph R.
> 
