From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: Re: [PATCH net-next V2] net: ena: Add a driver for Amazon Elastic
 Network Adapters (ENA)
Date: Thu, 7 Jul 2016 16:07:44 +0300
Message-ID: <577E5420.6030306@annapurnalabs.com>
References: <1467871095-26394-1-git-send-email-netanel@annapurnalabs.com>
 <1467885403.4171.17.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: zorik@annapurnalabs.com, saeed@annapurnalabs.com,
	alex@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
	benjamin.poirier@gmail.com, romieu@fr.zoreil.com,
	rami.rosen@intel.com, antoine.tenart@free-electrons.com
To: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467885403.4171.17.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/07/2016 12:56 PM, Ben Hutchings wrote:
> On Thu, 2016-07-07 at 08:58 +0300, Netanel Belgazal wrote:
> [...]
>> +int ena_get_sset_count(struct net_device *netdev, int sset)
>> +{
>> +       if (sset != ETH_SS_STATS)
>> +               return -EOPNOTSUPP;
>> +
>> +       return  netdev->num_tx_queues *
>> +               (ENA_STATS_ARRAY_TX + ENA_STATS_ARRAY_RX) +
>> +               ENA_STATS_ARRAY_GLOBAL + ENA_STATS_ARRAY_ENA_COM;
> num_tx_queues is the number of software queues originally allocated,
> which may be larger than the number in use (real_num_tx_queues).
>
> And when actually generating the strings:
I'll change it to adapter->num_queues.
>
> [...]
>> +static void ena_queue_strings(struct ena_adapter *adapter, u8 **data)
>> +{
>> +       const struct ena_stats *ena_stats;
>> +       int i, j;
>> +
>> +       for (i = 0; i < adapter->num_queues; i++) {
> you use adapter->num_queues.
>
> [...]
>> +static int ena_nway_reset(struct net_device *netdev)
>> +{
>> +       return -ENODEV;
>> +}
> That doesn't make sense.  The device is there but presumably doesn't
> support autonegotiation.  So don't implement the operation.
Removed
>
> [...]
>> +static int ena_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
>> +                       u8 *hfunc)
>> +{
>> +       struct ena_adapter *adapter = netdev_priv(netdev);
>> +       enum ena_admin_hash_functions ena_func;
>> +       u8 func;
>> +       int rc;
>> +
>> +       rc = ena_com_indirect_table_get(adapter->ena_dev, indir);
>> +       if (rc)
>> +               return rc;
>> +
>> +       rc = ena_com_get_hash_function(adapter->ena_dev, &ena_func, key);
>> +       if (rc)
>> +               return rc;
>> +
>> +       switch (ena_func) {
>> +       case ENA_ADMIN_TOEPLITZ:
>> +               func = ETH_RSS_HASH_TOP;
>> +       case ENA_ADMIN_CRC32:
>> +               func = ETH_RSS_HASH_XOR;
> Missing break statements.
Ack
>
>> +       default:
>> +               netif_err(adapter, drv, netdev,
>> +                         "Command parameter is not supported\n");
>> +               return -EOPNOTSUPP;
>> +       }
> [...]
>> +static const struct ethtool_ops ena_ethtool_ops = {
>> +       .get_settings           = ena_get_settings,
> [...]
>
> get_settings is now deprecated in favour of get_link_ksettings.
>
> Ben.
Ack
>
> Ben.
Thanks for the review.
