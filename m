From: "Aviad Krawczyk (A)" <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH net 20/20] net/hinic: Add ethtool and stats
Date: Thu, 13 Jul 2017 16:16:46 +0300
Message-ID: <a83d8d80-8a4f-1a65-ff4e-71bf4d0828d1@huawei.com>
References: <cover.1499865197.git.aviad.krawczyk@huawei.com>
 <bd60f835144c37334a53df6a053b7efcc4c26c41.1499865198.git.aviad.krawczyk@huawei.com>
 <20170712154347.GH2557@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <bc.y@huawei.com>,
        <victor.gissin@huawei.com>, <zhaochen6@huawei.com>,
        <tony.qu@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([45.249.212.187]:9764 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdGMNRH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 09:17:07 -0400
In-Reply-To: <20170712154347.GH2557@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Andrew,

We will separate the patches when we will resubmit.

Aviad

On 7/12/2017 6:43 PM, Andrew Lunn wrote:
> On Wed, Jul 12, 2017 at 10:17:26PM +0800, Aviad Krawczyk wrote:
> 
> Hi Avaid
> 
>> +
>> +static void hinic_tx_timeout(struct net_device *netdev)
>> +{
>> +	struct hinic_dev *nic_dev = netdev_priv(netdev);
>> +
>> +	netif_err(nic_dev, drv, netdev, "Tx timeout\n");
>> +}
>> +
>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>> +static void hinic_netpoll(struct net_device *netdev)
>> +{
>> +	struct hinic_dev *nic_dev = netdev_priv(netdev);
>> +	struct hinic_hwdev *hwdev = nic_dev->hwdev;
>> +	int i, num_qps = hinic_hwdev_num_qps(hwdev);
>> +
>> +	for (i = 0; i < num_qps; i++) {
>> +		struct hinic_txq *txq = &nic_dev->txqs[i];
>> +		struct hinic_rxq *rxq = &nic_dev->rxqs[i];
>> +
>> +		napi_schedule(&txq->napi);
>> +		napi_schedule(&rxq->napi);
>> +	}
>> +}
>> +#endif
> 
> This has nothing to do with ethtool support. Separate patch please.
> 
>      Andrew
> 
> .
> 
