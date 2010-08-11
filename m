From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Subject: Re: [RFC PATCH 1/2] pci: add function reset call that can be used
 inside	of probe
Date: Wed, 11 Aug 2010 09:44:03 +0900
Message-ID: <4C61F253.8050700@jp.fujitsu.com>
References: <20100731005803.32625.6891.stgit@localhost.localdomain> <4C612C5E.8020909@jp.fujitsu.com> <4C61DD57.5030208@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4C61DD57.5030208@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2010/08/11 8:14), Alexander Duyck wrote:
> Kenji Kaneshige wrote:
>> (2010/07/31 9:58), Jeff Kirsher wrote:
>>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>> + /*
>>> + * both INTx and MSI are disabled after the Interrupt Disable bit
>>> + * is set and the Bus Master bit is cleared.
>>> + */
>>> + pci_write_config_word(dev, PCI_COMMAND, PCI_COMMAND_INTX_DISABLE);
>>> +
>>> + rc = __pci_dev_reset(dev, 0);
>>
>> Could you tell me why you need to program command register before reset?
>>
>> "MSI enable" and "Bus Master" bits are cleared by the reset. Furthermore,
>> resetting the device clears the "Interrupt Disable bit", even though it
>> was set just before the rest. So I'm a little confused.
>>
>> Thanks,
>> Kenji Kaneshige
>>
>
> The point is to prevent any pending transactions from being on the bus
> while we are doing the reset. By writing only the INTX disable bit we
> are disabling all interrupts from being generated, and also disabling
> all DMA and MSI interrupts since the bus master enable bit is not set.
>
> Without this change the device might be in the middle of a transaction
> or sending an interrupt while we are doing the reset which may lead to
> other issues after the reset.
>

Thank you for clarification. I understood.

Thanks,
Kenji Kaneshige
