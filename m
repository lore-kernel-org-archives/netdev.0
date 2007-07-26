From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/1]ixgbe: Driver for Intel 82598 based 10GbE PCI Express
 family of adapters
Date: Thu, 26 Jul 2007 23:22:29 +0100
Message-ID: <46A91EA5.9060005@linux-foundation.org>
References: <20070726200105.27129.18979.stgit@localhost.localdomain> <20070726200841.27129.76915.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, arjan@linux.intel.com,
	akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	hch@infradead.org, nhorman@tuxdriver.com, inaky@linux.intel.com,
	mb@bu3sch.de, john.ronciak@intel.com
To: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38419 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765445AbXGZWYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 18:24:22 -0400
In-Reply-To: <20070726200841.27129.76915.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +
> +Command Line Parameters
> +=======================
> +
> +If the driver is built as a module, the  following optional parameters are
> +used by entering them on the command line with the modprobe command using
> +this syntax:
> +
> +     modprobe ixgbe [<option>=<VAL1>,<VAL2>,...]
> +
> +For example, with two PRO/10GbE PCI Express adapters, entering:
> +
> +     modprobe ixgbe TxDescriptors=80,128
> +
> +loads the ixgbe driver with 80 TX resources for the first adapter and 128 TX
> +resources for the second adapter.
> +
> +The default value for each parameter is generally the recommended setting,
> +unless otherwise noted.
> +
> +
> +RxQueues
> +--------
> +Valid Range: 1, 2, 4, 8
> +Default Value: 8
> +    Number of RX queues.
> +   
> +
> +RxFCHighThresh
> +--------------
> +Valid Range: 1,536 - 262,136 (0x600 - 0x3FFF8, 8 byte granularity)
> +Default Value: 196,608 (0x30000)
> +    Receive Flow control high threshold (when we send a pause frame)
> +
> +
> +RxFCLowThresh
> +-------------
> +Valid Range: 64 - 262,136 (0x40 - 0x3FFF8, 8 byte granularity)
> +             *  must be less than high threshold by at least 8 bytes
> +Default Value:  163,840 (0x28000)
> +Receive Flow control low threshold (when we send a resume frame)
>   
Does this really need to be tunable?
> +
> +
> +RxBufferMode
> +------------
> +Valid Range: 0-2
> +Default Value: 2
> +0 = Driver will use single buffer for Rx packets.
> +1 = Driver will use packet split mode for Rx. Packet header will be 
> +received in header buffer and payload will be received in data buffer.
> +2. = Optimal mode. Driver will use single buffer mode for non-Jumbo 
> +configurations and packet split mode for Jumbo configurations.
> +
> +
> +InterruptType
> +-------------
> +Valid Range: 0-2 0 = Legacy Int, 1 = MSI and 2 = MSIX
> +Default Value: 2
> +    Interrupt type
>   
Bogus, just do it.
> +
> +
> +FCReqTimeout
> +------------
> +Valid Range: 1 - 65535
> +Default Value:  65535 (0xffff) (will send an xon if we recover)
> +    Flow control request timeout (how long to pause the link partner's tx)
> +
>   
Extend ethtool?
> +
> +InterruptThrottleRate
> +---------------------
> +Valid Range: 100-100000 (0=off, 1=dynamic)
> +Default Value: 
> +    Interrupt Throttle Rate (interrupts/sec)
>   
Use ethtool for this
> +
> +
> +FlowControl
> +-----------
> +Valid Range: 0-3
> +0 - No Flow Control
> +1 - Rx only, respond to PAUSE frames but do not generate them
> +2 - Tx only, generate PAUSE frames but ignore them on receive
> +3 - Full Flow Control Support
> +Default Value: 1 - Rx only 
> +    User Specified Flow Control Override
> +
>   
Use ethtool, no module parameter please
> +
> +LLIPort
> +-------
> +Valid Range: 0 - 65535
> +Default Value: 0 (disabled)
> +
> +  LLI is configured with the LLIPort command-line parameter, which specifies 
> +  which TCP should general Low Latency Interrupts.
> +
> +  For example, using LLIPort=80 would cause the board to generate an 
> +  immediate interrupt upon receipt of any packet sent to TCP port 80 on the 
> +  local machine.
> +
>   
This seems like a bogus feature, it is very protocol specific, and won't 
work
with encapsulation, and probably not IPV6.
> +
> +LLIPush
> +-------
> +Valid Range: 0-1
> +Default Value: 0 (disabled)
> +
> +  LLIPush can be set to be enabled or disabled (default). It is most 
> +  effective in an environment with many small transactions.
> +  NOTE: Enabling LLIPush may allow a denial of service attack.
>   

Extend ethtool instead?
> +
> +
> +LLISize
> +-------
> +Valid Range: 0-1500
> +Default Value: 0 (disabled)
> +
> +  LLISize causes an immediate interrupt if the board receives a packet smaller 
> +  than the specified size.
>   
Another odd hardware feature. Just because hardware supports it,
you don't have to have driver support.
> +
> +
> +Support
> +=======
> +
> +For general information, go to the Intel support website at:
> +
> +    http://support.intel.com
> +
> +or the Intel Wired Networking project hosted by Sourceforge at:
> +
> +    http://sourceforge.net/projects/e1000
> +
> +If an issue is identified with the released source code on the supported
> +kernel with a supported adapter, email the specific information related
> +to the issue to e1000-devel@lists.sf.net
>   
Using module parameter for per device settings is bad idea.
Please extend existing interfaces like ethtool, etc rather than committing
to a bad inflexible API.

