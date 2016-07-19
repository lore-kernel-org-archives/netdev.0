From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next V3] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Tue, 19 Jul 2016 14:09:25 +0300
Message-ID: <578E0A65.1020105@annapurnalabs.com>
References: <1468478774-19942-1-git-send-email-netanel@annapurnalabs.com>
 <20160715050005.GD30603@leon.nu>
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
In-Reply-To: <20160715050005.GD30603@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/15/2016 08:00 AM, Leon Romanovsky wrote:
> On Thu, Jul 14, 2016 at 09:46:14AM +0300, Netanel Belgazal wrote:
>> This is a driver for the ENA family of networking devices.
>>
>> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
>> ---
>>
>> Notes:
> ...
>
>>     - Increase driver version to 1.0.2
> ...
>
>> +static void ena_get_drvinfo(struct net_device *dev,
>> +			    struct ethtool_drvinfo *info)
>> +{
>> +	struct ena_adapter *adapter = netdev_priv(dev);
>> +
>> +	strlcpy(info->driver, DRV_MODULE_NAME, sizeof(info->driver));
>> +	strlcpy(info->version, DRV_MODULE_VERSION, sizeof(info->version));
> Does module version give anything valuable in real life usage?
> Do you plan to bump version after every patch?
>
> Hint, NO.

I think it is appropriate to expose driver version to ethtool, and itis appropriate to be able to version a driver in upstream (mainly for debug purpose)
I don't think there is upstream agreementthat no driver should be allowed to maintain a versionnumber.

>> +	strlcpy(info->bus_info, pci_name(adapter->pdev),
>> +		sizeof(info->bus_info));
>> +}
>> +
>> +
> ...
>
>> +
>> +static char version[] =
>> +		DEVICE_NAME " v"
>> +		DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
>> +
>> +MODULE_AUTHOR("Amazon.com, Inc. or its affiliates");
>> +MODULE_DESCRIPTION(DEVICE_NAME);
>> +MODULE_LICENSE("GPL");
>> +MODULE_VERSION(DRV_MODULE_VERSION);
>> +
>> +/* Time in jiffies before concluding the transmitter is hung. */
>> +#define TX_TIMEOUT  (5 * HZ)
>> +
>> +#define ENA_NAPI_BUDGET 64
>> +
>> +#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | \
>> +		NETIF_MSG_TX_DONE | NETIF_MSG_TX_ERR | NETIF_MSG_RX_ERR)
>> +static int debug = -1;
>> +module_param(debug, int, 0);
>> +MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
> What is it?

This is the debugging message interface.
https://www.kernel.org/doc/Documentation/networking/netif-msg.txt

>> +
>> +static int push_mode;
>> +module_param(push_mode, int, 0);
>> +MODULE_PARM_DESC(push_mode, "Descriptor / header push mode (0=automatic,1=disable,3=enable)\n"
>> +		 "\t\t\t  0 - Automatically choose according to device capability (default)\n"
>> +		 "\t\t\t  1 - Don't push anything to device memory\n"
>> +		 "\t\t\t  3 - Push descriptors and header buffer to device memory");
>> +
>> +static int enable_wd = 1;
>> +module_param(enable_wd, int, 0);
>> +MODULE_PARM_DESC(enable_wd, "Enable keepalive watchdog (0=disable,1=enable,default=1)");
>> +
>> +static int enable_missing_tx_detection = 1;
>> +module_param(enable_missing_tx_detection, int, 0);
>> +MODULE_PARM_DESC(enable_missing_tx_detection, "Enable missing Tx completions. (default=1)");
>> +
>> +static int numa_node_override_array[NR_CPUS] = {[0 ... (NR_CPUS - 1)] = NUMA_NO_NODE };
>> +module_param_array(numa_node_override_array, int, NULL, 0);
>> +MODULE_PARM_DESC(numa_node_override_array, "Numa node override map\n");
>> +
>> +static int numa_node_override;
>> +module_param(numa_node_override, int, 0);
>> +MODULE_PARM_DESC(numa_node_override, "Enable/Disable numa node override (0=disable)\n");
> As fas as I remember, new drivers are not supposed to add module
> parameters.
>
Ack, I'll remove those module params.

> ...
>
>> +
>> +#define DRV_MODULE_VER_MAJOR	1
>> +#define DRV_MODULE_VER_MINOR	0
>> +#define DRV_MODULE_VER_SUBMINOR 1
>> +
>> +#define DRV_MODULE_NAME		"ena"
>> +#ifndef DRV_MODULE_VERSION
>> +#define DRV_MODULE_VERSION \
>> +	__stringify(DRV_MODULE_VER_MAJOR) "."	\
>> +	__stringify(DRV_MODULE_VER_MINOR) "."	\
>> +	__stringify(DRV_MODULE_VER_SUBMINOR)
>> +#endif
>> +#define DRV_MODULE_RELDATE      "22-JUNE-2016"
> Please remove it, driver version is useless in real life kernel usage.
>

I'll remove the driver date.
