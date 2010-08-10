From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 1/2] pci: add function reset call that can be used
 inside	of probe
Date: Tue, 10 Aug 2010 16:14:31 -0700
Message-ID: <4C61DD57.5030208@intel.com>
References: <20100731005803.32625.6891.stgit@localhost.localdomain> <4C612C5E.8020909@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4321 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932670Ab0HJXOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Aug 2010 19:14:32 -0400
In-Reply-To: <4C612C5E.8020909@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kenji Kaneshige wrote:
> (2010/07/31 9:58), Jeff Kirsher wrote:
>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>> +	/*
>> +	 * both INTx and MSI are disabled after the Interrupt Disable bit
>> +	 * is set and the Bus Master bit is cleared.
>> +	 */
>> +	pci_write_config_word(dev, PCI_COMMAND, PCI_COMMAND_INTX_DISABLE);
>> +
>> +	rc = __pci_dev_reset(dev, 0);
> 
> Could you tell me why you need to program command register before reset?
> 
> "MSI enable" and "Bus Master" bits are cleared by the reset. Furthermore,
> resetting the device clears the "Interrupt Disable bit", even though it
> was set just before the rest. So I'm a little confused.
> 
> Thanks,
> Kenji Kaneshige
> 

The point is to prevent any pending transactions from being on the bus 
while we are doing the reset.  By writing only the INTX disable bit we 
are disabling all interrupts from being generated, and also disabling 
all DMA and MSI interrupts since the bus master enable bit is not set.

Without this change the device might be in the middle of a transaction 
or sending an interrupt while we are doing the reset which may lead to 
other issues after the reset.

Thanks,

Alex
