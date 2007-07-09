From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based PCI	Express adapters...
Date: Mon, 9 Jul 2007 07:21:24 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF58304209337@orsmsx412.amr.corp.intel.com>
References: <20070705123705.GA19656@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<arjan@linux.intel.com>, <akpm@linux-foundation.org>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62072 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028AbXGIOV0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 10:21:26 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070705123705.GA19656@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From: Neil Horman [mailto:nhorman@tuxdriver.com]
>Replying to myself...
>	I've looked through the driver pretty throughly with regards to
my
>above
>concern, and it appears the driver is reasonably free of netpoll issues
at
>the
>moment, at least as far as what we found in e1000 was concerned.  I do

Thanks for reviewing the code..

>however,
>see a concern in the use of the in_netpoll flag within the driver.
Given
>that
>the primary registered net_device, and all the dummy net_devices in the
>rx_ring
>point to the same ixgbe_adapter structure, there can be some level of
>confusion
>over weather a given rx queue is in netpoll_mode or not.

The revised driver I am going to post today will not have fake
netdevs...

>adapter prforms a netpoll, all the individual rx queues will follow the
>in_netpoll path in the receive path (assuming misx interrupts are
used).
>The
>result I think is the potential for a large amount of packet reordering
>during a
>netpoll operation.  Perhaps not a serious problem, but likely worth
looking

Multiple Rx queues are used in non-NAPI mode only, and all Rx queues use
one netdev (which is associated with the adapter struct). Also, the RSS
(receive side scaling or rx packet steering) feature is used in multiple
rx queues mode. In this mode, HW will always select the same Rx queue
(for a flow) and this should prevent any packet reordering issue.


>Neil

Ayyappan
