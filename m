From: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Subject: RE: [PATCH 1/1]ixgbe: Driver for Intel 82598 based 10GbE PCI Express family of adapters
Date: Fri, 27 Jul 2007 12:45:59 -0700
Message-ID: <E35F4F4D7F6C9E4E826FEC1F86CEF58304487242@orsmsx412.amr.corp.intel.com>
References: <46A9F882.3000208@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <arjan@linux.intel.com>,
	<akpm@linux-foundation.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hch@infradead.org>,
	<nhorman@tuxdriver.com>, <inaky@linux.intel.com>, <mb@bu3sch.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17320 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935563AbXG0TqB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 15:46:01 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46A9F882.3000208@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Jeff Garzik [mailto:jeff@garzik.org]
>
>Stephen Hemminger wrote:
>> Using module parameter for per device settings is bad idea.
>> Please extend existing interfaces like ethtool, etc rather than
>committing
>> to a bad inflexible API.
>
>
>I agreed with Stephen's comments here.
>
>In general, net driver policy is to use ethtool (per-interface
>granularity) rather than module options.
>

Thanks Stephen and Jeff for the feedback. The flow control and
InterruptThrottleRate parameters were carried over from e1000 and it was
pointed out to me that some disros/customer's scripts used those
parameters in the scripts. Ixgbe being a new driver, we can remove
those.

Yes the LLI parameters can be removed.

> +RxQueues
> +--------
> +Valid Range: 1, 2, 4, 8
> +Default Value: 8
> +    Number of RX queues.
> +
> +

Ok. The present driver being NAPI only and supports one Rx queue only.
So this parameter needs to be removed .

But, once we have DaveM/Stephen work of NAPI struct work is done, driver
will support multiple Rx queues and with Multi Tx queue patch already in
the kernel, driver will support multiple Tx queues also shortly.

So, with driver/device supporting multiple Tx and Rx queues, I think, it
would be very useful to have ethtool interface to manage the number of
Tx and Rx queues of the interface. Current ethtool interface supports
managing the ring size so, we need similar interface for managing the
number of Tx and Rx queues of the interface.

Ayyappan
