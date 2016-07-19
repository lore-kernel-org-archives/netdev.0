From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 19 Jul 2016 21:39:14 +0300
Message-ID: <578E73D2.7080209@annapurnalabs.com>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu> <578E0A65.1020105@annapurnalabs.com>
 <20160719172644.GK20674@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, zorik@annapurnalabs.com,
	saeed@annapurnalabs.com, alex@annapurnalabs.com, msw@amazon.com,
	aliguori@amazon.com, benjamin.poirier@gmail.com,
	ben@decadent.org.uk, romieu@fr.zoreil.com, rami.rosen@intel.com,
	antoine.tenart@free-electrons.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719172644.GK20674@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/19/2016 08:26 PM, Leon Romanovsky wrote:
> On Tue, Jul 19, 2016 at 02:09:25PM +0300, Netanel Belgazal wrote:
>>
>> On 07/15/2016 08:00 AM, Leon Romanovsky wrote:
>>> On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
>>>> This is a driver for the ENA family of networking devices.
>>>>
>>>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
>>>> ---
>>>>
>>>> Notes:
>>> ...
>>>
>>>>     - Increase driver version to 1.0.2
>>> ...
>>>
>>>> +static void ena_get_drvinfo(struct net_device *dev,
>>>> +			    struct ethtool_drvinfo *info)
>>>> +{
>>>> +	struct ena_adapter *adapter = netdev_priv(dev);
>>>> +
>>>> +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
>>>> +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
>>> Does module version give anything valuable in real life usage?
>>> Do you plan to bump version after every patch?
>>>
>>> Hint, NO.
>> I think it is appropriate to expose driver version to ethtool, and itis appropriate to be able to version a driver in upstream (mainly for debug purpose)
>> I don't think there is upstream agreementthat no driver should be allowed to maintain a versionnumber.
> You didn't answer on my questions, so I suppose that this version
> interface will be forgotten and won't be relevant after first major
> rework.
>
> You have kernel version to know which driver you are running, mixing
> different versions of driver with other kernels are seeing as
> not-supported by the community.

We need this information for our internal purposes including debugging and problems tracking.
It is in our interests to make sure that versions are managed correctly.
Besides, it seems to be a common practice, and most of the drivers maintain internal driver versions.
   
>>>> +	strlcpy(info->bus_info, pci_name(adapter->pdev),
>>>> +		sizeof(info->bus_info));
>>>> +}
>>>> +
>>>> +
>>> ...
>>>
>>>> +
>>>> +static char version[] =
>>>> +		DEVICE_NAME " v"
>>>> +		DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
>>>> +
>>>> +MODULE_AUTHOR("Amazon.com, Inc. or its affiliates");
>>>> +MODULE_DESCRIPTION(DEVICE_NAME);
>>>> +MODULE_LICENSE("GPL");
>>>> +MODULE_VERSION(DRV_MODULE_VERSION);
>>>> +
>>>> +/* Time in jiffies before concluding the transmitter is hung. */
>>>> +#define TX_TIMEOUT  (5 * HZ)
>>>> +
>>>> +#define ENA_NAPI_BUDGET 64
>>>> +
>>>> +#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | \
>>>> +		NETIF_MSG_TX_DONE | NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
>>>> +static int debug = -1;
>>>> +module_param(debug, int, 0);
>>>> +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
>>> What is it?
>> This is the debugging message interface.
>> https://www.kernel.org/doc/Documentation/networking/netif-msg.txt
> This document was updated last time in 2006 and I doubt that it is
> relevant in 2016. You have dynamic debug prints infrastructure for it,
> use it.

Joe answer for that.
