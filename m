From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 17:00:57 +0000
Message-ID: <20090324170057.5d09d5f0@lxorguk.ukuu.org.uk>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
	<49C9087C.5070907@trash.net>
	<1237912858.9082.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:44769 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1762593AbZCXRAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 13:00:43 -0400
In-Reply-To: <1237912858.9082.39.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If the MAC address isn't a UUID for the device, then *what* is?

MAC is technically per system if desired (eg old Sun boxes) and that is
quite valid by IEE802.3. In that case you need MAC + topology.

If you are running DECnet your system runs on assigned MAC addresses so
you also have to be careful to use the EPROM MAC (if one exists which is
99.9% of the time) + topology.

> Either people want (a) a name assigned to a specific device (which
> implies a UUID like a MAC address stored on that device somewhere
> accessible to the driver at plug/boot time), or they want (b) to assign
> a name to a *position* on the PCI or USB or firewire or whatever bus, or
> they (c) don't care about this at all.

I'd argue the fumdamental problem is that I can do this

	ln -s /dev/sda /dev/thebigdiskunderthefridge

but cannot ln -s /dev/eth0 /dev/ethernet/slot0

and the SIOCGIF/SIF BSD style ioctl interface doesn't do pathnames or
file handles of network devices.

Anyone feel up to putting all the network devices into dev space and
fixing the ioctls ;)
