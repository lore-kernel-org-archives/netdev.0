From: "lipeng (Y)" <lipeng321@huawei.com>
Subject: Re: [PATCH net v4 3/3] net: hns: fixed bug that skb used after kfree
Date: Fri, 28 Apr 2017 11:39:35 +0800
Message-ID: <0901245c-5f3d-455c-9d5a-b1b5695755dc@huawei.com>
References: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
 <1493261053-68197-4-git-send-email-yankejian@huawei.com>
 <eb7eaead-f32c-0ffb-3b24-0d6e11a60843@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Yankejian <yankejian@huawei.com>, <davem@davemloft.net>,
        <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <matthias.bgg@gmail.com>, <zhouhuiru@huawei.com>,
        <huangdaode@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:2075 "EHLO
        dggrg05-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1034458AbdD1DkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 23:40:20 -0400
In-Reply-To: <eb7eaead-f32c-0ffb-3b24-0d6e11a60843@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/28 1:38, Florian Fainelli wrote:
> On 04/26/2017 07:44 PM, Yankejian wrote:
>>   	struct hns_nic_priv *priv = netdev_priv(ndev);
>>   	struct hnae_ring *ring = ring_data->ring;
>> @@ -361,6 +361,10 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
>>   	dev_queue = netdev_get_tx_queue(ndev, skb->queue_mapping);
>>   	netdev_tx_sent_queue(dev_queue, skb->len);
>>   
>> +	netif_trans_update(ndev);
>> +	ndev->stats.tx_bytes += skb->len;
>> +	ndev->stats.tx_packets++;
> This is still wrong though, you should not update your TX statistics
> until you get a TX completion interrupt that confirms these packets were
> actually transmitted. This has the advantage of not causing use after
> free in your ndo_start_xmit() function (current bug), and also allows
> feeding information into BQL where it is appropriate, and in a central
> location: the TX completion handler.

Agree, I will fix this, and will delete this patch from patchset and 
refloat it later.
